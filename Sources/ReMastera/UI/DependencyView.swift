import SwiftUI

public struct DependencyView: View {
    @State private var dependencies: [DependencyInfo] = []
    @State private var isScanning = false
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Dependency Manager")
                        .font(.title2.bold())
                    Text("ReMastera executes local CLI tools privately. No files are uploaded.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button(action: scan) {
                    Label(isScanning ? "Scanning..." : "Rescan Tools", systemImage: "arrow.clockwise")
                }
                .disabled(isScanning)
                .buttonStyle(.bordered)
            }
            .padding(.bottom, 8)
            
            if dependencies.isEmpty {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Initializing tools configuration...")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(dependencies) { dep in
                            dependencyRow(dep)
                        }
                    }
                    .padding(.trailing, 8)
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Developer Bootstrap Guide")
                    .font(.headline)
                Text("ReMastera will never silently download or install packages. To bootstrap dependencies manually, use the project command-line utility:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text("./scripts/bootstrap.sh")
                    .font(.system(.subheadline, design: .monospaced))
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(6)
            }
            .padding(.top, 8)
        }
        .padding()
        .onAppear(perform: scan)
    }
    
    private func scan() {
        isScanning = true
        // Query in background
        DispatchQueue.global(qos: .userInitiated).async {
            let results = DependencyDetector.scanDependencies()
            DispatchQueue.main.async {
                self.dependencies = results
                self.isScanning = false
            }
        }
    }
    
    @ViewBuilder
    private func dependencyRow(_ dep: DependencyInfo) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: dep.isInstalled ? "checkmark.circle.fill" : (dep.isRequired ? "xmark.circle.fill" : "exclamationmark.triangle.fill"))
                .font(.system(size: 24))
                .foregroundStyle(dep.isInstalled ? .green : (dep.isRequired ? .red : .yellow))
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(dep.name)
                        .font(.headline)
                    Text(dep.isRequired ? "(Required)" : "(Optional)")
                        .font(.caption)
                        .foregroundStyle(dep.isRequired ? .primary : .secondary)
                    
                    if let version = dep.version {
                        Text("v\(version)")
                            .font(.caption.monospaced())
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.secondary.opacity(0.15))
                            .cornerRadius(4)
                    }
                }
                
                Text(dep.purpose)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                if dep.isInstalled, let path = dep.path {
                    Text("Location: \(path)")
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Missing dependency. To install, run:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(dep.installCommand)
                            .font(.caption.monospaced())
                            .padding(6)
                            .background(Color(nsColor: .textBackgroundColor))
                            .cornerRadius(4)
                    }
                    .padding(.top, 4)
                }
            }
            Spacer()
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
        )
    }
}
