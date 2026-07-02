import Foundation
import Observation

public struct JobData: Codable {
    public let id: UUID
    public let sourceURL: URL
    public let destinationURL: URL
    public let tags: [String]
    public let preset: Preset
    public let status: JobStatus
    public let currentStage: String
    public let progress: Double
    public let errorDescription: String?
    public let duration: Double?
    public let fileSizeEstimate: Int64
    public let actualFileSize: Int64?
    public let logs: [String]
    public var isDenoiseEnabled: Bool
    public var isFilmLookEnabled: Bool
    public var isSubtitleEnabled: Bool
    public var isUpscaleEnabled: Bool
    public var isHdr10Enabled: Bool
}

@MainActor
@Observable
public final class Job: Identifiable, Equatable {
    public let id: UUID
    public let sourceURL: URL
    public var destinationURL: URL
    public var tags: [String]
    public var preset: Preset
    public var status: JobStatus
    public var currentStage: String
    public var progress: Double // 0.0 to 1.0
    public var errorDescription: String?
    public var duration: Double? // in seconds
    public var fileSizeEstimate: Int64 // in bytes
    public var actualFileSize: Int64? // in bytes
    public var logs: [String]
    
    // Enhancement configuration flags
    public var isDenoiseEnabled: Bool
    public var isFilmLookEnabled: Bool
    public var isSubtitleEnabled: Bool
    public var isUpscaleEnabled: Bool
    public var isHdr10Enabled: Bool
    
    public init(
        id: UUID = UUID(),
        sourceURL: URL,
        destinationURL: URL,
        tags: [String] = [],
        preset: Preset = .balanced4K,
        status: JobStatus = .queued,
        currentStage: String = "Queued",
        progress: Double = 0.0,
        errorDescription: String? = nil,
        duration: Double? = nil,
        fileSizeEstimate: Int64 = 0,
        actualFileSize: Int64? = nil,
        logs: [String] = [],
        isDenoiseEnabled: Bool = false,
        isFilmLookEnabled: Bool = false,
        isSubtitleEnabled: Bool = false,
        isUpscaleEnabled: Bool = false,
        isHdr10Enabled: Bool = false
    ) {
        self.id = id
        self.sourceURL = sourceURL
        self.destinationURL = destinationURL
        self.tags = tags
        self.preset = preset
        self.status = status
        self.currentStage = currentStage
        self.progress = progress
        self.errorDescription = errorDescription
        self.duration = duration
        self.fileSizeEstimate = fileSizeEstimate
        self.actualFileSize = actualFileSize
        self.logs = logs
        self.isDenoiseEnabled = isDenoiseEnabled
        self.isFilmLookEnabled = isFilmLookEnabled
        self.isSubtitleEnabled = isSubtitleEnabled
        self.isUpscaleEnabled = isUpscaleEnabled
        self.isHdr10Enabled = isHdr10Enabled
    }
    
    /// Converts the dynamic Job state to a static JobData snapshot for serialization.
    public func toData() -> JobData {
        return JobData(
            id: id,
            sourceURL: sourceURL,
            destinationURL: destinationURL,
            tags: tags,
            preset: preset,
            status: status,
            currentStage: currentStage,
            progress: progress,
            errorDescription: errorDescription,
            duration: duration,
            fileSizeEstimate: fileSizeEstimate,
            actualFileSize: actualFileSize,
            logs: logs,
            isDenoiseEnabled: isDenoiseEnabled,
            isFilmLookEnabled: isFilmLookEnabled,
            isSubtitleEnabled: isSubtitleEnabled,
            isUpscaleEnabled: isUpscaleEnabled,
            isHdr10Enabled: isHdr10Enabled
        )
    }
    
    /// Initializes a dynamic Job model from a saved JobData snapshot.
    public convenience init(from data: JobData) {
        self.init(
            id: data.id,
            sourceURL: data.sourceURL,
            destinationURL: data.destinationURL,
            tags: data.tags,
            preset: data.preset,
            status: data.status,
            currentStage: data.currentStage,
            progress: data.progress,
            errorDescription: data.errorDescription,
            duration: data.duration,
            fileSizeEstimate: data.fileSizeEstimate,
            actualFileSize: data.actualFileSize,
            logs: data.logs,
            isDenoiseEnabled: data.isDenoiseEnabled,
            isFilmLookEnabled: data.isFilmLookEnabled,
            isSubtitleEnabled: data.isSubtitleEnabled,
            isUpscaleEnabled: data.isUpscaleEnabled,
            isHdr10Enabled: data.isHdr10Enabled
        )
    }
    
    // Equatable conformance
    public nonisolated static func == (lhs: Job, rhs: Job) -> Bool {
        return lhs.id == rhs.id
    }
}
