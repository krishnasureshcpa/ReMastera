# ReMastera
## Native macOS Media Processing Suite

[![Release](https://img.shields.io/github/v/release/krishnasureshcpa/ReMastera?style=flat-square&color=E63946&logo=apple)](https://github.com/krishnasureshcpa/ReMastera/releases)
[![Swift 6.0](https://img.shields.io/badge/Swift-6.0-F05138.svg?style=flat-square&logo=swift)](https://swift.org)
[![macOS 15.0+](https://img.shields.io/badge/macOS-15.0%2B-000000.svg?style=flat-square&logo=apple)](https://developer.apple.com/macos)
[![Build Status](https://img.shields.io/github/actions/workflow/status/krishnasureshcpa/ReMastera/ci.yml?style=flat-square&logo=githubactions)](https://github.com/krishnasureshcpa/ReMastera/actions)

ReMastera is a native macOS application for local, private, and offline video remastering. It restores and refines old or low-quality videos into modern, clean, and cinematic masters using hardware-accelerated HEVC 10-bit VideoToolbox encoding.

---

## ✦ Stark Swiss Design & Mascot Character

ReMastera is built with a custom design language inspired by **Swiss International Typographic style + Selective Neumorphism**, moving away from standard matrix terminals or gamified "AI toy" looks:
- **Typography**: stark Bebas Neue for headers, DM Sans for text, and DM Mono for console output.
- **Accents**: bold Swiss Crimson Red (`#E63946`) and deep structural grays with selective dual-shadow neumorphic embossing.
- **Mascot (Remy)**: Features a real local Rive runtime animation file (`remy.riv`) bundled inside the module's resources. Remy responds dynamically to job stages with visual moods (`.working`, `.happy`, `.thinking`, `.talking`, `.idle`).

---

## 1. System Requirements

- **Operating System**: macOS 15.0 (Sequoia) or newer.
- **Hardware**: Apple Silicon (M1, M2, M3, M4, or newer) for hardware-accelerated encoding/decoding.
- **Package Manager**: Homebrew is required for resolving external CLI dependencies.

---

## 2. External Dependencies

ReMastera delegates specialized local processing to verified command-line utilities.

| Dependency | Purpose | Install Command | Required |
|---|---|---|---|
| **FFmpeg** | Video decoding, subtitle merging, and audio mapping | `brew install ffmpeg` | **Yes** |
| **FFprobe** | Video metadata scanning, durations, and formats | `brew install ffmpeg` | **Yes** |
| **Whisper.cpp** | Local speech-to-text subtitle extraction | `brew install whisper-cpp` | No (Optional) |
| **Real-ESRGAN** | Local AI-powered resolution upscaling | `brew install realesrgan-ncnn-vulkan` | No (Optional) |
| **RIFE** | Local AI-powered video frame interpolation | `brew install rife-ncnn-vulkan` | No (Optional) |
| **dovi_tool** | Dolby Vision metadata mapping and extraction | `brew install dovi_tool` | No (Optional) |

> [!NOTE]
> The dependency scanner is designed to search for `whisper-cpp` first (as packaged by default by Homebrew) with automatic fallback detection to `whisper-cli` if custom compiled.

---

## 3. Quick-Start Setup

### Phase A: Bootstrap Onboarding
To inspect configurations, verify Homebrew, install dependencies, and build the application, run the interactive bootstrap:
```bash
./scripts/bootstrap.sh
```

### Phase B: Verification commands
Verify that your dependencies are mapped correctly on your PATH:
```bash
./scripts/check-dependencies.sh
```

---

## 4. Compilation & Verification

### Run Directly
To launch the SwiftUI application window directly using Swift Package Manager:
```bash
swift run ReMastera
```

### Run Tests
To run the automated verification suite (covering tag sorting, size estimations, path builders, and pipeline state changes) on a command-line environment:
```bash
./scripts/test.sh
```

### Package App Bundle & DMG
To compile the release binary, package it into a standalone macOS `.app` bundle, generate a `.dmg` installer volume, and deploy to your Applications folder:
```bash
./scripts/package.sh
```
- Standalone App: `ReMastera.app` (in root directory)
- Installer DMG: `ReMastera.dmg` (in root directory)
- Installed Application: `~/Applications/ReMastera.app`

> [!IMPORTANT]
> The script automatically renames any pre-existing installation at `~/Applications/ReMastera.app` using the format `ReMastera-Mmm-dd-yyyy-hh-mm-am/pm.app` to prevent data loss.

### Mount, Extract & Install Script
To mount the packaged DMG, extract the app bundle, copy it to your global `/Applications/` directory (prompting for permissions if protected), and launch the app:
```bash
./scripts/install-and-run.sh
```

---

## 5. Architecture & Layout Routing

The workspace is organized with strict Swift Package Manager dependency separation:
- `Sources/ReMastera/` — Main SwiftUI application and views (`MainAppView`, `RemyMascot`, `SidebarView`, `DashboardView`).
- `Sources/ReMasteraCore/` — Core processing logic, preset definitions, tag sanitizers, size estimators, and pipeline stages.
- `Sources/ReMasteraCLI/` — Immersive Terminal User Interface (TUI).
- `Sources/ReMasteraTests/` — Assertion executable suite verifying system actions out-of-the-box.
