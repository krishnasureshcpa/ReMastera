import Foundation

public struct EncodeStage: PipelineStage {
    public let id = "encode"
    public let displayName = "Final Encoding"
    
    public init() {}
    
    public func run(context: PipelineContext) async throws {
        context.addLog("Searching for local encoding backend (ffmpeg)...")
        
        guard let ffmpegURL = DependencyDetector.locateTool("ffmpeg") else {
            throw ToolError.executionFailed("ffmpeg CLI not found. Final encoding cannot proceed. Please install ffmpeg via Homebrew.")
        }
        
        context.addLog("ffmpeg found at \(ffmpegURL.path)")
        
        let job = context.job
        
        // 1. Resolve video filters
        var videoFilters = context.videoFilters
        if job.isUpscaleEnabled {
            context.addLog("Standard upscale enabled. Rescaling video to 3840x2160 (lanczos)...")
            videoFilters.append("scale=3840:2160:flags=lanczos")
        }
        
        // 2. Build FFmpeg command arguments
        var args: [String] = []
        
        // Overwrite output files automatically if specified
        args.append("-y")
        
        // Input file
        args.append(contentsOf: ["-i", job.sourceURL.path])
        
        // Mux subtitles if generated
        if let subtitleURL = context.subtitleSRTURL {
            args.append(contentsOf: ["-i", subtitleURL.path])
        }
        
        // Video encoder & bitrates
        args.append(contentsOf: ["-c:v", "hevc_videotoolbox"])
        
        let videoBitrateBps = Int(job.preset.videoBitrateMbps * 1_000_000)
        args.append(contentsOf: ["-b:v", "\(videoBitrateBps)"])
        
        // HEVC 10-bit & HDR10 Metadata if enabled
        if job.isHdr10Enabled {
            context.addLog("Applying HDR10 container metadata tags (Rec.2020 / PQ).")
            args.append(contentsOf: [
                "-profile:v", "main10",
                "-pix_fmt", "yuv420p10le",
                "-color_primaries", "bt2020",
                "-color_trc", "smpte2084",
                "-colorspace", "bt2020"
            ])
        }
        
        // Assemble filtergraph
        if !videoFilters.isEmpty {
            let filterGraphString = videoFilters.joined(separator: ",")
            args.append(contentsOf: ["-vf", filterGraphString])
        }
        
        // Audio parameters
        args.append(contentsOf: ["-c:a", "aac"])
        let audioBitrateBps = Int(job.preset.audioBitrateKbps * 1000)
        args.append(contentsOf: ["-b:a", "\(audioBitrateBps)"])
        
        // Subtitle mapping if subtitle file input is added
        if context.subtitleSRTURL != nil {
            args.append(contentsOf: [
                "-map", "0:v",
                "-map", "0:a",
                "-map", "1:s",
                "-c:s", "mov_text",
                "-metadata:s:s:0", "language=eng"
            ])
        }
        
        // Destination file
        // Ensure destination folder exists
        let destFolder = job.destinationURL.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: destFolder, withIntermediateDirectories: true)
        
        args.append(job.destinationURL.path)
        
        context.addLog("Executing FFmpeg command: ffmpeg \(args.joined(separator: " "))")
        
        let totalDuration = job.duration ?? 0.0
        
        do {
            try await ExternalToolRunner.run(executableURL: ffmpegURL, arguments: args) { progressLine in
                // Sample progress line: "frame=  134 fps= 45 q=-0.0 size=    1024kB time=00:00:05.12 bitrate=1638.4kbits/s speed=1.8x"
                if totalDuration > 0, let timeRange = progressLine.range(of: "time=") {
                    let timeSubstring = progressLine[timeRange.upperBound...]
                    let timeParts = timeSubstring.prefix(11).trimmingCharacters(in: .whitespaces).components(separatedBy: ":")
                    
                    if timeParts.count == 3,
                       let hours = Double(timeParts[0]),
                       let minutes = Double(timeParts[1]),
                       let seconds = Double(timeParts[2]) {
                        
                        let currentSeconds = (hours * 3600.0) + (minutes * 60.0) + seconds
                        let calcProgress = min(max(currentSeconds / totalDuration, 0.0), 0.99)
                        
                        Task { @MainActor in
                            job.progress = calcProgress
                        }
                    }
                }
            }
            
            // Log final file size
            if let attrs = try? FileManager.default.attributesOfItem(atPath: job.destinationURL.path),
               let size = attrs[.size] as? Int64 {
                Task { @MainActor in
                    job.actualFileSize = size
                }
                context.addLog("✓ Export complete. Final file size: \(SizeEstimator.formatBytes(size))")
            } else {
                context.addLog("✓ Export complete.")
            }
        } catch {
            throw ToolError.executionFailed("FFmpeg encoding process failed: \(error.localizedDescription)")
        }
    }
}
