import SwiftUI
import AppKit

public struct PrivacyView: View {
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Friendly Header
            HStack {
                VStack(alignment: .leading, spacing: ReMasteraDesign.space4) {
                    Text("Offline Sovereignty")
                        .font(ReMasteraType.heading(28))
                        .foregroundStyle(ReMasteraDesign.heading)
                    Text("ReMastera guarantees absolute privacy through strict offline isolation.")
                        .font(ReMasteraType.body(15))
                        .foregroundStyle(ReMasteraDesign.body)
                }
                Spacer()
            }
            .padding(ReMasteraDesign.space32)
            
            SectionDivider()
            
            ScrollView {
                VStack(spacing: ReMasteraDesign.space48) {
                    // Gamified Guarantees
                    VStack(spacing: ReMasteraDesign.space16) {
                        PrivacyRow(
                            icon: "shield.checkered",
                            iconColor: ReMasteraDesign.success,
                            title: "Zero Cloud Uploads",
                            description: "Your media files never leave this machine. All operations are processed locally on your Apple Silicon hardware."
                        )
                        PrivacyRow(
                            icon: "wifi.slash",
                            iconColor: ReMasteraDesign.brandDeep,
                            title: "No Telemetry",
                            description: "ReMastera does not gather usage analytics, logs, crash uploads, or user statistics. Your data is your own."
                        )
                        PrivacyRow(
                            icon: "folder.badge.gearshape",
                            iconColor: ReMasteraDesign.warning,
                            title: "No Silent Downloads",
                            description: "The application will never download models or dependencies in the background without explicit terminal authorization."
                        )
                    }
                    
                    // Local Storage Info
                    VStack(alignment: .leading, spacing: ReMasteraDesign.space16) {
                        Text("Local Directory Structure")
                            .font(ReMasteraType.label(14))
                            .foregroundStyle(ReMasteraDesign.brandDeep)
                        
                        VStack(spacing: ReMasteraDesign.space12) {
                            DirectoryInfoRow(
                                title: "Model Directory",
                                description: "Neural network weights (Whisper, Real-ESRGAN)",
                                path: "~/Library/Application Support/ReMastera/Models"
                            )
                            DirectoryInfoRow(
                                title: "Log Directory",
                                description: "Local execution logs (ffmpeg transcripts)",
                                path: "~/Library/Logs/ReMastera"
                            )
                        }
                    }
                    
                    HStack {
                        Button(action: openLogsFolder) {
                            HStack(spacing: ReMasteraDesign.space8) {
                                Image(systemName: "folder.fill")
                                Text("Reveal Logs in Finder")
                            }
                            .font(ReMasteraType.label(14))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(ReMasteraDesign.brand)
                            .clipShape(Capsule())
                            .shadow(color: ReMasteraDesign.brand.opacity(0.3), radius: 8, y: 4)
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                }
                .padding(ReMasteraDesign.space32)
            }
        }
        .background(ReMasteraDesign.background)
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
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: ReMasteraDesign.space24) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(iconColor)
            }
            
            VStack(alignment: .leading, spacing: ReMasteraDesign.space8) {
                Text(title)
                    .font(ReMasteraType.label(18))
                    .foregroundStyle(ReMasteraDesign.heading)
                Text(description)
                    .font(ReMasteraType.body(14))
                    .foregroundStyle(ReMasteraDesign.body)
                    .lineSpacing(4)
            }
            Spacer()
        }
        .padding(ReMasteraDesign.space24)
        .remasteraCard(interactive: false)
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
                    .font(ReMasteraType.label(16))
                    .foregroundStyle(ReMasteraDesign.heading)
                Spacer()
                Text(description)
                    .font(ReMasteraType.caption(12))
                    .foregroundStyle(ReMasteraDesign.bodySubtle)
            }
            Text(path)
                .font(ReMasteraType.code(12))
                .foregroundStyle(ReMasteraDesign.brand)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(ReMasteraDesign.brand.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(ReMasteraDesign.space16)
        .remasteraCard(interactive: false)
    }
}
