import SwiftUI
import AppKit

public struct PrivacyView: View {
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: ReMasteraDesign.space4) {
                    Text("OFFLINE SOVEREIGNTY")
                        .font(ReMasteraType.heading(24))
                        .foregroundStyle(ReMasteraDesign.heading)
                    Text("ReMastera guarantees absolute privacy through strict offline isolation.")
                        .font(ReMasteraType.body(14))
                        .foregroundStyle(ReMasteraDesign.body)
                }
                Spacer()
            }
            .padding(ReMasteraDesign.space32)
            
            SectionDivider()
            
            ScrollView {
                VStack(spacing: ReMasteraDesign.space48) {
                    // Guarantees
                    VStack(spacing: ReMasteraDesign.space16) {
                        PrivacyRow(
                            icon: "shield.checkered",
                            title: "ZERO CLOUD UPLOADS",
                            description: "Your media files never leave this machine. All operations are processed locally on your Apple Silicon hardware."
                        )
                        PrivacyRow(
                            icon: "wifi.slash",
                            title: "NO TELEMETRY",
                            description: "ReMastera does not gather usage analytics, logs, crash uploads, or user statistics. Your data is your own."
                        )
                        PrivacyRow(
                            icon: "folder.badge.gearshape",
                            title: "NO SILENT DOWNLOADS",
                            description: "The application will never download models or dependencies in the background without explicit terminal authorization."
                        )
                    }
                    
                    // Local Storage Info
                    VStack(alignment: .leading, spacing: ReMasteraDesign.space16) {
                        Text("LOCAL DIRECTORY STRUCTURE")
                            .font(ReMasteraType.label(12))
                            .tracking(2)
                            .foregroundStyle(ReMasteraDesign.brand)
                        
                        VStack(spacing: 0) {
                            DirectoryInfoRow(
                                title: "Model Directory",
                                description: "Neural network weights (Whisper, Real-ESRGAN)",
                                path: "~/Library/Application Support/ReMastera/Models"
                            )
                            Divider().background(ReMasteraDesign.borderSubtle)
                            DirectoryInfoRow(
                                title: "Log Directory",
                                description: "Local execution logs (ffmpeg transcripts)",
                                path: "~/Library/Logs/ReMastera"
                            )
                        }
                        .background(ReMasteraDesign.surfaceElevated)
                        .clipShape(RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase))
                        .overlay(
                            RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase)
                                .stroke(ReMasteraDesign.borderSubtle, lineWidth: 1)
                        )
                    }
                    
                    HStack {
                        Button(action: openLogsFolder) {
                            HStack(spacing: ReMasteraDesign.space8) {
                                Image(systemName: "terminal")
                                Text("REVEAL LOGS IN FINDER")
                                    .tracking(1)
                            }
                            .font(ReMasteraType.label(13))
                            .foregroundStyle(ReMasteraDesign.black)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(ReMasteraDesign.brand)
                            .clipShape(RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase))
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                }
                .padding(ReMasteraDesign.space32)
            }
        }
    }
    
    private func openLogsFolder() {
        let fileManager = FileManager.default
        let homeDir = fileManager.homeDirectoryForCurrentUser
        let logsDir = homeDir.appendingPathComponent("Library/Logs/ReMastera")
        
        try? fileManager.createDirectory(at: logsDir, withIntermediateDirectories: true)
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: logsDir.path)
    }
}

struct PrivacyRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: ReMasteraDesign.space24) {
            Image(systemName: icon)
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(ReMasteraDesign.success)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: ReMasteraDesign.space8) {
                Text(title)
                    .font(ReMasteraType.label(16))
                    .tracking(2)
                    .foregroundStyle(ReMasteraDesign.heading)
                Text(description)
                    .font(ReMasteraType.body(14))
                    .foregroundStyle(ReMasteraDesign.body)
                    .lineSpacing(4)
            }
            Spacer()
        }
        .padding(ReMasteraDesign.space24)
        .background(ReMasteraDesign.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase))
        .overlay(
            RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase)
                .stroke(ReMasteraDesign.borderSubtle, lineWidth: 1)
        )
    }
}

struct DirectoryInfoRow: View {
    let title: String
    let description: String
    let path: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: ReMasteraDesign.space8) {
            HStack {
                Text(title)
                    .font(ReMasteraType.label(14))
                    .foregroundStyle(ReMasteraDesign.heading)
                Spacer()
                Text(description)
                    .font(ReMasteraType.caption(12))
                    .foregroundStyle(ReMasteraDesign.fgDisabled)
            }
            Text(path)
                .font(ReMasteraType.caption(12))
                .foregroundStyle(ReMasteraDesign.brand)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(ReMasteraDesign.black)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(ReMasteraDesign.borderSubtle, lineWidth: 1)
                )
        }
        .padding(ReMasteraDesign.space16)
    }
}
