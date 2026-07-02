import SwiftUI
import AppKit

public struct DashboardView: View {
    @Bindable var queueManager: QueueManager
    
    // Selection state
    @State private var sourceURL: URL? = nil
    @State private var isDirectorySource = false
    @State private var discoveredVideos: [URL] = []
    
    @State private var outputDirectoryURL: URL? = nil
    @State private var isMirrorEnabled = false
    @State private var selectedPreset = Preset.balanced4K
    @State private var selectedOverwritePolicy = OverwritePolicy.createNumberedCopy
    
    // Pipeline flags
    @State private var isDenoiseEnabled = true
    @State private var isFilmLookEnabled = true
    @State private var isSubtitleEnabled = false
    @State private var isUpscaleEnabled = true
    @State private var isHdr10Enabled = true
    
    @State private var isDraggingOver = false
    
    public init(queueManager: QueueManager) {
        self.queueManager = queueManager
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Left Content: Source Selection & Info
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Cinematic Restoration Workspace")
                            .font(.title2.bold())
                        Text("Import video assets and configure processing pipelines locally.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    // Ingestion drop zone
                    dropZone
                        .frame(height: 180)
                    
                    if sourceURL != nil {
                        sourceMetadataPanel
                    }
                    
                    // Pipeline configuration checklist
                    pipelineStagesPanel
                }
                .padding()
            }
            .frame(maxWidth: .infinity)
            
            Divider()
            
            // Right Inspector Panel: Settings & Bitrate Size Estimator
            inspectorPanel
        }
        .onAppear {
            setDefaultPaths()
        }
    }
    
    // Ingestion drop zone
    private var dropZone: some View {
        VStack(spacing: 16) {
            Image(systemName: isDirectorySource ? "folder.badge.plus" : "film.badge.plus")
                .font(.system(size: 40))
                .foregroundStyle(isDraggingOver ? Color.accentColor : Color.secondary)
            
            VStack(spacing: 6) {
                Text(sourceURL == nil ? "Drag and drop video files or folders here" : (isDirectorySource ? "Folder Loaded" : "Video File Loaded"))
                    .font(.headline)
                Text("Supports mp4, mov, mkv, avi, m4v, and webm")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 12) {
                Button(action: selectFile) {
                    Label("Select File", systemImage: "doc")
                }
                .buttonStyle(.bordered)
                
                Button(action: selectFolder) {
                    Label("Select Folder", systemImage: "folder")
                }
                .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(isDraggingOver ? Color.accentColor.opacity(0.06) : Color.secondary.opacity(0.03))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isDraggingOver ? Color.accentColor : Color.secondary.opacity(0.15), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .bevel, dash: [6, 4]))
        )
        .onDrop(of: [.fileURL], isTargeted: $isDraggingOver) { providers in
            guard let provider = providers.first else { return false }
            _ = provider.loadObject(ofClass: URL.self) { url, _ in
                if let localURL = url {
                    DispatchQueue.main.sync {
                        loadURL(localURL)
                    }
                }
            }
            return true
        }
    }
    
    // Discovered video details panel
    private var sourceMetadataPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Source Metadata")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Type:")
                        .bold()
                        .frame(width: 80, alignment: .leading)
                    Text(isDirectorySource ? "Directory Batch" : "Single Video File")
                }
                HStack {
                    Text("Location:")
                        .bold()
                        .frame(width: 80, alignment: .leading)
                    Text(sourceURL?.path ?? "")
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .font(.system(.caption, design: .monospaced))
                }
                
                if isDirectorySource {
                    HStack {
                        Text("Discovered:")
                            .bold()
                            .frame(width: 80, alignment: .leading)
                        Text("\(discoveredVideos.count) video assets")
                            .bold()
                            .foregroundStyle(.tint)
                    }
                }
            }
            .font(.subheadline)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.secondary.opacity(0.04))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.secondary.opacity(0.08), lineWidth: 1)
            )
        }
    }
    
    // Toggle switches for stages
    private var pipelineStagesPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Modular Enhancement Pipeline")
                .font(.headline)
            
            VStack(spacing: 0) {
                stageToggle(title: "Standard Denoise", description: "Softens grain and luma/chroma noise using hqdn3d filter.", isOn: $isDenoiseEnabled, isRequired: false)
                Divider()
                stageToggle(title: "Kodak 5247-inspired Look", description: "Applies warm highlight grading and slight cyan shadow balance.", isOn: $isFilmLookEnabled, isRequired: false)
                Divider()
                stageToggle(title: "Standard Upscale (4K)", description: "Rescales input resolution up to 3840x2160 via Lanczos interpolation.", isOn: $isUpscaleEnabled, isRequired: false)
                Divider()
                stageToggle(title: "HDR10 Compatibility", description: "Tags output container with Rec.2020 color coordinates and PQ transfer curve.", isOn: $isHdr10Enabled, isRequired: false)
                Divider()
                stageToggle(title: "Subtitle Extraction", description: "Extracts soft-subtitles locally using whisper.cpp backend (requires optional tool).", isOn: $isSubtitleEnabled, isRequired: false)
            }
            .background(Color.secondary.opacity(0.03))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.secondary.opacity(0.08), lineWidth: 1)
            )
        }
    }
    
    // Individual stage toggle view
    @ViewBuilder
    private func stageToggle(title: String, description: String, isOn: Binding<Bool>, isRequired: Bool) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if isRequired {
                Text("Locked")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            } else {
                Toggle("", isOn: isOn)
                    .labelsHidden()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
    
    // Sidebar inspector panel for preset and sizing parameters
    private var inspectorPanel: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Export settings")
                .font(.headline)
                .padding(.bottom, 4)
            
            // Preset configuration
            VStack(alignment: .leading, spacing: 8) {
                Text("Export Preset")
                    .font(.subheadline.bold())
                Picker("", selection: $selectedPreset) {
                    ForEach(Preset.allCases) { preset in
                        Text(preset.displayName).tag(preset)
                    }
                }
                .labelsHidden()
                
                Text(selectedPreset.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }
            
            // Bitrates display
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Target Video:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(Int(selectedPreset.videoBitrateMbps)) Mbps")
                        .font(.caption.bold())
                }
                HStack {
                    Text("Target Audio:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(Int(selectedPreset.audioBitrateKbps)) kbps")
                        .font(.caption.bold())
                }
            }
            .padding(10)
            .background(Color.secondary.opacity(0.05))
            .cornerRadius(6)
            
            Divider()
            
            // Destination settings
            VStack(alignment: .leading, spacing: 8) {
                Text("Output Directory")
                    .font(.subheadline.bold())
                
                HStack(spacing: 8) {
                    Text(outputDirectoryURL?.path ?? "Choose folder...")
                        .font(.system(.caption, design: .monospaced))
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Spacer()
                    Button("Choose...") { selectOutputFolder() }
                        .buttonStyle(.bordered)
                }
                
                Toggle("Mirror Folder Structure", isOn: $isMirrorEnabled)
                    .disabled(!isDirectorySource)
                    .font(.caption)
                
                Picker("Overwrite Policy", selection: $selectedOverwritePolicy) {
                    Text("Numbered Copy").tag(OverwritePolicy.createNumberedCopy)
                    Text("Replace Existing").tag(OverwritePolicy.replaceExisting)
                    Text("Skip Existing").tag(OverwritePolicy.skipExisting)
                }
                .font(.caption)
            }
            
            Divider()
            
            // Size estimator box
            VStack(alignment: .leading, spacing: 8) {
                Text("Estimated output size")
                    .font(.subheadline.bold())
                Text("Compact encoding options guarantee clean results without storage bloating.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                let sampleEstimate = SizeEstimator.estimateSize(
                    durationSeconds: 180.0, // base estimation on a 3-minute sample
                    videoBitrateMbps: selectedPreset.videoBitrateMbps,
                    audioBitrateKbps: selectedPreset.audioBitrateKbps
                )
                
                HStack {
                    Image(systemName: "opticaldisc")
                    Text("Sample 3-min Clip: ~\(SizeEstimator.formatBytes(sampleEstimate))")
                        .font(.subheadline.monospacedDigit().bold())
                }
                .padding(.top, 4)
                .foregroundStyle(.tint)
            }
            
            Spacer()
            
            Button(action: addJobsToQueue) {
                Text(isDirectorySource ? "Queue Batch (\(discoveredVideos.count) items)" : "Queue Video Asset")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(sourceURL == nil || outputDirectoryURL == nil || (isDirectorySource && discoveredVideos.isEmpty))
        }
        .padding()
        .frame(width: 280)
        .background(Color.secondary.opacity(0.02))
    }
    
    private func setDefaultPaths() {
        let fileManager = FileManager.default
        let homeDir = fileManager.homeDirectoryForCurrentUser
        let defaultOutput = homeDir.appendingPathComponent("Movies/ReMastera_Processed")
        try? fileManager.createDirectory(at: defaultOutput, withIntermediateDirectories: true)
        self.outputDirectoryURL = defaultOutput
    }
    
    private func selectFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.movie, .video, .quickTimeMovie, .mpeg4Movie]
        
        if panel.runModal() == .OK, let url = panel.url {
            loadURL(url)
        }
    }
    
    private func selectFolder() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        
        if panel.runModal() == .OK, let url = panel.url {
            loadURL(url)
        }
    }
    
    private func selectOutputFolder() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        
        if panel.runModal() == .OK, let url = panel.url {
            self.outputDirectoryURL = url
        }
    }
    
    private func loadURL(_ url: URL) {
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) {
            self.sourceURL = url
            self.isDirectorySource = isDir.boolValue
            
            if isDir.boolValue {
                scanFolderForVideos(url)
                self.isMirrorEnabled = true
            } else {
                self.discoveredVideos = []
                self.isMirrorEnabled = false
            }
        }
    }
    
    private func scanFolderForVideos(_ url: URL) {
        let fileManager = FileManager.default
        let supportedExtensions = ["mp4", "mov", "mkv", "avi", "m4v", "webm"]
        var videos: [URL] = []
        
        if let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles]) {
            for case let fileURL as URL in enumerator {
                if supportedExtensions.contains(fileURL.pathExtension.lowercased()) {
                    videos.append(fileURL)
                }
            }
        }
        
        self.discoveredVideos = videos
    }
    
    private func addJobsToQueue() {
        guard let outputDir = outputDirectoryURL else { return }
        
        if isDirectorySource {
            for videoURL in discoveredVideos {
                let destURL = OutputPathBuilder.buildOutputPath(
                    sourceURL: videoURL,
                    inputDirectoryURL: sourceURL,
                    outputDirectoryURL: outputDir,
                    tags: getActiveTags(),
                    overwritePolicy: selectedOverwritePolicy
                )
                
                queueManager.addJob(
                    sourceURL: videoURL,
                    destinationURL: destURL,
                    preset: selectedPreset,
                    isDenoiseEnabled: isDenoiseEnabled,
                    isFilmLookEnabled: isFilmLookEnabled,
                    isSubtitleEnabled: isSubtitleEnabled,
                    isUpscaleEnabled: isUpscaleEnabled,
                    isHdr10Enabled: isHdr10Enabled
                )
            }
        } else if let fileURL = sourceURL {
            let destURL = OutputPathBuilder.buildOutputPath(
                sourceURL: fileURL,
                inputDirectoryURL: nil,
                outputDirectoryURL: outputDir,
                tags: getActiveTags(),
                overwritePolicy: selectedOverwritePolicy
            )
            
            queueManager.addJob(
                sourceURL: fileURL,
                destinationURL: destURL,
                preset: selectedPreset,
                isDenoiseEnabled: isDenoiseEnabled,
                isFilmLookEnabled: isFilmLookEnabled,
                isSubtitleEnabled: isSubtitleEnabled,
                isUpscaleEnabled: isUpscaleEnabled,
                isHdr10Enabled: isHdr10Enabled
            )
        }
        
        // Reset selections after queuing
        self.sourceURL = nil
        self.discoveredVideos = []
        self.isDirectorySource = false
    }
    
    private func getActiveTags() -> [String] {
        return [
            isDenoiseEnabled ? "denoised" : nil,
            isFilmLookEnabled ? "kodak" : nil,
            isSubtitleEnabled ? "subtitles" : nil,
            isUpscaleEnabled ? "upscaled" : nil,
            isHdr10Enabled ? "hdr10" : nil
        ].compactMap { $0 }
    }
}
