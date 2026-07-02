import SwiftUI
import AppKit

public struct SettingsView: View {
    @State private var defaultOutputFolder: String = "~/Movies/ReMastera_Processed"
    @State private var defaultPreset = Preset.balanced4K
    @State private var defaultOverwritePolicy = OverwritePolicy.createNumberedCopy
    @State private var launchAtLogin = false
    @State private var keepTempFiles = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Friendly Header
            HStack {
                VStack(alignment: .leading, spacing: ReMasteraDesign.space4) {
                    Text("System Configuration")
                        .font(ReMasteraType.heading(28))
                        .foregroundStyle(ReMasteraDesign.heading)
                    Text("Modify global operation parameters and default overrides.")
                        .font(ReMasteraType.body(15))
                        .foregroundStyle(ReMasteraDesign.body)
                }
                Spacer()
            }
            .padding(ReMasteraDesign.space32)
            
            SectionDivider()
            
            ScrollView {
                VStack(spacing: ReMasteraDesign.space32) {
                    // Global Parameters
                    VStack(alignment: .leading, spacing: ReMasteraDesign.space16) {
                        Text("Global Parameters")
                            .font(ReMasteraType.label(14))
                            .foregroundStyle(ReMasteraDesign.brandDeep)
                        
                        VStack(spacing: 0) {
                            GamifiedToggle(title: "Launch ReMastera at login", isOn: $launchAtLogin)
                            Divider().background(ReMasteraDesign.borderSubtle)
                            GamifiedToggle(title: "Preserve intermediate debug frames (requires extra storage)", isOn: $keepTempFiles)
                        }
                        .remasteraCard(interactive: false)
                    }
                    
                    // Processing Defaults
                    VStack(alignment: .leading, spacing: ReMasteraDesign.space16) {
                        Text("Processing Defaults")
                            .font(ReMasteraType.label(14))
                            .foregroundStyle(ReMasteraDesign.brandDeep)
                        
                        VStack(spacing: 0) {
                            // Preset Picker
                            HStack {
                                Text("Target Preset")
                                    .font(ReMasteraType.label(16))
                                    .foregroundStyle(ReMasteraDesign.heading)
                                Spacer()
                                Picker("", selection: $defaultPreset) {
                                    ForEach(Preset.allCases) { preset in
                                        Text(preset.displayName).tag(preset)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(width: 180)
                            }
                            .padding(ReMasteraDesign.space16)
                            
                            Divider().background(ReMasteraDesign.borderSubtle)
                            
                            // Overwrite Policy
                            HStack {
                                Text("Overwrite Policy")
                                    .font(ReMasteraType.label(16))
                                    .foregroundStyle(ReMasteraDesign.heading)
                                Spacer()
                                Picker("", selection: $defaultOverwritePolicy) {
                                    ForEach(OverwritePolicy.allCases, id: \.self) { policy in
                                        Text(policy.rawValue.capitalized.replacingOccurrences(of: "-", with: " ")).tag(policy)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(width: 180)
                            }
                            .padding(ReMasteraDesign.space16)
                            
                            Divider().background(ReMasteraDesign.borderSubtle)
                            
                            // Output Directory
                            VStack(alignment: .leading, spacing: ReMasteraDesign.space12) {
                                Text("Output Directory")
                                    .font(ReMasteraType.label(16))
                                    .foregroundStyle(ReMasteraDesign.heading)
                                
                                HStack {
                                    Text(defaultOutputFolder)
                                        .font(ReMasteraType.code(12))
                                        .foregroundStyle(ReMasteraDesign.brandDeep)
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                    Spacer()
                                    Button(action: selectDefaultFolder) {
                                        Text("Browse")
                                            .font(ReMasteraType.label(12))
                                            .foregroundStyle(ReMasteraDesign.heading)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 6)
                                            .background(ReMasteraDesign.surfaceElevated)
                                            .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(12)
                                .background(ReMasteraDesign.surfaceElevated.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .padding(ReMasteraDesign.space16)
                        }
                        .remasteraCard(interactive: false)
                    }
                    
                    // About
                    VStack(alignment: .leading, spacing: ReMasteraDesign.space8) {
                        Text("ReMastera macOS Media Processing Suite")
                            .font(ReMasteraType.label(14))
                            .foregroundStyle(ReMasteraDesign.heading)
                        Text("Version 1.0.0 (Build 2)")
                            .font(ReMasteraType.caption(12))
                            .foregroundStyle(ReMasteraDesign.brand)
                        Text("Developed locally for private, offline video enhancements on Apple Silicon.")
                            .font(ReMasteraType.body(14))
                            .foregroundStyle(ReMasteraDesign.bodySubtle)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, ReMasteraDesign.space32)
                }
                .padding(ReMasteraDesign.space32)
            }
        }
        .background(ReMasteraDesign.background)
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

struct GamifiedToggle: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(ReMasteraType.label(16))
                .foregroundStyle(ReMasteraDesign.heading)
            Spacer()
            Toggle("", isOn: $isOn)
                .toggleStyle(.switch)
                .tint(ReMasteraDesign.brand)
        }
        .padding(ReMasteraDesign.space16)
    }
}
