# SENTENCE

**Current application and release: 2.1.25 · Windows x64**

SENTENCE is a Tauri desktop scripting workspace with a Luau editor, Sentence Guide, SENCHAN, Script Hub and Instance Explorer.

## Download

- [SENTENCE 2.1.25 release](https://github.com/DareQPlaysRBX/Sentence-INT/releases/tag/v2.1.25)
- [Release.zip](https://github.com/DareQPlaysRBX/Sentence-INT/releases/download/v2.1.25/SENTENCE-2.1.25-optimized-Release.zip)
- [Matching Runtime.zip](https://github.com/DareQPlaysRBX/Sentence-INT/releases/download/v2.1.25/SENTENCE-2.1.25-optimized-Runtime.zip)
- [SHA-256 checksums](https://github.com/DareQPlaysRBX/Sentence-INT/releases/download/v2.1.25/SENTENCE-2.1.25-optimized-SHA256SUMS.txt)
- [SENInstaller](https://gitlab.com/dareqplays/Sentence-INT/-/blob/main/SENInstaller.exe)

Release.zip and Runtime.zip are a matched pair for the installer; keep them in the same folder for local package verification. The application contains an embedded runtime. Preserve bin beside SENTENCE.exe. The scripts folder is empty for your own scripts. Public packages contain no personal scripts, project data, AI keys or signing private keys.

Microsoft Edge WebView2 and Microsoft Visual C++ Redistributable may be required. SENCHAN uses your own provider API key; external MCP integration is optional.

## Current changes

- Added a new **Software Auto-Updater** (SENTENCE will now automatically check for and install updates on startup).
- Made minor color adjustments to the **Halloween 2026 Theme**.
- Scripts selected in **Instance Explorer** will now be prioritized for decompilation.
- Various minor bug fixes and improvements.

The Find game scripts suggestion has been removed from SENCHAN. This optimized revision adds reusable Explorer name comparison, memoized source byte counts, reusable translation rules and non-overlapping status polling; unused legacy files were removed. Current build: **optimized-20261028**, version **2.1.25**. Download the assets prefixed SENTENCE-2.1.25-optimized-. Rename the Release and Runtime files to Release.zip and Runtime.zip for local installer verification. Earlier assets are preserved as previous builds.

## Automatic updates

The software section of [sentence_update.json](https://github.com/DareQPlaysRBX/Sentence-INT/blob/main/sentence_update.json) points to **2.1.25**. Supported releases download newer Software.zip packages from the exact GitLab commit recorded there, verify size, SHA-256 and executable version, save the project and stage replacement. A separate worker keeps the previous EXE and restarts the application. Personal scripts, settings and modules are preserved.

**Installations already on 2.1.25 or above require manual installation of this refreshed build; the updater only installs higher version numbers.** Older releases without the updater also require manual installation. Application and module updates are separate. Developer and headless builds do not update automatically.

## Test signature

The EXE has a self-signed Authenticode test signature: **CN=Yume Bytes Community**. It is not trusted by Windows and does not establish verified publisher status or SmartScreen reputation. No certificate was installed in Trusted Root. Only the public certificate is included; the private key is not exported.

## Publication workflow

Publish matching Release.zip, Runtime.zip and Software.zip to GitLab main, verify all three at one commit using Prepare-GitLabRelease.ps1, and publish the generated sentence_update.json on GitHub. Publish the same packages and checksums in the matching GitHub Release. Preserve unrelated manifest fields.

Made by **DareQPlays** | **Yume Bytes Community**
