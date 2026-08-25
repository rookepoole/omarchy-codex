# Core graphical workflow check

This is the final physical-machine check. It tests the graphical application, not Codex CLI.

1. Open **Codex** with `Super + Shift + A` and complete **Continue with ChatGPT** in the browser.
2. Fully quit and reopen Codex. Confirm the same ChatGPT account is still signed in.
3. Select **Work** mode. From a terminal opened inside any disposable Git repository, run `chatgpt .`.
4. Confirm the graphical app opens that repository. Ask it to read a harmless file, then create one disposable proof file.
5. Fully quit and reopen Codex. Confirm the task remains visible and the proof file remains in the repository.
6. Run `omarchy-codex doctor`. It must report the graphical app and libraries as passing, with no Hyprland configuration errors.

Delete only the disposable proof file when finished. The package never needs an API key for this workflow.
