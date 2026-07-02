# System Requirements

This document outlines the software versions and hardware specifications required to run, build, and test the ReMastera macOS application.

## Operating System

- macOS 14.0 (Sonoma) or newer.
- Apple Silicon (M1, M2, M3, M4, or newer) is highly recommended for hardware-accelerated HEVC 10-bit encoding.

## Developer Tooling

- Xcode 15.0 or newer (or Xcode Command Line Tools containing the Swift 6.0 driver or newer).
- Swift 6.0 compiler or newer.
- XcodeGen utility (version 2.45.0 or newer) for optional Xcode project file generation.

## CLI Dependencies

ReMastera uses safe Process execution to wrap command line utilities. The following tools must be installed and accessible via PATH or Homebrew:

### Required Tooling

- **ffmpeg** (version 6.0 or newer): Required for video stream decoding, subtitle muxing, video filter applications, and hardware-accelerated HEVC encoding.
- **ffprobe**: Required for scanning stream metadata, duration metrics, and video properties.

### Optional Tooling

These tools are not required for core operations but unlock advanced enhancement features when detected:

- **whisper-cli** (via whisper-cpp): Unlocks local, offline subtitle extraction from video audio tracks.
- **realesrgan-ncnn-vulkan**: Unlocks local AI resolution upscaling plugins.
- **rife-ncnn-vulkan**: Unlocks local AI video frame interpolation plugins.
- **dovi_tool**: Unlocks parsing and injection hooks for Dolby Vision RPU metadata.
