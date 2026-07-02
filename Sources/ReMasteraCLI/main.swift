import Foundation
import ArgumentParser
import ReMasteraCore

@main
struct ReMasteraCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "remastera-core",
        abstract: "ReMastera headless CLI for video processing."
    )

    @Argument(help: "The source video file path.")
    var source: String

    @Argument(help: "The destination directory or file path.")
    var destination: String

    @Option(name: .shortAndLong, help: "Preset (Fast Preview, Compact 4K, Balanced 4K, Archival 4K, Original Resolution Enhanced)")
    var preset: String = "Balanced 4K"

    @Flag(name: .long, help: "Enable denoise stage")
    var denoise: Bool = false

    @Flag(name: .long, help: "Enable kodak film look stage")
    var filmLook: Bool = false

    @Flag(name: .long, help: "Enable subtitle extraction")
    var subtitles: Bool = false

    @Flag(name: .long, help: "Enable 4K upscaling")
    var upscale: Bool = false

    @Flag(name: .long, help: "Enable HDR10 container tagging")
    var hdr10: Bool = false

    mutating func run() async throws {
        guard let resolvedPreset = Preset.allCases.first(where: { $0.rawValue.lowercased() == preset.lowercased() }) else {
            print("{\"error\": \"Invalid preset: \(preset)\"}")
            throw ExitCode.failure
        }

        let sourceURL = URL(fileURLWithPath: source)
        let destURL = URL(fileURLWithPath: destination)

        let sizeEstimate = SizeEstimator.estimateSize(
            durationSeconds: 0,
            videoBitrateMbps: resolvedPreset.videoBitrateMbps,
            audioBitrateKbps: resolvedPreset.audioBitrateKbps
        )

        let tags = [
            denoise ? "denoised" : nil,
            filmLook ? "kodak" : nil,
            subtitles ? "subtitles" : nil,
            upscale ? "upscaled" : nil,
            hdr10 ? "hdr10" : nil
        ].compactMap { $0 }

        let job = await MainActor.run {
            Job(
                sourceURL: sourceURL,
                destinationURL: destURL,
                tags: tags,
                preset: resolvedPreset,
                status: .queued,
                fileSizeEstimate: sizeEstimate,
                isDenoiseEnabled: denoise,
                isFilmLookEnabled: filmLook,
                isSubtitleEnabled: subtitles,
                isUpscaleEnabled: upscale,
                isHdr10Enabled: hdr10
            )
        }

        // Start processing
        Task { @MainActor in
            await Pipeline.execute(job: job)
        }

        var isDone = false
        var lastProgress: Double = -1.0
        var lastStage = ""

        while !isDone {
            let statusTuple = await MainActor.run {
                (job.status, job.progress, job.currentStage)
            }
            let (status, progress, stage) = statusTuple

            if progress != lastProgress || stage != lastStage || status == .completed || status == .failed || status == .cancelled {
                lastProgress = progress
                lastStage = stage
                
                await MainActor.run {
                    printJobStatus(job: job)
                }
            }

            if status == .completed || status == .failed || status == .cancelled {
                isDone = true
                break
            }

            try await Task.sleep(nanoseconds: 100_000_000)
        }
        
        let finalStatus = await MainActor.run { job.status }
        if finalStatus != .completed {
            throw ExitCode.failure
        }
    }
    
    @MainActor
    private func printJobStatus(job: Job) {
        let encoder = JSONEncoder()
        let data = job.toData()
        if let jsonData = try? encoder.encode(data),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString)
            fflush(stdout)
        }
    }
}
