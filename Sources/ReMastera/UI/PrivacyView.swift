import SwiftUI
import AppKit

public struct PrivacyView: View {
    @State private var isNetworkSecure = true
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Privacy & Offline Sovereignty")
                    .font(.title2.bold())
                Text("ReMastera is designed to operate 100% offline, guaranteeing absolute privacy.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 16) {
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 36))
                        .foregroundStyle(.green)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Zero Cloud Uploads")
                            .font(.headline)
                        Text("Your media files never leave this machine. All operations are processed locally on your Mac.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                HStack(spacing: 16) {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 36))
                        .foregroundStyle(.green)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("No Telemetry & Analytics")
                            .font(.headline)
                        Text("ReMastera does not gather usage analytics, logs, crash uploads, or user statistics.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                HStack(spacing: 16) {
                    Image(systemName: "folder.badge.gearshape")
                        .font(.system(size: 36))
                        .foregroundStyle(.orange)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("No Silent Downloads")
                            .font(.headline)
                        Text("The application will never download models or dependencies in the background without your explicit permission.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.vertical, 8)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Local Directories")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    directoryRow(
                        title: "Model Directory",
                        description: "Used to store neural network models (e.g. Whisper base models).",
                        path: "~/Library/Application Support/ReMastera/Models"
                    )
                    
                    directoryRow(
                        title: "Log Directory",
                        description: "Stores local execution logs (job-specific transcripts).",
                        path: "~/Library/Logs/ReMastera"
                    )
                }
            }
            
            Spacer()
            
            HStack {
                Button(action: openLogsFolder) {
                    Label("Reveal Logs Folder in Finder", systemImage: "folder")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .padding()
    }
    
    @ViewBuilder
    private func directoryRow(title: String, description: String, path: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline.bold())
            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(path)
                .font(.system(.caption, design: .monospaced))
                .padding(6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(nsColor: .textBackgroundColor))
                .cornerRadius(4)
        }
        .padding(.vertical, 4)
    }
    
    private func openLogsFolder() {
        let fileManager = FileManager.default
        let homeDir = fileManager.homeDirectoryForCurrentUser
        let logsDir = homeDir.appendingPathComponent("Library/Logs/ReMastera")
        
        // Ensure directory exists before opening
        try? fileManager.createDirectory(at: logsDir, withIntermediateDirectories: true)
        
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: logsDir.path)
    }
}
