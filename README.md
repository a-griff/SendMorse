![SendMorseCode Logo](SendMorseCode_logo-200px.png)


# SoX Morse Code Generator & Transmitter

A lightweight Bash script that converts any text string—including punctuation, numbers, and custom newlines (`\n`)—into a clean Morse code audio stream using **SoX (Sound eXchange)**. 

Featuring strict ITU 1:3:7 timing and clickless audio envelope shaping for crystal-clear playback.

---

## Features

- **Punctuation & Numbers:** Supports standard letters (A-Z), numbers (0-9), and common punctuation (`.`, `,`, `?`, `/`, `-`, `!`).
- **Custom Newline Escape (`\n`):** Automatically interprets `\n` as the standard Morse code prosign **AA** (`.-.-`).
- **Strict ITU Timing (1:3:7):** Complies with international standards for dot/element space (1u), letter space (3u), and word space (7u).
- **Clickless Audio Envelopes:** Applies a micro 3ms fade-in/fade-out to every dot and dash, completely eliminating the harsh audio "pops" caused by abrupt square-wave transitions.
- **Dynamic Array Assembly:** Builds and plays the sequence on-the-fly using secure temporary directories with automatic cleanup.

---

## Useage


`SendMorseCode.sh "Message to send"`

`SendMorseCode.sh "Message to send\nwith a new line"`


## Prerequisites

You need **SoX** installed on your system to generate and play the audio files.

### Installation

* **Slackware:**
  Using `slackpkg`:
  ```bash
  sudo slackpkg install sox
  
* **Ubuntu / Debian / Mint:**
  ```bash
  sudo apt install sox libsox-fmt-all
