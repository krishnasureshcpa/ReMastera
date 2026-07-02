import Foundation
import Observation

@MainActor
@Observable
public final class QueueManager {
    public var jobs: [Job] = []
    public var isProcessing: Bool = false
    
    private var processingTask: Task<Void, Never>? = nil
    
    public init() {}
    
    /// Adds a new remastering job to the queue.
    public func addJob(
        sourceURL: URL,
        destinationURL: URL,
        preset: Preset,
        isDenoiseEnabled: Bool,
        isFilmLookEnabled: Bool,
        isSubtitleEnabled: Bool,
        isUpscaleEnabled: Bool,
        isHdr10Enabled: Bool
    ) {
        let sizeEstimate = SizeEstimator.estimateSize(
            durationSeconds: 0, // queried during execution
            videoBitrateMbps: preset.videoBitrateMbps,
            audioBitrateKbps: preset.audioBitrateKbps
        )
        
        let tags = [
            isDenoiseEnabled ? "denoised" : nil,
            isFilmLookEnabled ? "kodak" : nil,
            isSubtitleEnabled ? "subtitles" : nil,
            isUpscaleEnabled ? "upscaled" : nil,
            isHdr10Enabled ? "hdr10" : nil
        ].compactMap { $0 }
        
        let job = Job(
            sourceURL: sourceURL,
            destinationURL: destinationURL,
            tags: tags,
            preset: preset,
            status: .queued,
            fileSizeEstimate: sizeEstimate,
            isDenoiseEnabled: isDenoiseEnabled,
            isFilmLookEnabled: isFilmLookEnabled,
            isSubtitleEnabled: isSubtitleEnabled,
            isUpscaleEnabled: isUpscaleEnabled,
            isHdr10Enabled: isHdr10Enabled
        )
        
        jobs.append(job)
        processNextIfNeeded()
    }
    
    /// Processes the next queued job if no job is currently running.
    public func processNextIfNeeded() {
        guard !isProcessing else { return }
        guard let nextJob = jobs.first(where: { $0.status == .queued }) else { return }
        
        isProcessing = true
        processingTask = Task {
            await Pipeline.execute(job: nextJob)
            isProcessing = false
            processNextIfNeeded()
        }
    }
    
    /// Cancels a running or queued job.
    public func cancelJob(job: Job) {
        if job.status == .processing {
            processingTask?.cancel()
            processingTask = nil
            job.status = .cancelled
            job.currentStage = "Cancelled"
            job.logs.append("Job cancelled by user.")
            isProcessing = false
            processNextIfNeeded()
        } else if job.status == .queued {
            job.status = .cancelled
            job.currentStage = "Cancelled"
        }
    }
    
    /// Retries a failed or cancelled job.
    public func retryJob(job: Job) {
        job.status = .queued
        job.progress = 0.0
        job.currentStage = "Queued"
        job.errorDescription = nil
        processNextIfNeeded()
    }
    
    /// Removes a job from the queue.
    public func removeJob(job: Job) {
        cancelJob(job: job)
        jobs.removeAll(where: { $0.id == job.id })
    }
}
