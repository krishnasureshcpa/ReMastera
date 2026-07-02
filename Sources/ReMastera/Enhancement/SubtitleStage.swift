import Foundation

public struct SubtitleStage: PipelineStage {
    public let id = "subtitles"
    public let displayName = "Subtitle Extraction"
    
    public init() {}
    
    public func run(context: PipelineContext) async throws {
        guard context.job.isSubtitleEnabled else {
            context.addLog("Subtitle extraction disabled. Skipping.")
            return
        }
        
        context.addLog("Scanning for local subtitle extraction backend (whisper-cpp)...")
        
        let whisperURL = DependencyDetector.locateTool("whisper-cpp") ?? DependencyDetector.locateTool("whisper-cli")
        guard let whisperURL = whisperURL else {
            context.addLog("⚠ whisper-cpp not found. Skipping subtitle extraction.")
            context.addLog("Install instructions: Run 'brew install whisper-cpp' and configure a model.")
            return
        }
        
        context.addLog("Subtitle backend found at \(whisperURL.path). Starting subtitle extraction...")
        
        let outputSRTURL = context.tempDirectoryURL.appendingPathComponent("subtitles.srt")
        let modelDir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/ReMastera/Models")
        
        // Ensure models directory exists
        try? FileManager.default.createDirectory(at: modelDir, withIntermediateDirectories: true)
        
        let modelPath = modelDir.appendingPathComponent("ggml-base.en.bin")
        
        guard FileManager.default.fileExists(atPath: modelPath.path) else {
            context.addLog("⚠ Whisper model ggml-base.en.bin missing under \(modelDir.path). Skipping subtitles.")
            context.addLog("Please download a model to unlock offline subtitle extraction.")
            return
        }
        
        let arguments = [
            "-m", modelPath.path,
            "-f", context.job.sourceURL.path,
            "-of", outputSRTURL.deletingPathExtension().path,
            "-osrt"
        ]
        
        do {
            try await ExternalToolRunner.run(executableURL: whisperURL, arguments: arguments) { progressLine in
                Task { @MainActor in
                    context.addLog("[whisper] \(progressLine)")
                }
            }
            context.subtitleSRTURL = outputSRTURL
            context.addLog("✓ Subtitles successfully generated at \(outputSRTURL.path)")
        } catch {
            context.addLog("⚠ whisper-cli failed: \(error.localizedDescription). Skipping subtitles.")
        }
    }
}
