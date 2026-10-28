# SENTENCE

**Current application and release: 2.1.25 · Windows x64**

SENTENCE is a Tauri desktop scripting workspace with a Luau editor, Sentence Guide, SENCHAN, Script Hub and Instance Explorer.

## Download

- [SENTENCE 2.1.25 release](https://github.com/DareQPlaysRBX/Sentence-INT/releases/tag/v2.1.25)
- [Release.zip](https://github.com/DareQPlaysRBX/Sentence-INT/releases/download/v2.1.25/Release.zip)
- [Matching Runtime.zip](https://github.com/DareQPlaysRBX/Sentence-INT/releases/download/v2.1.25/Runtime.zip)
- [SHA-256 checksums](https://github.com/DareQPlaysRBX/Sentence-INT/releases/download/v2.1.25/SHA256SUMS.txt)
- [SENInstaller](https://gitlab.com/dareqplays/Sentence-INT/-/blob/main/SENInstaller.exe)

Release.zip and Runtime.zip are a matched pair for the installer; keep them in the same folder for local package verification. The application contains an embedded runtime. Preserve bin beside SENTENCE.exe. The scripts folder is empty for your own scripts. Public packages contain no personal scripts, project data, AI keys or signing private keys.

Microsoft Edge WebView2 and Microsoft Visual C++ Redistributable may be required. SENCHAN uses your own provider API key; external MCP integration is optional.

## Current changes

- Software Auto Updater with animated update stages at the bottom right of the loading screen, without an outer background or border.
- Priority decompilation of selected Explorer scripts and distinct module update status colors.
- Improved Polish translation and Halloween tab accent.
- The separate SENCHAN Explorer remains removed.

The actual EXE ProductVersion, FileVersion and displayed application version are **2.1.25**, with all current changes retained. Earlier releases remain in release history.

## Automatic updates

The software section of [sentence_update.json](https://github.com/DareQPlaysRBX/Sentence-INT/blob/main/sentence_update.json) points to **2.1.25**. Supported releases download newer Software.zip packages from the exact GitLab commit recorded there, verify size, SHA-256 and executable version, save the project and stage replacement. A separate worker keeps the previous EXE and restarts the application. Personal scripts, settings and modules are preserved.

**Installations with versions above 2.1.25 require manual installation of this release; the updater does not downgrade.** Older releases without the updater also require manual installation. Application and module updates are separate. Developer and headless builds do not update automatically.

## Test signature

The EXE has a self-signed Authenticode test signature: **CN=Yume Bytes Community**. It is not trusted by Windows and does not establish verified publisher status or SmartScreen reputation. No certificate was installed in Trusted Root. Only the public certificate is included; the private key is not exported.

## Publication workflow

Publish matching Release.zip, Runtime.zip and Software.zip to GitLab main, verify all three at one commit using Prepare-GitLabRelease.ps1, and publish the generated sentence_update.json on GitHub. Publish the same packages and checksums in the matching GitHub Release. Preserve unrelated manifest fields.

Made by **DareQPlays** | **Yume Bytes Community**
