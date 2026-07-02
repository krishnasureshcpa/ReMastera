import Foundation

public enum Preset: String, Codable, CaseIterable, Identifiable, Equatable, Sendable {
    case fastPreview = "fast-preview"
    case compact4K = "compact-4k"
    case balanced4K = "balanced-4k"
    case archival4K = "archival-4k"
    case originalResolution = "original-resolution"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .fastPreview: return "Fast Preview"
        case .compact4K: return "Compact 4K"
        case .balanced4K: return "Balanced 4K"
        case .archival4K: return "Archival 4K"
        case .originalResolution: return "Original Resolution Enhanced"
        }
    }
    
    public var videoBitrateMbps: Double {
        switch self {
        case .fastPreview: return 2.0
        case .compact4K: return 5.0
        case .balanced4K: return 10.0
        case .archival4K: return 25.0
        case .originalResolution: return 6.0
        }
    }
    
    public var audioBitrateKbps: Double {
        switch self {
        case .fastPreview: return 128.0
        case .compact4K: return 192.0
        case .balanced4K: return 256.0
        case .archival4K: return 320.0
        case .originalResolution: return 192.0
        }
    }
    
    public var description: String {
        switch self {
        case .fastPreview:
            return "Visually lightweight, fast processing for quick setting previews."
        case .compact4K:
            return "Constrained HEVC 10-bit. Visually clean, extremely storage-efficient."
        case .balanced4K:
            return "High fidelity HEVC 10-bit. Balanced size and crisp details."
        case .archival4K:
            return "Pro-tier master quality. High bitrate, large file size."
        case .originalResolution:
            return "Enhances color and texture without upscaling resolution."
        }
    }
}
