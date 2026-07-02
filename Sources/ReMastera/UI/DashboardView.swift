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
        VStack(spacing: ReMasteraDesign.space24) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: ReMasteraDesign.space8) {
                    SwissMixedHeading(prefix: "[01]", title: "READY TO REMASTER", suffix: "v1.0.0")
                    Text("Drag a video into the zone below or choose your enhancements.")
                        .font(ReMasteraType.body())
                        .foregroundStyle(ReMasteraDesign.body)
                }
                Spacer()
                
                // Gamified "Start" button placeholder if we had a file
                Button(action: {}) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Process Queue")
                    }
                    .font(ReMasteraType.label(15))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(ReMasteraDesign.primary)
                    .clipShape(Capsule())
                    .shadow(color: ReMasteraDesign.primary.opacity(0.3), radius: 8, y: 4)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, ReMasteraDesign.space32)
            .padding(.horizontal, ReMasteraDesign.space32)
            
            HStack(spacing: ReMasteraDesign.space24) {
                // Left: Gamified Drop Zone
                ZStack {
                    RoundedRectangle(cornerRadius: ReMasteraDesign.radiusLg, style: .continuous)
                        .fill(isTargeted ? ReMasteraDesign.brand.opacity(0.1) : ReMasteraDesign.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: ReMasteraDesign.radiusLg, style: .continuous)
                                .strokeBorder(
                                    isTargeted ? ReMasteraDesign.brand : ReMasteraDesign.borderSubtle,
                                    style: StrokeStyle(lineWidth: isTargeted ? 3 : 2, dash: isTargeted ? [15] : [])
                                )
                        )
                    
                    VStack(spacing: ReMasteraDesign.space16) {
                        Image(systemName: isTargeted ? "arrow.down.circle.fill" : "plus.circle.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(isTargeted ? ReMasteraDesign.brand : ReMasteraDesign.borderSubtle)
                            .scaleEffect(isTargeted ? 1.1 : 1.0)
                            .animation(ReMasteraDesign.springBouncy, value: isTargeted)
                        
                        VStack(spacing: ReMasteraDesign.space4) {
                            Text("Drop video files here")
                                .font(ReMasteraType.subheading())
                                .foregroundStyle(ReMasteraDesign.heading)
                            Text("MP4, MOV, or MKV")
                                .font(ReMasteraType.body())
                                .foregroundStyle(ReMasteraDesign.body)
                        }
                    }
                }
                .remasteraCard(interactive: true)
                .onDrop(of: [UTType.movie, UTType.video], isTargeted: $isTargeted) { providers in
                    handleDrop(providers: providers)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Right: Configuration Panel
                VStack(alignment: .leading, spacing: ReMasteraDesign.space24) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: ReMasteraDesign.space24) {
                            
                            VStack(alignment: .leading, spacing: ReMasteraDesign.space12) {
                                Text("Quality Preset")
                                    .font(ReMasteraType.label())
                                    .foregroundStyle(ReMasteraDesign.heading)
                                
                                ForEach(Preset.allCases) { preset in
                                    PresetRow(
                                        preset: preset,
                                        isSelected: selectedPreset == preset,
                                        action: {
                                            withAnimation(ReMasteraDesign.springBouncy) {
                                                selectedPreset = preset
                                            }
                                        }
                                    )
                                }
                            }
                            
                            SectionDivider()
                            
                            VStack(alignment: .leading, spacing: ReMasteraDesign.space16) {
                                Text("Enhancements")
                                    .font(ReMasteraType.label())
                                    .foregroundStyle(ReMasteraDesign.heading)
                                
                                VStack(spacing: ReMasteraDesign.space12) {
                                    EnhancementToggle(title: "AI Denoise", icon: "sparkles", isOn: $isDenoiseEnabled)
                                    EnhancementToggle(title: "Kodak Film Look", icon: "film", isOn: $isFilmLookEnabled)
                                    EnhancementToggle(title: "Extract Subtitles", icon: "text.bubble", isOn: $isSubtitleEnabled)
                                    EnhancementToggle(title: "Neural Upscale", icon: "arrow.up.left.and.arrow.down.right", isOn: $isUpscaleEnabled)
                                    EnhancementToggle(title: "HDR10 Tagging", icon: "sun.max.fill", isOn: $isHdr10Enabled)
                                }
                            }
                        }
                        .padding(ReMasteraDesign.space4)
                    }
                }
                .frame(width: 320)
            }
            .padding(.horizontal, ReMasteraDesign.space32)
            .padding(.bottom, ReMasteraDesign.space32)
        }
        .background(ReMasteraDesign.background)
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

// MARK: - Gamified Toggles and Rows

struct EnhancementToggle: View {
    let title: String
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: ReMasteraDesign.space12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(isOn ? ReMasteraDesign.brand : ReMasteraDesign.bodySubtle)
                .frame(width: 24)
            
            Text(title)
                .font(ReMasteraType.body())
                .foregroundStyle(ReMasteraDesign.heading)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(.switch)
                .tint(ReMasteraDesign.primary)
        }
        .padding(ReMasteraDesign.space12)
        .background(ReMasteraDesign.surface)
        .clipShape(RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase, style: .continuous)
                .stroke(isOn ? ReMasteraDesign.brand.opacity(0.3) : ReMasteraDesign.borderSubtle, lineWidth: 1)
        )
        .animation(ReMasteraDesign.springBouncy, value: isOn)
    }
}

struct PresetRow: View {
    let preset: Preset
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isHovered = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: ReMasteraDesign.space16) {
                // Radio button circle
                ZStack {
                    Circle()
                        .stroke(isSelected ? ReMasteraDesign.brand : ReMasteraDesign.borderSubtle, lineWidth: 2)
                        .frame(width: 20, height: 20)
                    
                    if isSelected {
                        Circle()
                            .fill(ReMasteraDesign.brand)
                            .frame(width: 10, height: 10)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(preset.displayName)
                        .font(ReMasteraType.label())
                        .foregroundStyle(isSelected ? ReMasteraDesign.brandDeep : ReMasteraDesign.heading)
                    Text(preset.description)
                        .font(ReMasteraType.caption())
                        .foregroundStyle(ReMasteraDesign.body)
                }
                Spacer()
            }
            .padding(ReMasteraDesign.space16)
            .background(
                isSelected ? ReMasteraDesign.brand.opacity(0.1) :
                (isHovered ? ReMasteraDesign.surfaceElevated : ReMasteraDesign.surface)
            )
            .clipShape(RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase, style: .continuous)
                    .stroke(isSelected ? ReMasteraDesign.brand : ReMasteraDesign.borderSubtle, lineWidth: isSelected ? 2 : 1)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(ReMasteraDesign.springBouncy, value: isSelected)
            .animation(ReMasteraDesign.springBouncy, value: isHovered)
            .animation(ReMasteraDesign.springBouncy, value: isPressed)
        }
        .buttonStyle(.plain)
        .onHover { hovering in isHovered = hovering }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}
