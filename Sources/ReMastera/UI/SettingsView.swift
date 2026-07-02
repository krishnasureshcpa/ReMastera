import SwiftUI

public struct SettingsView: View {
    @State private var defaultOutputFolder: String = "~/Movies/ReMastera_Processed"
    @State private var defaultPreset = Preset.balanced4K
    @State private var defaultOverwritePolicy = OverwritePolicy.createNumberedCopy
    @State private var launchAtLogin = false
    @State private var keepTempFiles = false
    
    public init() {}
    
    public var body: some View {
        Form {
            Section(header: Text("General Settings").font(.headline)) {
                Toggle("Launch ReMastera at login", isOn: $launchAtLogin)
                Toggle("Preserve intermediate debug frames (requires extra storage)", isOn: $keepTempFiles)
            }
            .padding(.bottom, 12)
            
            Section(header: Text("Processing Defaults").font(.headline)) {
                Picker("Default Target Preset:", selection: $defaultPreset) {
                    ForEach(Preset.allCases) { preset in
                        Text(preset.displayName).tag(preset)
                    }
                }
                
                Picker("Default Overwrite Behavior:", selection: $defaultOverwritePolicy) {
                    ForEach(OverwritePolicy.allCases, id: \.self) { policy in
                        Text(policy.rawValue.capitalized.replacingOccurrences(of: "-", with: " ")).tag(policy)
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Default Export Location:")
                        .font(.subheadline.bold())
                    HStack {
                        Text(defaultOutputFolder)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button("Change...") {
                            selectDefaultFolder()
                        }
                    }
                }
                .padding(.top, 4)
            }
            
            Divider()
                .padding(.vertical, 12)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("ReMastera MacOS Media Processing Suite")
                    .font(.subheadline.bold())
                Text("Version 1.0.0 (Build 1)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Developed locally for private, offline video enhancements on Apple Silicon.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
    
    private func selectDefaultFolder() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        
        if panel.runModal() == .OK, let url = panel.url {
            self.defaultOutputFolder = url.path
        }
    }
}
