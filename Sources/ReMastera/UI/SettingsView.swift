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
            // Header
            HStack {
                VStack(alignment: .leading, spacing: ReMasteraDesign.space4) {
                    Text("SYSTEM CONFIGURATION")
                        .font(ReMasteraType.heading(24))
                        .foregroundStyle(ReMasteraDesign.heading)
                    Text("Modify global operation parameters and default overrides.")
                        .font(ReMasteraType.body(14))
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
                        Text("GLOBAL PARAMETERS")
                            .font(ReMasteraType.label(12))
                            .tracking(2)
                            .foregroundStyle(ReMasteraDesign.brand)
                        
                        VStack(spacing: 0) {
                            TerminalToggle(title: "Launch ReMastera at login", isOn: $launchAtLogin)
                            Divider().background(ReMasteraDesign.borderSubtle)
                            TerminalToggle(title: "Preserve intermediate debug frames (requires extra storage)", isOn: $keepTempFiles)
                        }
                        .background(ReMasteraDesign.surfaceElevated)
                        .clipShape(RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase))
                        .overlay(
                            RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase)
                                .stroke(ReMasteraDesign.borderSubtle, lineWidth: 1)
                        )
                    }
                    
                    // Processing Defaults
                    VStack(alignment: .leading, spacing: ReMasteraDesign.space16) {
                        Text("PROCESSING DEFAULTS")
                            .font(ReMasteraType.label(12))
                            .tracking(2)
                            .foregroundStyle(ReMasteraDesign.brand)
                        
                        VStack(spacing: 0) {
                            // Preset Picker
                            HStack {
                                Text("Target Preset")
                                    .font(ReMasteraType.label(14))
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
                                    .font(ReMasteraType.label(14))
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
                                    .font(ReMasteraType.label(14))
                                    .foregroundStyle(ReMasteraDesign.heading)
                                
                                HStack {
                                    Text(defaultOutputFolder)
                                        .font(ReMasteraType.caption(12))
                                        .foregroundStyle(ReMasteraDesign.brand)
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                    Spacer()
                                    Button(action: selectDefaultFolder) {
                                        Text("BROWSE")
                                            .font(ReMasteraType.label(11))
                                            .tracking(1)
                                            .foregroundStyle(ReMasteraDesign.heading)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(ReMasteraDesign.surface)
                                            .clipShape(RoundedRectangle(cornerRadius: 4))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 4)
                                                    .stroke(ReMasteraDesign.borderSubtle, lineWidth: 1)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(12)
                                .background(ReMasteraDesign.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                            .padding(ReMasteraDesign.space16)
                        }
                        .background(ReMasteraDesign.surfaceElevated)
                        .clipShape(RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase))
                        .overlay(
                            RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase)
                                .stroke(ReMasteraDesign.borderSubtle, lineWidth: 1)
                        )
                    }
                    
                    // About
                    VStack(alignment: .leading, spacing: ReMasteraDesign.space8) {
                        Text("ReMastera MacOS Media Processing Suite")
                            .font(ReMasteraType.label(14))
                            .foregroundStyle(ReMasteraDesign.heading)
                        Text("Version 1.0.0 (Build 1)")
                            .font(ReMasteraType.caption(12))
                            .foregroundStyle(ReMasteraDesign.brand)
                        Text("Developed locally for private, offline video enhancements on Apple Silicon.")
                            .font(ReMasteraType.body(12))
                            .foregroundStyle(ReMasteraDesign.fgDisabled)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, ReMasteraDesign.space32)
                }
                .padding(ReMasteraDesign.space32)
            }
        }
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

struct TerminalToggle: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(ReMasteraType.label(14))
                .foregroundStyle(ReMasteraDesign.heading)
            Spacer()
            Toggle("", isOn: $isOn)
                .toggleStyle(.switch)
                .tint(ReMasteraDesign.brand)
        }
        .padding(ReMasteraDesign.space16)
    }
}
