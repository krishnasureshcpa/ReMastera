import Foundation
import Observation

@MainActor
@Observable
public final class PipelineContext {
    public let job: Job
    public let tempDirectoryURL: URL
    public var stageLogs: [String] = []
    public var isCancelled: Bool = false
    
    // Single-pass FFmpeg builder context
    public var videoFilters: [String] = []
    public var audioFilters: [String] = []
    public var extraArguments: [String] = []
    public var subtitleSRTURL: URL? = nil
    
    public init(job: Job, tempDirectoryURL: URL) {
        self.job = job
        self.tempDirectoryURL = tempDirectoryURL
    }
    
    public func addLog(_ message: String) {
        let timestamp = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: [.withTime, .withColonSeparatorInTime])
        let logMessage = "[\(timestamp)] \(message)"
        stageLogs.append(logMessage)
        job.logs.append(logMessage)
    }
}
