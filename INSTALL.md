# Installation Guide

Follow these instructions to configure system dependencies, compile ReMastera from source, and build the native macOS application.

## 1. Setup Dependencies

ReMastera relies on local multimedia utilities. You must install them using Homebrew before compiling the application.

### Automatic Bootstrap Setup

Execute the interactive bootstrap onboarding script in your terminal. This script will inspect your system version, check for Xcode Command Line Tools, verify Homebrew, and prompt you to install dependencies:

```bash
./scripts/bootstrap.sh
```

### Manual Dependency Installation

If you prefer to install packages manually, ensure Homebrew is configured and run:

```bash
# Install required tools (ffmpeg and ffprobe)
brew install ffmpeg

# Install optional tools (Whisper, AI Upscaling, HDR metadata tools)
brew install whisper-cpp realesrgan-ncnn-vulkan rife-ncnn-vulkan dovi_tool
```

Verify that all tools are visible in your PATH by executing:

```bash
./scripts/check-dependencies.sh
```

## 2. Compile from Source

ReMastera supports compilation via the Swift Package Manager command-line interface or Xcode project files.

### Option A: Swift Package Manager (Recommended)

To compile the application using Swift Package Manager, run the build script:

```bash
./scripts/build.sh
```

This compiles the release binary. The executable is generated at `.build/release/ReMastera`. You can launch it by running:

```bash
swift run ReMastera
```

### Option B: Xcode Generation

To generate the `.xcodeproj` directory using XcodeGen, run:

```bash
xcodegen generate
```

You can then open the project in Xcode:

```bash
open ReMastera.xcodeproj
```

Compile and run the project by selecting the ReMastera scheme and clicking Product -> Run.

## 3. Run Automated Tests

To verify code correctness, run the test script:

```bash
./scripts/test.sh
```

## 4. Package the Application

To bundle the compiled binary as a standard macOS application package (`ReMastera.app`) and zip it for distribution, run:

```bash
./scripts/package.sh
```

The resulting package will be placed in `build/Dist/ReMastera-macOS.zip`.

## Troubleshooting

- **Error: ffmpeg is not found**: Ensure `/opt/homebrew/bin` is added to your PATH environment variable. You can verify this by running `which ffmpeg` in your terminal.
- **xcode-select error**: If Xcode tools are missing or misconfigured, execute `xcode-select --install` to reset the active CommandLineTools directory.
- **Build fails due to signature requirements**: ReMastera compiles locally with ad-hoc signatures. To distribute outside your machine, follow the code signing steps detailed in the output of `./scripts/package.sh`.
