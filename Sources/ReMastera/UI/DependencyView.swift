import SwiftUI

public struct DependencyView: View {
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Friendly Header
            HStack {
                VStack(alignment: .leading, spacing: ReMasteraDesign.space4) {
                    Text("System Dependencies")
                        .font(ReMasteraType.heading(28))
                        .foregroundStyle(ReMasteraDesign.heading)
                    Text("Verify required command-line binaries and ML models.")
                        .font(ReMasteraType.body(15))
                        .foregroundStyle(ReMasteraDesign.body)
                }
                Spacer()
            }
            .padding(ReMasteraDesign.space32)
            
            SectionDivider()
            
            ScrollView {
                VStack(spacing: ReMasteraDesign.space32) {
                    
                    VStack(alignment: .leading, spacing: ReMasteraDesign.space16) {
                        Text("Core Binaries")
                            .font(ReMasteraType.label(14))
                            .foregroundStyle(ReMasteraDesign.brandDeep)
                        
                        VStack(spacing: ReMasteraDesign.space12) {
                            DependencyRow(
                                name: "FFmpeg",
                                description: "Core media processing and demuxing engine.",
                                command: "ffmpeg",
                                status: .installed("v7.0.1"),
                                installHint: "brew install ffmpeg"
                            )
                            
                            DependencyRow(
                                name: "FFprobe",
                                description: "Media stream analyzer.",
                                command: "ffprobe",
                                status: .installed("v7.0.1"),
                                installHint: "brew install ffmpeg"
                            )
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: ReMasteraDesign.space16) {
                        Text("Machine Learning Modules")
                            .font(ReMasteraType.label(14))
                            .foregroundStyle(ReMasteraDesign.brandDeep)
                        
                        VStack(spacing: ReMasteraDesign.space12) {
                            DependencyRow(
                                name: "Real-ESRGAN (NCNN Vulkan)",
                                description: "Neural network upscale engine for animation and film.",
                                command: "realesrgan-ncnn-vulkan",
                                status: .missing,
                                installHint: "brew install realesrgan-ncnn-vulkan"
                            )
                            
                            DependencyRow(
                                name: "Whisper.cpp",
                                description: "High-performance CoreML inference for subtitle extraction.",
                                command: "whisper-cpp",
                                status: .missing,
                                installHint: "brew install whisper-cpp"
                            )
                        }
                    }
                }
                .padding(ReMasteraDesign.space32)
            }
        }
        .background(ReMasteraDesign.background)
    }
}

enum DependencyStatus {
    case installed(String)
    case missing
    case checking
}

struct DependencyRow: View {
    let name: String
    let description: String
    let command: String
    let status: DependencyStatus
    let installHint: String
    
    var body: some View {
        HStack(alignment: .top, spacing: ReMasteraDesign.space16) {
            // Bouncy Status Icon
            Group {
                switch status {
                case .installed:
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(ReMasteraDesign.success)
                case .missing:
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(ReMasteraDesign.error)
                case .checking:
                    ProgressView()
                        .progressViewStyle(.circular)
                        .controlSize(.small)
                }
            }
            .font(.system(size: 24))
            .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: ReMasteraDesign.space8) {
                HStack {
                    Text(name)
                        .font(ReMasteraType.label(16))
                        .foregroundStyle(ReMasteraDesign.heading)
                    
                    Spacer()
                    
                    switch status {
                    case .installed(let version):
                        Text("Installed: \(version)")
                            .font(ReMasteraType.caption(12))
                            .foregroundStyle(ReMasteraDesign.success)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(ReMasteraDesign.success.opacity(0.15))
                            .clipShape(Capsule())
                    case .missing:
                        Text("Missing")
                            .font(ReMasteraType.caption(12))
                            .foregroundStyle(ReMasteraDesign.error)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(ReMasteraDesign.error.opacity(0.15))
                            .clipShape(Capsule())
                    case .checking:
                        Text("Checking")
                            .font(ReMasteraType.caption(12))
                            .foregroundStyle(ReMasteraDesign.warning)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(ReMasteraDesign.warning.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
                
                Text(description)
                    .font(ReMasteraType.body(14))
                    .foregroundStyle(ReMasteraDesign.body)
                
                HStack(spacing: ReMasteraDesign.space8) {
                    Image(systemName: "terminal")
                        .font(.system(size: 12))
                        .foregroundStyle(ReMasteraDesign.bodySubtle)
                    Text(command)
                        .font(ReMasteraType.code(12))
                        .foregroundStyle(ReMasteraDesign.body)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(ReMasteraDesign.surfaceElevated)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .padding(.top, 4)
                
                if case .missing = status {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.down.app.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(ReMasteraDesign.error)
                        Text(installHint)
                            .font(ReMasteraType.code(12))
                            .foregroundStyle(ReMasteraDesign.heading)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(ReMasteraDesign.error.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.top, 4)
                }
            }
        }
        .padding(ReMasteraDesign.space16)
        .remasteraCard(interactive: false)
    }
}
