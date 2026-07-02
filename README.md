# ReMastera macOS Media Processing Suite

ReMastera is a native macOS application for local, private, and offline video remastering. It restores and refines old or low-quality videos into modern, clean, and cinematic masters while maintaining efficient output file sizes.

## The ReMastera Privacy Promise

ReMastera is designed on a local-first architecture. It guarantees:

- Zero Telemetry and Analytics: The application does not collect usage metrics, crash reports, or click analysis.
- Zero Cloud Uploads: All video and audio processing is executed locally on your Mac. No files leave your machine.
- No Silent background downloads: Software dependencies and model configurations are never downloaded in the background without explicit user permission.
- Completely Offline: Once dependencies are configured, the app operates without requiring an internet connection.

## System Requirements

- Operating System: macOS 15.0 (Sequoia) or newer.
- Hardware: Apple Silicon (M1, M2, M3, M4, or newer) is highly recommended for hardware-accelerated HEVC 10-bit VideoToolbox encoding.
- Package Manager: Homebrew is required for automatic dependency installation.

## Feature Overview

### Currently Implemented (MVP)

- Ingestion Zone: Drag and drop files or directories recursively scanning for `mp4`, `mov`, `mkv`, `avi`, `m4v`, and `webm` extensions.
- Processing Presets: Segmented profiles (Fast Preview, Compact 4K, Balanced 4K, Archival 4K, and Original Resolution Enhanced) with pre-set video and audio bitrates.
- Size Estimator: Live byte output estimation based on selected preset parameters and clip duration.
- Folder Mirroring: Recreates input subdirectory structures inside output directories during batch processing.
- Overwrite Configurations: Automatically creates numbered copies (e.g., `Clip 2.mp4`) to prevent accidental data loss.
- Denoise Stage: Applies the high-quality 3D denoiser filter (hqdn3d) to clean up sensor noise and film grain.
- Cinematic Color: Applies a Kodak 5247-inspired color balance and contrast grading curve.
- Standard Upscaling: Rescales video outputs to 4K resolution (3840x2160) using Lanczos interpolation.
- HDR10 Container Tagging: Integrates Rec.2020 color primaries and PQ transfer characteristics (smpte2084) for high dynamic range playback.
- Subtitle Stage: Detects and executes subtitle extractions using local `whisper-cli` tooling.
- Active Queue Manager: Lists pending, processing, completed, and failed tasks with custom console logs and retry actions.

### Planned for Future Release

- Core ML Real-ESRGAN: True neural resolution enhancement using Apple Silicon Neural Engine accelerators.
- WhisperKit: Swift-native subtitle extraction directly inside the app process.
- RIFE Frame Interpolation: Smooth local frame rate conversions (e.g., up to 60 fps).
- Dolby Vision RPU Injector: Integrates `dovi_tool` command line workflows for parsing and merging dynamic HDR metadata.
- Multichannel Audio Passthrough: Advanced mapping of ADM/BWF tracks.
- Local voice conversion: Offline text-to-speech and translation dubbing tools.

## Installation and Setup

### 1. Bootstrap Setup

To install missing dependencies and verify system compatibility, run the interactive bootstrap utility in your terminal:

```bash
./scripts/bootstrap.sh
```

### 2. Manual Dependency Configuration

Install required multimedia binaries using Homebrew:

```bash
# Required tools
brew install ffmpeg

# Optional tools
brew install whisper-cpp realesrgan-ncnn-vulkan rife-ncnn-vulkan dovi_tool
```

Verify your dependency status by running:

```bash
./scripts/check-dependencies.sh
```

## Running and Building from Source

### Run Directly

To compile and launch the application directly from your terminal using Swift Package Manager, execute:

```bash
swift run ReMastera
```

### Compile Release Binary

To build the release version, run:

```bash
./scripts/build.sh
```

The executable is compiled under `.build/release/ReMastera`.

### Run Automated Tests

ReMastera contains a unit test suite executing path mirroring, size estimation, tag sorting, and preset calculations. Run the tests using:

```bash
./scripts/test.sh
```

### Package the App Bundle

To package the release binary as a standard macOS application bundle and generate a distributable zip archive, run:

```bash
./scripts/package.sh
```

The output bundle is generated at `build/ReMastera.app`, and the distribution zip lands at `build/Dist/ReMastera-macOS.zip`.

## Advanced Workflow Clarification

- Real AI Enhancement: ReMastera does not fake AI features. If a neural model is not active on your Mac, the upscale process is clearly labeled as "Standard Upscale" rather than "AI Upscale."
- Dolby Vision / Dolby Atmos: True Dolby Vision and Dolby Atmos creation requires licensed tools. ReMastera provides "HDR10-compatible" container mapping and "spatial audio passthrough" instead. Advanced Dolby metadata injection hooks are provided for users who manually configure local licensed toolchains.
- Voice Cloning and Dubbing: These options are structured as future plugin hooks. A warning consent banner is shown to users before executing these tools to respect copyright boundaries.

## Known Limitations

- Processing Speed: Performance is highly dependent on your hardware profile. Apple Silicon Macs with active hardware decoders deliver significantly faster render times.
- Sandboxing: Standard sandboxing restrictions require explicit user permission to read or write files outside default system movie directories.

## Visual Design Presentation

### Application Layout

A placeholder path for screenshots is set below:
- Design/screenshots/dashboard_mockup.png

### Processing Animation

A placeholder path for demo GIFs is set below:
- Design/demo/render_progress.gif
