import SwiftUI
import UniformTypeIdentifiers

public struct DashboardView: View {
    @Bindable var queueManager: QueueManager
    @State private var isTargeted = false
    @State private var selectedPreset: Preset = .balanced4K
    
    // Feature Toggles
    @State private var isDenoiseEnabled = false
    @State private var isFilmLookEnabled = false
    @State private var isSubtitleEnabled = false
    @State private var isUpscaleEnabled = false
    @State private var isHdr10Enabled = false
    
    public init(queueManager: QueueManager) {
        self.queueManager = queueManager
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: ReMasteraDesign.space4) {
                    Text("DASHBOARD")
                        .font(ReMasteraType.heading(24))
                        .foregroundStyle(ReMasteraDesign.heading)
                    Text("Drop media files here to begin processing sequence.")
                        .font(ReMasteraType.body(14))
                        .foregroundStyle(ReMasteraDesign.body)
                }
                Spacer()
            }
            .padding(ReMasteraDesign.space32)
            
            SectionDivider()
            
            HStack(spacing: 0) {
                // Left: Drop Zone
                VStack {
                    ZStack {
                        // Drop Zone Background
                        RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase)
                            .fill(isTargeted ? ReMasteraDesign.brandSofter : ReMasteraDesign.surfaceElevated)
                            .overlay(
                                RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase)
                                    .strokeBorder(
                                        isTargeted ? ReMasteraDesign.brand : ReMasteraDesign.borderSubtle,
                                        style: StrokeStyle(lineWidth: isTargeted ? 2 : 1, dash: isTargeted ? [10] : [])
                                    )
                            )
                        
                        VStack(spacing: ReMasteraDesign.space24) {
                            Image(systemName: "plus.square.dashed")
                                .font(.system(size: 64, weight: .ultraLight))
                                .foregroundStyle(isTargeted ? ReMasteraDesign.brand : ReMasteraDesign.brandSoft)
                            
                            VStack(spacing: ReMasteraDesign.space8) {
                                Text("INITIALIZE BATCH")
                                    .font(ReMasteraType.label(16))
                                    .tracking(2)
                                    .foregroundStyle(isTargeted ? ReMasteraDesign.brand : ReMasteraDesign.heading)
                                Text("Drag & drop .mov, .mp4, or .mkv files")
                                    .font(ReMasteraType.caption(12))
                                    .foregroundStyle(ReMasteraDesign.fgDisabled)
                            }
                        }
                    }
                    .padding(ReMasteraDesign.space32)
                    .onDrop(of: [UTType.movie, UTType.video], isTargeted: $isTargeted) { providers in
                        handleDrop(providers: providers)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Vertical Divider
                Rectangle()
                    .fill(ReMasteraDesign.borderSubtle)
                    .frame(width: 1)
                
                // Right: Configuration Panel
                VStack(alignment: .leading, spacing: ReMasteraDesign.space24) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: ReMasteraDesign.space24) {
                            Text("TARGET PRESET")
                                .font(ReMasteraType.label(12))
                                .tracking(2)
                                .foregroundStyle(ReMasteraDesign.brand)
                            
                            VStack(spacing: ReMasteraDesign.space12) {
                                ForEach(Preset.allCases) { preset in
                                    PresetRow(
                                        preset: preset,
                                        isSelected: selectedPreset == preset,
                                        action: { selectedPreset = preset }
                                    )
                                }
                            }
                            
                            Text("ENHANCEMENTS")
                                .font(ReMasteraType.label(12))
                                .tracking(2)
                                .foregroundStyle(ReMasteraDesign.brand)
                                .padding(.top, ReMasteraDesign.space16)
                            
                            VStack(spacing: 0) {
                                DashboardToggle(title: "Standard Denoise (hqdn3d)", isOn: $isDenoiseEnabled)
                                Divider().background(ReMasteraDesign.borderSubtle)
                                DashboardToggle(title: "Kodak Film Look (5247)", isOn: $isFilmLookEnabled)
                                Divider().background(ReMasteraDesign.borderSubtle)
                                DashboardToggle(title: "Subtitle Extraction", isOn: $isSubtitleEnabled)
                                Divider().background(ReMasteraDesign.borderSubtle)
                                DashboardToggle(title: "Neural Upscale (RealESRGAN)", isOn: $isUpscaleEnabled)
                                Divider().background(ReMasteraDesign.borderSubtle)
                                DashboardToggle(title: "HDR10 Tagging", isOn: $isHdr10Enabled)
                            }
                            .background(ReMasteraDesign.surfaceElevated)
                            .clipShape(RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase))
                            .overlay(
                                RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase)
                                    .stroke(ReMasteraDesign.borderSubtle, lineWidth: 1)
                            )
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: ReMasteraDesign.space8) {
                        Text("SYSTEM READY")
                            .font(ReMasteraType.caption(10))
                            .tracking(2)
                            .foregroundStyle(ReMasteraDesign.success)
                        Text("Awaiting input stream...")
                            .font(ReMasteraType.body(12))
                            .foregroundStyle(ReMasteraDesign.body)
                    }
                    .padding(ReMasteraDesign.space16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(ReMasteraDesign.surfaceElevated)
                    .clipShape(RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase))
                    .overlay(
                        RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase)
                            .stroke(ReMasteraDesign.borderSubtle, lineWidth: 1)
                    )
                }
                .padding(ReMasteraDesign.space32)
                .frame(width: 320)
                .background(ReMasteraDesign.surface)
            }
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        var handled = false
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.movie.identifier, options: nil) { item, error in
                    guard let data = item as? Data,
                          let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
                    DispatchQueue.main.async {
                        queueJob(url: url)
                    }
                }
                handled = true
            } else if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
                    guard let data = item as? Data,
                          let urlString = String(data: data, encoding: .utf8),
                          let url = URL(string: urlString) else { return }
                    DispatchQueue.main.async {
                        queueJob(url: url)
                    }
                }
                handled = true
            }
        }
        return handled
    }
    
    private func queueJob(url: URL) {
        let outputDir = URL(fileURLWithPath: NSHomeDirectory() + "/Movies/ReMastera_Processed")
        try? FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
        
        var tags = [selectedPreset.displayName.replacingOccurrences(of: " ", with: "")]
        if isDenoiseEnabled { tags.append("Denoised") }
        if isFilmLookEnabled { tags.append("Kodak5247") }
        if isSubtitleEnabled { tags.append("Subs") }
        if isUpscaleEnabled { tags.append("Upscaled") }
        if isHdr10Enabled { tags.append("HDR10") }
        
        let destinationURL = OutputPathBuilder.buildOutputPath(
            sourceURL: url,
            inputDirectoryURL: nil,
            outputDirectoryURL: outputDir,
            tags: tags,
            overwritePolicy: .createNumberedCopy
        )
        
        queueManager.addJob(
            sourceURL: url,
            destinationURL: destinationURL,
            preset: selectedPreset,
            isDenoiseEnabled: isDenoiseEnabled,
            isFilmLookEnabled: isFilmLookEnabled,
            isSubtitleEnabled: isSubtitleEnabled,
            isUpscaleEnabled: isUpscaleEnabled,
            isHdr10Enabled: isHdr10Enabled
        )
    }
}

struct DashboardToggle: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(ReMasteraType.label(12))
                .foregroundStyle(ReMasteraDesign.heading)
            Spacer()
            Toggle("", isOn: $isOn)
                .toggleStyle(.switch)
                .tint(ReMasteraDesign.brand)
                .controlSize(.small)
        }
        .padding(ReMasteraDesign.space12)
    }
}

struct PresetRow: View {
    let preset: Preset
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: ReMasteraDesign.space12) {
                ZStack {
                    Circle()
                        .stroke(isSelected ? ReMasteraDesign.brand : ReMasteraDesign.borderSubtle, lineWidth: 1.5)
                        .frame(width: 16, height: 16)
                    
                    if isSelected {
                        Circle()
                            .fill(ReMasteraDesign.brand)
                            .frame(width: 8, height: 8)
                            .shadow(color: ReMasteraDesign.brand.opacity(0.8), radius: 4)
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(preset.displayName)
                        .font(ReMasteraType.label(14))
                        .foregroundStyle(isSelected ? ReMasteraDesign.heading : ReMasteraDesign.body)
                    Text(preset.description)
                        .font(ReMasteraType.caption(11))
                        .foregroundStyle(ReMasteraDesign.fgDisabled)
                }
                Spacer()
            }
            .padding(ReMasteraDesign.space12)
            .background(
                isSelected ? ReMasteraDesign.brandSofter :
                (isHovered ? ReMasteraDesign.surfaceElevated : .clear)
            )
            .clipShape(RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase))
            .overlay(
                RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase)
                    .stroke(isSelected ? ReMasteraDesign.borderSubtle : .clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.15)) { isHovered = hovering }
        }
    }
}
