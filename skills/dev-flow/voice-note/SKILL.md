---
name: voice-note
description: "Transcribe a local voice note (a WhatsApp .ogg or similar) with local Whisper, write the transcript next to the audio, then anonymize it by hand. Use when a MIP, an issue or a task needs the words of a voice note."
---

# voice-note

Transcribe one local audio file with a local Whisper backend. No network call, no upload, no
external speech service. The skill does one thing: speech to text in the source language.

## Run it

```bash
python3 scripts/transcribe.py <audio> [--model small] [--language pt]
python3 scripts/transcribe.py --self-test
```

The path is relative to this skill folder.

- It tries `faster_whisper` first, then `whisper`. With neither, it stops with exit code 2 and
  an install hint.
- `--model small` is the default. Use `medium` or `large` only when `small` gets names or numbers
  wrong.
- Always set `--language`. Automatic detection often fails on a short, noisy note.
- The output is `<audio>.txt` next to the audio. The script prints only that path.

Install a backend in the project's own environment, not globally: `pip install faster-whisper`.

## After the transcript

1. **Read it.** Correct the words that Whisper heard wrong.
2. **Anonymize it by hand.** Replace each name, except the owner's, with a neutral word such as
   "a collaborator". A script cannot tell a name from a common word. Do it by reading.
3. **Translate it yourself** if necessary, as a second step. Do not use Whisper's translate mode.
   It hides which error occurred: a word heard wrong, or a word translated wrong.
4. Then use the text: a `triage` draft, a `mip`, or a note.

## Never

- **Never commit the audio.** A voice note is personal data. Keep it outside the work tree, or
  ignored by git. Delete it when the transcript is correct.
- Never commit a transcript before it is anonymized.
- Never turn a voice note into a merged feature in one pass. A voice note starts a design. It
  does not replace the review of a MIP.
