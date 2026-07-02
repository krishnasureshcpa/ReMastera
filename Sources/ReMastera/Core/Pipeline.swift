import Foundation

public final class Pipeline {
    /// Executes the full enhancement pipeline for a given Job.
    @MainActor
    public static func execute(job: Job) async {
        guard job.status == .queued else { return }
        
        job.status = .processing
        job.progress = 0.0
        job.errorDescription = nil
        job.logs = []
        
        // 1. Create temporary directory
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory
            .appendingPathComponent("ReMastera-\(job.id.uuidString)")
        
        let context = PipelineContext(job: job, tempDirectoryURL: tempDir)
        context.addLog("Starting ReMastera processing pipeline for: \(job.sourceURL.lastPathComponent)")
        
        do {
            try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)
            
            // 2. Query video metadata (Duration)
            job.currentStage = "Reading Metadata"
            context.addLog("Querying video metadata using ffprobe...")
            if let ffprobeURL = DependencyDetector.locateTool("ffprobe") {
                let durationArgs = [
                    "-v", "error",
                    "-show_entries", "format=duration",
                    "-of", "default=noprint_wrappers=1:nokey=1",
                    job.sourceURL.path
                ]
                
                if let durationStr = try? ExternalToolRunner.runSync(executableURL: ffprobeURL, arguments: durationArgs),
                   let duration = Double(durationStr.trimmingCharacters(in: .whitespacesAndNewlines)) {
                    job.duration = duration
                    
                    // Update estimate size
                    let estimate = SizeEstimator.estimateSize(
                        durationSeconds: duration,
                        videoBitrateMbps: job.preset.videoBitrateMbps,
                        audioBitrateKbps: job.preset.audioBitrateKbps
                    )
                    job.fileSizeEstimate = estimate
                    context.addLog("Video duration detected: \(String(format: "%.2f", duration))s. Size estimate: \(SizeEstimator.formatBytes(estimate))")
                } else {
                    context.addLog("⚠ Failed to query duration via ffprobe. Using duration fallback.")
                }
            } else {
                context.addLog("⚠ ffprobe not found. Metadata scanning skipped.")
            }
            
            // Define stages
            let stages: [PipelineStage] = [
                DenoiseStage(),
                FilmLookStage(),
                SubtitleStage(),
                EncodeStage()
            ]
            
            // Run each stage sequentially
            for stage in stages {
                if Task.isCancelled || context.isCancelled {
                    throw ToolError.cancelled
                }
                
                job.currentStage = stage.displayName
                context.addLog("---- Entering Stage: \(stage.displayName) ----")
                try await stage.run(context: context)
            }
            
            // Success
            job.status = .completed
            job.progress = 1.0
            job.currentStage = "Completed"
            context.addLog("Pipeline processing completed successfully.")
            
        } catch is CancellationError {
            job.status = .cancelled
            job.currentStage = "Cancelled"
            context.addLog("Pipeline processing cancelled by user.")
        } catch {
            job.status = .failed
            job.currentStage = "Failed"
            job.errorDescription = error.localizedDescription
            context.addLog("❌ Error: \(error.localizedDescription)")
        }
        
        // Clean up temporary workspace directory
        do {
            if fileManager.fileExists(atPath: tempDir.path) {
                try fileManager.removeItem(at: tempDir)
                context.addLog("Cleaned up temporary directory: \(tempDir.path)")
            }
        } catch {
            context.addLog("⚠ Failed to clean up temporary directory: \(error.localizedDescription)")
        }
        
        // Save logs locally under ~/Library/Logs/ReMastera/
        saveLogsLocally(job: job)
    }
    
    /// Writes the logs for a completed/failed job to the local log directory.
    @MainActor
    private static func saveLogsLocally(job: Job) {
        let fileManager = FileManager.default
        let homeDir = fileManager.homeDirectoryForCurrentUser
        let logsDir = homeDir.appendingPathComponent("Library/Logs/ReMastera")
        
        do {
            try fileManager.createDirectory(at: logsDir, withIntermediateDirectories: true)
            let logFileURL = logsDir.appendingPathComponent("job-\(job.id.uuidString).log")
            
            let logContent = job.logs.joined(separator: "\n")
            try logContent.write(to: logFileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to save local log: \(error.localizedDescription)")
        }
    }
}
