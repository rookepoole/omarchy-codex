# Security

## Authentication

Omarchy Codex uses the official application's ChatGPT browser sign-in. This project never asks for, stores, prints, or configures an OpenAI API key. It does not read or modify ChatGPT or Codex authentication files.

## Supply chain

OpenAI's application binary is not stored in this repository or release archives. `makepkg` downloads a versioned `.deb` directly from `persistent.oaistatic.com` and verifies its architecture-specific SHA-256 checksum before extracting it.

The optional panel never downloads or executes source. Its update action only opens
the public releases page for review. The installer runs only from the local project
checkout or checksummed release bundle that contains it; it does not pull or clone a
mutable remote branch before invoking privileged package operations.

Report a packaging or installer vulnerability through GitHub's private vulnerability reporting. Report vulnerabilities in the OpenAI application to OpenAI.
