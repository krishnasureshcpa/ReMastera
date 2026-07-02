# Product Roadmap

This document outlines the planned local enhancement features, plugins, and technology integrations for future releases of ReMastera.

## Phase 1: Local AI Integrations

- **Core ML Real-ESRGAN Upscaling**: Integrate native Core ML models for Real-ESRGAN to replace standard Lanczos upscaling with neural enhancement. Processing will run locally on the Apple Silicon Neural Engine.
- **WhisperKit Swift Integration**: Replace the external `whisper-cli` dependency with WhisperKit to perform subtitle extraction directly inside the Swift app process.
- **RIFE Frame Interpolation**: Add a RIFE vulkan/ncnn-based plugin to support local, high-fidelity frame interpolation (e.g. converting 24 fps footage to 60 fps).

## Phase 2: Advanced Media Workflows

- **Dolby Vision RPU Muxing**: Support reading, extracting, and injecting Dolby Vision RPU metadata locally using `dovi_tool` configurations.
- **Spatial Audio / Dolby Atmos Passthrough**: Add a dedicated muxing stage that supports multichannel audio track passthrough and ADM/BWF rendering hooks.
- **Local Text-to-Speech (TTS)**: Integrate voice replacement and local translation dubbing plugins using local models (e.g. ChatTTS or similar offline frameworks).

## Phase 3: Advanced Power-User Tooling

- **VapourSynth Processing Backend**: Enable advanced users to supply custom VapourSynth Python scripts for frame-by-frame restorations, denoising, and manual color grading.
- **Visual HDR Scope Monitor**: Add real-time luminance waveform, vector scope, and RGB parade displays in the video preview screen to help creators verify high dynamic range color coordinates.
- **Segmented Render Caching**: Support division of long videos into small chunks, rendering them concurrently, and merging them at the final stage to maximize CPU/GPU utilization on multi-core Mac Studio hardware.
