// SPDX-License-Identifier: MIT
// Open-source license. Anyone can read, reuse, and verify this code.

pragma solidity ^0.8.19;
// Solidity version 0.8.19 gives us built-in overflow protection on all math.

contract ClassCall {

    // ══════════════════════════════════════════════════════════════
    //  ENUM — Defines the two supported question formats
    // ══════════════════════════════════════════════════════════════

    // YesNo  = contract auto-creates ["Yes", "No"] as the options.
    // MultiChoice = owner passes a custom list like ["Pizza", "Tacos", "Sushi"].
    enum QuestionType { YesNo, MultiChoice }

    // ══════════════════════════════════════════════════════════════
    //  STRUCT — Blueprint for a single question's data
    // ══════════════════════════════════════════════════════════════

    // Everything about one question is grouped here.
    // Once created, text and options can NEVER be changed.
    struct Question {
        string text;                // The question everyone sees ("Is a hotdog a sandwich?")
        QuestionType questionType;  // YesNo or MultiChoice
        string[] options;           // The voteable option names
        uint256[] voteCounts;       // Parallel array: voteCounts[i] = votes for options[i]
        bool isHidden;              // If true, voting is permanently blocked
        uint256 deadline;           // Unix timestamp when voting closes (0 = no time limit)
    }

    // ══════════════════════════════════════════════════════════════
    //  STATE VARIABLES — Stored permanently on the blockchain
    // ══════════════════════════════════════════════════════════════

    // Dynamic array of all questions. New ones are pushed; none are ever removed.
    // Private so we control access through getter functions below.
    Question[] private questions;

    // The wallet address that deployed this contract.
    // 'immutable' = set once in constructor, can never be changed, saves gas.
    address public immutable owner;

    // Nested mapping: questionIndex => walletAddress => hasThisWalletVoted
    // Example: hasVoted[2][0xABC] = true means wallet 0xABC voted on question #2.
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    // ══════════════════════════════════════════════════════════════
    //  EVENTS — Broadcast to the frontend for real-time updates
    // ══════════════════════════════════════════════════════════════

    // Fired when the owner creates a new question.
    // Frontend listens for this to dynamically add the question to the UI.
    event QuestionAdded(
        uint256 indexed questionIndex,  // Position in the questions array
        QuestionType questionType,      // YesNo or MultiChoice
        string text,                    // The question text
        uint256 deadline                // When voting ends (0 = no limit)
    );

    // Fired when the owner hides a question.
    // Frontend listens for this to remove the question from the active view.
    event QuestionHidden(uint256 indexed questionIndex);

    // Fired every time someone successfully votes.
    // Frontend listens for this to update vote counts in real time.
    event VoteCast(
        address indexed voter,          // Which wallet voted
        uint256 indexed questionIndex,  // Which question they voted on
        uint256 optionIndex,            // Which option they chose (0, 1, 2...)
        string optionName,              // Human-readable option name ("Yes", "Pizza")
        uint256 newOptionTotal          // Updated vote count for that option
    );

    // ══════════════════════════════════════════════════════════════
    //  MODIFIERS — Reusable checks attached to functions
    // ══════════════════════════════════════════════════════════════

    // Restricts a function so only the contract deployer can call it.
    // The underscore (_) represents where the function's own code runs.
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can do this");
        _;
    }

    // Ensures the question index actually exists in the array.
    // Prevents crashes from accessing an array slot that doesn't exist.
    modifier validQuestion(uint256 _questionIndex) {
        require(_questionIndex < questions.length, "Question does not exist");
        _;
    }

    // ══════════════════════════════════════════════════════════════
    //  CONSTRUCTOR — Runs exactly once when the contract is deployed
    // ══════════════════════════════════════════════════════════════

    // Saves the deployer's wallet as the permanent owner.
    // No questions are created here — owner adds them after deployment.
    constructor() {
        owner = msg.sender;
    }

    // ══════════════════════════════════════════════════════════════
    //  OWNER FUNCTIONS — Only the deployer can call these
    // ══════════════════════════════════════════════════════════════

    /*
        addQuestion()
        Creates a new question and stores it on-chain forever.

        Parameters:
        - _questionType : YesNo (0) or MultiChoice (1)
        - _text         : The question string
        - _options      : Custom option names (ignored for YesNo)
        - _durationSeconds : How long voting stays open
                             Pass 0 for no time limit
                             Pass 60 for 60 seconds, 300 for 5 minutes, etc.

        Returns: The index of the newly created question.
    */
    function addQuestion(
        QuestionType _questionType,
        string calldata _text,
        string[] calldata _options,
        uint256 _durationSeconds
    ) external onlyOwner returns (uint256) {

        // Question text cannot be empty.
        require(bytes(_text).length > 0, "Question text cannot be empty");

        // Calculate the deadline timestamp.
        // If duration is 0, deadline stays 0 (meaning no limit).
        // Otherwise, deadline = current time + duration.
        uint256 finalDeadline = 0;
        if (_durationSeconds > 0) {
            finalDeadline = block.timestamp + _durationSeconds;
        }

        // Push an empty Question struct into storage, then fill it.
        // This pattern works reliably with dynamic arrays inside structs.
        questions.push();
        uint256 newIndex = questions.length - 1;
        Question storage q = questions[newIndex];

        // Set the basic fields.
        q.text = _text;
        q.questionType = _questionType;
        q.isHidden = false;
        q.deadline = finalDeadline;

        // Populate options based on question type.
        if (_questionType == QuestionType.YesNo) {
            // YesNo questions always get exactly two options.
            // Owner's _options parameter is ignored for this type.
            q.options.push("Yes");
            q.options.push("No");
            q.voteCounts.push(0);
            q.voteCounts.push(0);
        } else {
            // MultiChoice requires at least 2 custom options.
            require(_options.length >= 2, "MultiChoice needs at least 2 options");

            // Copy each option into storage. Cannot be changed after this.
            for (uint256 i = 0; i < _options.length; i++) {
                require(bytes(_options[i]).length > 0, "Option text cannot be empty");
                q.options.push(_options[i]);
                q.voteCounts.push(0);
            }
        }

        // Broadcast so the frontend can instantly show the new question.
        emit QuestionAdded(newIndex, _questionType, _text, finalDeadline);

        // Return the index so the owner knows which question was created.
        return newIndex;
    }

    /*
        hideQuestion()
        Permanently hides a question from voting.
        The question and its votes remain on-chain — nothing is deleted.
        This is the only way to "close" a question that has no deadline.
    */
    function hideQuestion(uint256 _questionIndex)
        external
        onlyOwner
        validQuestion(_questionIndex)
    {
        Question storage q = questions[_questionIndex];

        // Can't hide a question that's already hidden.
        require(!q.isHidden, "Question is already hidden");

        // Set the hidden flag. Voting is now blocked forever.
        q.isHidden = true;

        // Broadcast so the frontend can remove it from the active list.
        emit QuestionHidden(_questionIndex);
    }

    // ══════════════════════════════════════════════════════════════
    //  VOTING — Anyone with a wallet can call this (costs gas)
    // ══════════════════════════════════════════════════════════════

    /*
        castVote()
        Works identically for YesNo and MultiChoice questions.

        Parameters:
        - _questionIndex : Which question to vote on (0, 1, 2...)
        - _optionIndex   : Which option to vote for
                           YesNo: 0 = Yes, 1 = No
                           MultiChoice: 0 = first option, 1 = second, etc.
    */
    function castVote(uint256 _questionIndex, uint256 _optionIndex)
        external
        validQuestion(_questionIndex)
    {
        // Get a reference to the question in storage (so changes persist).
        Question storage q = questions[_questionIndex];

        // Rule 1: Cannot vote on a hidden question.
        require(!q.isHidden, "This question is no longer active");

        // Rule 2: Cannot vote after the deadline has passed.
        // If deadline is 0, this check is skipped (no time limit).
        if (q.deadline != 0) {
            require(block.timestamp <= q.deadline, "Voting deadline has passed");
        }

        // Rule 3: Each wallet can only vote once per question.
        require(
            !hasVoted[_questionIndex][msg.sender],
            "You already voted on this question"
        );

        // Rule 4: The chosen option must actually exist.
        require(_optionIndex < q.options.length, "Invalid option index");

        // Record that this wallet has now voted on this question.
        hasVoted[_questionIndex][msg.sender] = true;

        // Increment the vote count for the chosen option.
        q.voteCounts[_optionIndex] += 1;

        // Broadcast the vote so the frontend can update results live.
        emit VoteCast(
            msg.sender,
            _questionIndex,
            _optionIndex,
            q.options[_optionIndex],
            q.voteCounts[_optionIndex]
        );
    }

    // ══════════════════════════════════════════════════════════════
    //  WINNER & RESULTS — Read-only, free to call (no gas cost)
    // ══════════════════════════════════════════════════════════════

    /*
        getWinner()
        Returns the winner and a full ranking sorted highest to lowest.

        IMPORTANT: Only callable after voting has ended.
        Voting ends when:
          - The question is hidden, OR
          - The deadline has passed (if one was set)

        Returns:
        - winnerName   : The option name with the most votes
        - winnerVotes  : How many votes the winner received
        - rankedNames  : ALL options sorted from most to fewest votes
        - rankedVotes  : Corresponding vote counts in the same order
    */
    function getWinner(uint256 _questionIndex)
        external
        view
        validQuestion(_questionIndex)
        returns (
            string memory winnerName,
            uint256 winnerVotes,
            string[] memory rankedNames,
            uint256[] memory rankedVotes
        )
    {
        Question storage q = questions[_questionIndex];

        // getWinner is only available after voting has closed.
        require(_isVotingEnded(q), "Voting has not ended yet");

        uint256 n = q.options.length;

        // Create memory copies of options and counts for sorting.
        // We sort copies so the original on-chain data stays untouched.
        rankedNames = new string[](n);
        rankedVotes = new uint256[](n);

        for (uint256 i = 0; i < n; i++) {
            rankedNames[i] = q.options[i];
            rankedVotes[i] = q.voteCounts[i];
        }

        // Selection sort: arrange from highest votes to lowest.
        // Simple and gas-efficient for small option counts (2–10 options).
        for (uint256 i = 0; i < n; i++) {
            uint256 maxIdx = i;
            for (uint256 j = i + 1; j < n; j++) {
                if (rankedVotes[j] > rankedVotes[maxIdx]) {
                    maxIdx = j;
                }
            }
            // Swap if we found a higher value later in the array.
            if (maxIdx != i) {
                (rankedVotes[i], rankedVotes[maxIdx]) = (rankedVotes[maxIdx], rankedVotes[i]);
                (rankedNames[i], rankedNames[maxIdx]) = (rankedNames[maxIdx], rankedNames[i]);
            }
        }

        // The first element after sorting is the winner.
        winnerName = rankedNames[0];
        winnerVotes = rankedVotes[0];
    }

    /*
        getResults()
        Returns live vote counts for any question at any time.
        Unlike getWinner(), this works even while voting is still open.
    */
    function getResults(uint256 _questionIndex)
        external
        view
        validQuestion(_questionIndex)
        returns (string[] memory options, uint256[] memory voteCounts)
    {
        Question storage q = questions[_questionIndex];
        uint256 n = q.options.length;

        // Build memory copies to return.
        options = new string[](n);
        voteCounts = new uint256[](n);

        for (uint256 i = 0; i < n; i++) {
            options[i] = q.options[i];
            voteCounts[i] = q.voteCounts[i];
        }
    }

    // ══════════════════════════════════════════════════════════════
    //  HELPER VIEW FUNCTIONS — Used by the frontend (all free)
    // ══════════════════════════════════════════════════════════════

    /*
        getQuestion()
        Returns all metadata for a single question in one call.
        Saves the frontend from making multiple separate requests.
    */
    function getQuestion(uint256 _questionIndex)
        external
        view
        validQuestion(_questionIndex)
        returns (
            string memory text,
            QuestionType questionType,
            string[] memory options,
            uint256[] memory voteCounts,
            bool isHidden,
            uint256 deadline
        )
    {
        Question storage q = questions[_questionIndex];
        uint256 n = q.options.length;

        // Copy dynamic arrays into memory for the return.
        string[] memory opts = new string[](n);
        uint256[] memory votes = new uint256[](n);
        for (uint256 i = 0; i < n; i++) {
            opts[i] = q.options[i];
            votes[i] = q.voteCounts[i];
        }

        return (q.text, q.questionType, opts, votes, q.isHidden, q.deadline);
    }

    // Returns the total number of questions (including hidden ones).
    function getQuestionCount() external view returns (uint256) {
        return questions.length;
    }

    // Returns true if voting is still open for a question, false if ended.
    function isVotingOpen(uint256 _questionIndex)
        external
        view
        validQuestion(_questionIndex)
        returns (bool)
    {
        return !_isVotingEnded(questions[_questionIndex]);
    }

    // Lets a frontend check if a specific wallet has already voted.
    function checkIfVoted(uint256 _questionIndex, address _voter)
        external
        view
        validQuestion(_questionIndex)
        returns (bool)
    {
        return hasVoted[_questionIndex][_voter];
    }

    // Returns indices of all questions where voting is still open.
    // The frontend calls this to know which questions to display.
    function getActiveQuestions() external view returns (uint256[] memory) {
        // First pass: count how many are active.
        uint256 activeCount = 0;
        for (uint256 i = 0; i < questions.length; i++) {
            if (!_isVotingEnded(questions[i])) {
                activeCount++;
            }
        }

        // Second pass: fill an array with their indices.
        uint256[] memory activeIndices = new uint256[](activeCount);
        uint256 current = 0;
        for (uint256 i = 0; i < questions.length; i++) {
            if (!_isVotingEnded(questions[i])) {
                activeIndices[current] = i;
                current++;
            }
        }

        return activeIndices;
    }

    // ══════════════════════════════════════════════════════════════
    //  INTERNAL HELPER — Used by other functions, not callable externally
    // ══════════════════════════════════════════════════════════════

    // Determines if voting has ended for a question.
    // Voting ends if the question is hidden OR its deadline has passed.
    function _isVotingEnded(Question storage q) internal view returns (bool) {
        // Hidden questions are always considered ended.
        if (q.isHidden) return true;

        // If a deadline was set and the current time has passed it, voting is over.
        if (q.deadline != 0 && block.timestamp > q.deadline) return true;

        // Otherwise, voting is still open.
        return false;
    }
}