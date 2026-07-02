import Foundation

public struct SizeEstimator {
    /// Estimates final file size in bytes based on duration, video bitrate (Mbps), and audio bitrate (kbps).
    public static func estimateSize(durationSeconds: Double, videoBitrateMbps: Double, audioBitrateKbps: Double) -> Int64 {
        guard durationSeconds > 0 else { return 0 }
        
        let totalBitrateBps = (videoBitrateMbps * 1_000_000.0) + (audioBitrateKbps * 1000.0)
        let totalBytes = (totalBitrateBps * durationSeconds) / 8.0
        
        return Int64(totalBytes)
    }
    
    /// Formats bytes into a human-readable string using the decimal base (e.g., MB, GB).
    public static func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
        formatter.countStyle = .decimal
        return formatter.string(fromByteCount: bytes)
    }
}
