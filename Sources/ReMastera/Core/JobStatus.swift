import Foundation

public enum JobStatus: String, Codable, Equatable, Sendable {
    case queued
    case processing
    case completed
    case failed
    case cancelled
    
    public var displayName: String {
        switch self {
        case .queued: return "Queued"
        case .processing: return "Processing"
        case .completed: return "Completed"
        case .failed: return "Failed"
        case .cancelled: return "Cancelled"
        }
    }
}
