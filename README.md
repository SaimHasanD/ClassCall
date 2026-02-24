# 🗳️ ClassCall

**Live blockchain voting for classrooms — every vote recorded permanently on-chain.**

ClassCall lets an instructor create live polls during a lecture and lets every student in the room vote from their phone in real time. Results update instantly across all connected devices. No backend server, no database — just a smart contract on Base and a single-page frontend.

---

## ✨ Features

- **Yes / No Polls** — Create simple binary questions with one click
- **Multi-Choice Polls** — Add as many options as you need
- **Real-Time Sync** — Vote counts and progress bars update live across every connected browser via on-chain events
- **Countdown Timers** — Set a duration so polls close automatically when time runs out
- **Winner Reveal** — Ended polls show ranked results with a trophy badge and confetti
- **One Vote Per Wallet** — The smart contract enforces one vote per address per question
- **Owner Controls** — Only the deployer wallet can create and end polls
- **On-Chain Transparency** — Every vote is a transaction anyone can verify on Basescan
- **Mobile Friendly** — Students scan a QR code and vote from their phones

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Smart Contract | Solidity 0.8.19 |
| Blockchain | Base Sepolia (EVM) |
| Frontend | Vanilla HTML / CSS / JavaScript |
| Web3 Library | Ethers.js v5 |
| Wallet | MetaMask |
| Hosting | Vercel |

---

## 🚀 Live Demo

👉 **[class-call.vercel.app](https://class-call.vercel.app/)**

> You need MetaMask installed and connected to the **Base Sepolia** testnet with a small amount of test ETH to interact with the app.

---

## 📦 Installation

Clone the repository and open the file — no build step required.

```bash
git clone https://github.com/yourusername/classcall.git
cd classcall
```

Open `index.html` in any modern browser with MetaMask installed.

If you want to deploy your own instance with your own contract:

1. Open `index.html` in a text editor
2. Find the configuration block near the top of the `<script>` section
3. Replace the contract address with your own deployed address

```javascript
const CFG = Object.freeze({
    addr: "YOUR_CONTRACT_ADDRESS_HERE",  // ← paste your address
    chain: 84532,
    hex: "0x14a34",
    name: "Base Sepolia",
    rpc: "https://sepolia.base.org",
    scan: "https://sepolia.basescan.org",
});
```

4. Save and open in browser

---

## 💡 Usage

### As the Owner (instructor)

1. Open the app and connect with the wallet that deployed the contract
2. The **Owner Control Panel** appears at the top
3. Create a Yes/No or Multi-Choice question with an optional timer
4. Share the QR code or URL with your audience
5. Click **End Voting** on any poll to close it and reveal the winner

### As a Voter (student)

1. Scan the QR code or open the link
2. Connect MetaMask on the Base Sepolia network
3. Tap an option to vote — your vote is confirmed on-chain in seconds
4. Watch results update in real time as others vote

---

## 📁 Project Structure
