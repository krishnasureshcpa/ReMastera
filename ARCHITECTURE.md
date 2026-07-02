# Architecture Documentation

ReMastera is structured with a modular, local-first architecture separating the SwiftUI user interface from the underlying media processing utilities.

## Core Architecture Pattern

```
ReMastera macOS Application (SwiftUI / AppKit)
  │
  ├── State Management (QueueManager @Observable)
  │     └── Job List [Job 1, Job 2, ...]
  │
  └── Orchestration Engine (Pipeline Class)
        └── PipelineContext
              ├── Video Filters [Filter 1, Filter 2, ...]
              ├── Audio Filters
              └── PipelineStages (Conforming to PipelineStage protocol)
                    ├── DenoiseStage (hqdn3d)
                    ├── FilmLookStage (colorbalance / eq)
                    ├── SubtitleStage (whisper-cli)
                    └── EncodeStage (ffmpeg process wrapper)
```

## Modular Pipeline and Context

Processing tasks follow a structured pipeline governed by the `PipelineStage` protocol:

```swift
public protocol PipelineStage {
    var id: String { get }
    var displayName: String { get }
    func run(context: PipelineContext) async throws
}
```

The pipeline context (`PipelineContext`) acts as a shared, thread-safe memory workspace during the execution of a job. It collects video filters, audio filters, and command line arguments from each stage sequentially. 

## Single-Pass Encoding Design

To avoid creating heavy intermediate files (like raw PNG/TIFF frames or uncompressed MOV files), ReMastera implements a single-pass encoding strategy. 

1. Individual stages (Denoise, Film Look, Upscale) do not execute FFmpeg processes independently. They append their specific filter parameters to the `videoFilters` list in the context.
2. The final `EncodeStage` compiles the complete list of video filters into a single comma-separated filter chain (e.g. `-vf "hqdn3d=1.5:1.5:6:6,colorbalance=...,scale=3840:2160"`).
3. FFmpeg executes once, performing decoding, filtering, scaling, and hardware-accelerated HEVC encoding in a single pass. This minimizes disk writes and increases processing performance on Apple Silicon.

## Safe Process Wrapper

All external tool execution is managed by the `ExternalToolRunner` class. This wrapper uses the Foundation `Process` API to execute binaries safely:

- User-controlled paths and arguments are passed as an array of arguments, not through `/bin/sh`. This prevents shell injection vulnerabilities.
- File paths with spaces are handled natively by the operating system, without requiring manual shell escaping.
- The standard output and standard error streams are read asynchronously using system pipe file handles, which avoids memory exhaustion or buffer overflows during long operations.
- Task cancellation is monitored. If a user cancels a job, the active process is terminated immediately.

## Future AI Backend Hooks

ReMastera structures advanced AI capabilities (such as Real-ESRGAN upscaling or Whisper subtitle translations) as pluggable stages. The pipeline context is designed to support the registration of future local machine learning frameworks:

- The model downloader targets local storage under `~/Library/Application Support/ReMastera/Models/`.
- Deep learning processing is directed to Core ML, Metal Performance Shaders (MPS), or MLX frameworks for execution on the local Apple Silicon neural engine.
