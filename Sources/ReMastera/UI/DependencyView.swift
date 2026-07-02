import SwiftUI

public struct DependencyView: View {
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: ReMasteraDesign.space4) {
                    Text("SYSTEM DEPENDENCIES")
                        .font(ReMasteraType.heading(24))
                        .foregroundStyle(ReMasteraDesign.heading)
                    Text("Verify required command-line binaries and ML models.")
                        .font(ReMasteraType.body(14))
                        .foregroundStyle(ReMasteraDesign.body)
                }
                Spacer()
            }
            .padding(ReMasteraDesign.space32)
            
            SectionDivider()
            
            ScrollView {
                VStack(spacing: ReMasteraDesign.space32) {
                    
                    VStack(alignment: .leading, spacing: ReMasteraDesign.space16) {
                        Text("CORE BINARIES")
                            .font(ReMasteraType.label(12))
                            .tracking(2)
                            .foregroundStyle(ReMasteraDesign.brand)
                        
                        VStack(spacing: 0) {
                            DependencyRow(
                                name: "FFmpeg",
                                description: "Core media processing and demuxing engine.",
                                command: "ffmpeg",
                                status: .installed("v7.0.1"),
                                installHint: "brew install ffmpeg"
                            )
                            Divider().background(ReMasteraDesign.borderSubtle)
                            DependencyRow(
                                name: "FFprobe",
                                description: "Media stream analyzer.",
                                command: "ffprobe",
                                status: .installed("v7.0.1"),
                                installHint: "brew install ffmpeg"
                            )
                        }
                        .background(ReMasteraDesign.surfaceElevated)
                        .clipShape(RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase))
                        .overlay(
                            RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase)
                                .stroke(ReMasteraDesign.borderSubtle, lineWidth: 1)
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: ReMasteraDesign.space16) {
                        Text("MACHINE LEARNING MODULES")
                            .font(ReMasteraType.label(12))
                            .tracking(2)
                            .foregroundStyle(ReMasteraDesign.brand)
                        
                        VStack(spacing: 0) {
                            DependencyRow(
                                name: "Real-ESRGAN (NCNN Vulkan)",
                                description: "Neural network upscale engine for animation and film.",
                                command: "realesrgan-ncnn-vulkan",
                                status: .missing,
                                installHint: "brew install realesrgan-ncnn-vulkan"
                            )
                            Divider().background(ReMasteraDesign.borderSubtle)
                            DependencyRow(
                                name: "Whisper.cpp",
                                description: "High-performance CoreML inference for subtitle extraction.",
                                command: "whisper-cpp",
                                status: .missing,
                                installHint: "brew install whisper-cpp"
                            )
                        }
                        .background(ReMasteraDesign.surfaceElevated)
                        .clipShape(RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase))
                        .overlay(
                            RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase)
                                .stroke(ReMasteraDesign.borderSubtle, lineWidth: 1)
                        )
                    }
                }
                .padding(ReMasteraDesign.space32)
            }
        }
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
            // Status Icon
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
            .font(.system(size: 20))
            .frame(width: 24, height: 24)
            .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: ReMasteraDesign.space8) {
                HStack {
                    Text(name)
                        .font(ReMasteraType.label(14))
                        .foregroundStyle(ReMasteraDesign.heading)
                    
                    Spacer()
                    
                    switch status {
                    case .installed(let version):
                        Text("INSTALLED: \(version)")
                            .font(ReMasteraType.caption(10))
                            .tracking(1)
                            .foregroundStyle(ReMasteraDesign.success)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(ReMasteraDesign.success.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    case .missing:
                        Text("MISSING")
                            .font(ReMasteraType.caption(10))
                            .tracking(1)
                            .foregroundStyle(ReMasteraDesign.error)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(ReMasteraDesign.error.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    case .checking:
                        Text("CHECKING")
                            .font(ReMasteraType.caption(10))
                            .tracking(1)
                            .foregroundStyle(ReMasteraDesign.warning)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(ReMasteraDesign.warning.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
                
                Text(description)
                    .font(ReMasteraType.body(12))
                    .foregroundStyle(ReMasteraDesign.body)
                
                HStack(spacing: ReMasteraDesign.space12) {
                    Text("CMD:")
                        .font(ReMasteraType.caption(10))
                        .foregroundStyle(ReMasteraDesign.fgDisabled)
                    Text(command)
                        .font(ReMasteraType.caption(11))
                        .foregroundStyle(ReMasteraDesign.brand)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(ReMasteraDesign.black)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(ReMasteraDesign.borderSubtle, lineWidth: 1)
                        )
                }
                .padding(.top, 4)
                
                if case .missing = status {
                    HStack(spacing: 8) {
                        Image(systemName: "terminal")
                            .font(.system(size: 10))
                            .foregroundStyle(ReMasteraDesign.fgDisabled)
                        Text(installHint)
                            .font(ReMasteraType.caption(11))
                            .foregroundStyle(ReMasteraDesign.heading)
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(ReMasteraDesign.black)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(ReMasteraDesign.error.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.top, 4)
                }
            }
        }
        .padding(ReMasteraDesign.space16)
    }
}
