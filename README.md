# SENTENCE

**THE MOST RELIABLE AND FLEXIBLE EXECUTOR IDE**

SENTENCE is a Windows scripting workspace built with Tauri, with a Luau editor, Sentence Guide, SENCHAN AI assistance, Script Hub and Instance Explorer.

**Application:** 2.6.13 · **SENInstaller:** 2.6.18

## Downloads

- [Download SENInstaller.exe](https://gitlab.com/dareqplays/Sentence-INT/-/raw/main/SENInstaller.exe) — online installer and version checker.
- [Download the portable ZIP](https://gitlab.com/dareqplays/Sentence-INT/-/raw/main/Debug.zip) — complete application with its required runtime folders and an empty scripts folder.

## Installation

1. Download and run SENInstaller.exe.
2. Choose a destination, language and shortcut preferences. New installations default to SentenceIDE on your desktop; detected installations retain their existing location.
3. Read and accept the terms and project notices, then review the installation details.
4. Confirm installation. The installer downloads the ZIP from GitLab, verifies it against its Git commit and installs the application.

An internet connection is required. The installer checks the application version online and does not contain an offline application package. Keep bin, binaries and sentence-guide-mcp.exe beside SENTENCE.exe when using the portable ZIP. Put your own scripts in the scripts folder.

AI chat uses your own provider API key. MCP integration is optional and configured from SENTENCE settings.

## Update channel

[View sentence_update.json](https://raw.githubusercontent.com/DareQPlaysRBX/Sentence-INT/main/sentence_update.json)

GitHub hosts the update information. GitLab hosts Debug.zip and SENInstaller.exe. No GitHub Release or individual BIN upload is required.

The tauri section of sentence_update.json describes the current Tauri release, including version, download_url, file_size, commit_sha, gitlab_project and file_path. The installer downloads the archive from the exact GitLab commit specified in this section, rather than trusting a moving branch.

The original root fields are retained for legacy WPF clients. Do not replace those fields with the ZIP URL while older WPF clients still use this feed.

## Publishing a new application version

1. Build a clean portable release and upload it to GitLab main as Debug.zip, including all required dependencies.
2. Obtain the GitLab commit for that archive and update the tauri fields in sentence_update.json on GitHub main. The supplied Prepare-Manifest.ps1 script can verify the uploaded ZIP and generate the merged JSON automatically.
3. Publish a new SENInstaller.exe on GitLab when the installer itself changes. Its application download version is read from the online manifest.

Updating an existing installation preserves personal scripts and AppData settings. The normal update check compares versions; it does not audit every installed file.

Made by **DareQPlays** | **Yume Bytes Community**
