# SENTENCE

**THE MOST RELIABLE AND FLEXIBLE EXECUTOR IDE**

SENTENCE is a Windows scripting workspace built with Tauri, with a Luau editor, Sentence Guide, SENCHAN AI assistance, Script Hub and Instance Explorer.

**Portable download: 2.1.26 · Automatic update channel: 2.1.27 · Windows x64**

## Download and start

- [Download SENTENCE 2.1.26 for Windows x64](https://github.com/DareQPlaysRBX/Sentence-INT/releases/download/v2.1.26/SENTENCE-2.1.26-win-x64.zip)
- [Release notes and SHA-256 checksums](https://github.com/DareQPlaysRBX/Sentence-INT/releases/tag/v2.1.26)
- [Latest published release](https://github.com/DareQPlaysRBX/Sentence-INT/releases/latest)

Extract the complete ZIP and run SENTENCE.exe. Keep bin, binaries and scripts beside the executable. Put your own scripts in scripts. The public package contains no personal scripts, project data or AI keys.

SENTENCE includes an embedded runtime and a Software Auto Updater. Microsoft Edge WebView2 and Microsoft Visual C++ Redistributable may be required by the interface and native components. SENCHAN uses your own provider API key; external MCP integration is optional.

## Automatic application updates

The software update channel now offers **2.1.27**. Start SENTENCE 2.1.26 to receive it automatically. The GitHub Release 2.1.26 remains the bootstrap download.

At startup, supported releases check the `software` section of [sentence_update.json](https://github.com/DareQPlaysRBX/Sentence-INT/blob/main/sentence_update.json). A newer compatible Software.zip is downloaded from the exact GitLab commit recorded there, checked by SHA-256 and executable version, and staged before installation.

The project must save successfully before SENTENCE exits. A separate worker replaces the application EXE, keeps its predecessor and restarts the application. Download or validation errors preserve the installed version. A replacement or launch failure retains/restores the previous EXE. Personal scripts, settings and module files are not overwritten by the application updater.

Older releases without this updater need one manual installation of the current portable package. Application updates are separate from Xeno/Velocity module updates. Developer and headless builds do not update automatically.

## Publication workflow

1. Build a higher application version with its embedded runtime. Prepare the full portable ZIP for GitHub Releases, and Software.zip containing only SENTENCE.exe and software-release.json.
2. Publish the full portable ZIP, Software.zip and checksums in the matching GitHub Release.
3. Commit Software.zip to GitLab dareqplays/Sentence-INT on main.
4. Run Prepare-SoftwareUpdate.ps1 against that Software.zip. It verifies the published archive and generates the software entry with the exact GitLab commit, size, SHA-256 and application hash.
5. Publish the merged sentence_update.json on GitHub main. Only then is that newer version offered by the updater.

The original WPF/installer fields in the shared manifest are preserved for compatibility; they do not identify the current Software Auto Updater release. Legacy SENInstaller, Debug.zip, Release.zip and Runtime.zip remain separate downloads. Use the GitHub Release linked above for SENTENCE 2.1.26.

Made by **DareQPlays** | **Yume Bytes Community**
