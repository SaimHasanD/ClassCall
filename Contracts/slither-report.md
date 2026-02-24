**THIS CHECKLIST IS NOT COMPLETE**. Use `--show-ignored-findings` to show all the results.
Summary
 - [timestamp](#timestamp) (5 results) (Low)
 - [solc-version](#solc-version) (1 results) (Informational)
 - [naming-convention](#naming-convention) (13 results) (Informational)
 - [cache-array-length](#cache-array-length) (2 results) (Optimization)
## timestamp
Impact: Low
Confidence: Medium
 - [ ] ID-0
[ClassCall.getWinner(uint256)](ClassVote.sol#L275-L322) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(_isVotingEnded(q),Voting has not ended yet)](ClassVote.sol#L289)

ClassVote.sol#L275-L322


 - [ ] ID-1
[ClassCall.getActiveQuestions()](ClassVote.sol#L411-L431) uses timestamp for comparisons
	Dangerous comparisons:
	- [i < questions.length](ClassVote.sol#L414)
	- [i_scope_0 < questions.length](ClassVote.sol#L423)

ClassVote.sol#L411-L431


 - [ ] ID-2
[ClassCall.hideQuestion(uint256)](ClassVote.sol#L184-L199) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(! q.isHidden,Question is already hidden)](ClassVote.sol#L192)

ClassVote.sol#L184-L199


 - [ ] ID-3
[ClassCall._isVotingEnded(ClassCall.Question)](ClassVote.sol#L439-L448) uses timestamp for comparisons
	Dangerous comparisons:
	- [q.deadline != 0 && block.timestamp > q.deadline](ClassVote.sol#L444)

ClassVote.sol#L439-L448


 - [ ] ID-4
[ClassCall.castVote(uint256,uint256)](ClassVote.sol#L215-L254) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(! q.isHidden,This question is no longer active)](ClassVote.sol#L223)
	- [require(bool,string)(block.timestamp <= q.deadline,Voting deadline has passed)](ClassVote.sol#L228)
	- [require(bool,string)(_optionIndex < q.options.length,Invalid option index)](ClassVote.sol#L238)

ClassVote.sol#L215-L254


## solc-version
Impact: Informational
Confidence: High
 - [ ] ID-5
Version constraint ^0.8.19 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
	- VerbatimInvalidDeduplication
	- FullInlinerNonExpressionSplitArgumentEvaluationOrder
	- MissingSideEffectsOnSelectorAccess.
It is used by:
	- [^0.8.19](ClassVote.sol#L4)

ClassVote.sol#L4


## naming-convention
Impact: Informational
Confidence: High
 - [ ] ID-6
Parameter [ClassCall.castVote(uint256,uint256)._questionIndex](ClassVote.sol#L215) is not in mixedCase

ClassVote.sol#L215


 - [ ] ID-7
Parameter [ClassCall.addQuestion(ClassCall.QuestionType,string,string[],uint256)._text](ClassVote.sol#L123) is not in mixedCase

ClassVote.sol#L123


 - [ ] ID-8
Parameter [ClassCall.checkIfVoted(uint256,address)._voter](ClassVote.sol#L400) is not in mixedCase

ClassVote.sol#L400


 - [ ] ID-9
Parameter [ClassCall.addQuestion(ClassCall.QuestionType,string,string[],uint256)._durationSeconds](ClassVote.sol#L125) is not in mixedCase

ClassVote.sol#L125


 - [ ] ID-10
Parameter [ClassCall.addQuestion(ClassCall.QuestionType,string,string[],uint256)._questionType](ClassVote.sol#L122) is not in mixedCase

ClassVote.sol#L122


 - [ ] ID-11
Parameter [ClassCall.castVote(uint256,uint256)._optionIndex](ClassVote.sol#L215) is not in mixedCase

ClassVote.sol#L215


 - [ ] ID-12
Parameter [ClassCall.isVotingOpen(uint256)._questionIndex](ClassVote.sol#L390) is not in mixedCase

ClassVote.sol#L390


 - [ ] ID-13
Parameter [ClassCall.getWinner(uint256)._questionIndex](ClassVote.sol#L275) is not in mixedCase

ClassVote.sol#L275


 - [ ] ID-14
Parameter [ClassCall.getResults(uint256)._questionIndex](ClassVote.sol#L329) is not in mixedCase

ClassVote.sol#L329


 - [ ] ID-15
Parameter [ClassCall.hideQuestion(uint256)._questionIndex](ClassVote.sol#L184) is not in mixedCase

ClassVote.sol#L184


 - [ ] ID-16
Parameter [ClassCall.checkIfVoted(uint256,address)._questionIndex](ClassVote.sol#L400) is not in mixedCase

ClassVote.sol#L400


 - [ ] ID-17
Parameter [ClassCall.addQuestion(ClassCall.QuestionType,string,string[],uint256)._options](ClassVote.sol#L124) is not in mixedCase

ClassVote.sol#L124


 - [ ] ID-18
Parameter [ClassCall.getQuestion(uint256)._questionIndex](ClassVote.sol#L357) is not in mixedCase

ClassVote.sol#L357


## cache-array-length
Impact: Optimization
Confidence: High
 - [ ] ID-19
Loop condition [i < questions.length](ClassVote.sol#L414) should use cached array length instead of referencing `length` member of the storage array.
 
ClassVote.sol#L414


 - [ ] ID-20
Loop condition [i_scope_0 < questions.length](ClassVote.sol#L423) should use cached array length instead of referencing `length` member of the storage array.
 
ClassVote.sol#L423


