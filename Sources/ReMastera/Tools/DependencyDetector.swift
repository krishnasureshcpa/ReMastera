import Foundation

public struct DependencyInfo: Codable, Identifiable, Equatable {
    public var id: String { name }
    public let name: String
    public let isRequired: Bool
    public let path: String?
    public let version: String?
    public let isInstalled: Bool
    public let purpose: String
    public let installCommand: String
    
    public init(
        name: String,
        isRequired: Bool,
        path: String?,
        version: String?,
        isInstalled: Bool,
        purpose: String,
        installCommand: String
    ) {
        self.name = name
        self.isRequired = isRequired
        self.path = path
        self.version = version
        self.isInstalled = isInstalled
        self.purpose = purpose
        self.installCommand = installCommand
    }
}

public struct DependencyDetector {
    /// Scans standard system paths and environment PATH variables for a CLI tool.
    public static func locateTool(_ name: String) -> URL? {
        let fileManager = FileManager.default
        var searchDirectories = [
            "/opt/homebrew/bin",
            "/usr/local/bin",
            "/usr/bin",
            "/bin"
        ]
        
        // Append paths from the system PATH environment variable
        if let envPath = ProcessInfo.processInfo.environment["PATH"] {
            let envDirectories = envPath.components(separatedBy: ":")
            searchDirectories.append(contentsOf: envDirectories)
        }
        
        for directory in searchDirectories {
            let directoryURL = URL(fileURLWithPath: directory)
            let toolURL = directoryURL.appendingPathComponent(name)
            
            // Check if file exists and is executable
            if fileManager.fileExists(atPath: toolURL.path) && fileManager.isExecutableFile(atPath: toolURL.path) {
                return toolURL
            }
        }
        
        return nil
    }
    
    /// Queries the tool version by running it with `-version` or `--version`.
    public static func queryVersion(for toolURL: URL) -> String? {
        // Most multimedia CLI tools (ffmpeg, ffprobe, dovi_tool) output version info on stdout or stderr.
        // We will try running with "-version" first, then fallback to "--version".
        let arguments = ["-version"]
        do {
            let output = try ExternalToolRunner.runSync(executableURL: toolURL, arguments: arguments)
            return parseVersionString(output, for: toolURL.lastPathComponent)
        } catch {
            // Try "--version" fallback
            do {
                let output = try ExternalToolRunner.runSync(executableURL: toolURL, arguments: ["--version"])
                return parseVersionString(output, for: toolURL.lastPathComponent)
            } catch {
                return nil
            }
        }
    }
    
    /// Parses the version string from the output of the CLI command.
    private static func parseVersionString(_ rawOutput: String, for toolName: String) -> String {
        let lines = rawOutput.components(separatedBy: .newlines)
        guard let firstLine = lines.first else { return "Unknown version" }
        
        // Look for common version patterns
        // e.g. "ffmpeg version 7.0 Copyright (c) ..." -> "7.0"
        let components = firstLine.components(separatedBy: .whitespaces)
        if toolName.lowercased() == "ffmpeg" || toolName.lowercased() == "ffprobe" {
            if let versionIdx = components.firstIndex(of: "version"), versionIdx + 1 < components.count {
                return components[versionIdx + 1]
            }
        }
        
        // General fallback: return the first few words or the first line
        return firstLine.replacingOccurrences(of: "\(toolName) version ", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Scans the system for all known dependencies and returns their status.
    public static func scanDependencies() -> [DependencyInfo] {
        let tools = [
            ("ffmpeg", true, "Required for video decoding, filtering, and final encoding.", "brew install ffmpeg"),
            ("ffprobe", true, "Required for reading video metadata, resolution, and audio details.", "brew install ffmpeg"),
            ("whisper-cpp", false, "Enables offline subtitle extraction (Whisper backend).", "brew install whisper-cpp"),
            ("realesrgan-ncnn-vulkan", false, "Enables local AI-powered resolution upscaling.", "brew install realesrgan-ncnn-vulkan"),
            ("rife-ncnn-vulkan", false, "Enables local AI-powered video frame interpolation.", "brew install rife-ncnn-vulkan"),
            ("dovi_tool", false, "Enables Dolby Vision metadata injection and workflow.", "brew install dovi_tool")
        ]
        
        var results: [DependencyInfo] = []
        
        for (name, isRequired, purpose, installCmd) in tools {
            let actualName = name == "whisper-cpp" ? (locateTool("whisper-cpp") != nil ? "whisper-cpp" : "whisper-cli") : name
            if let url = locateTool(actualName) {
                let version = queryVersion(for: url) ?? "Found"
                results.append(DependencyInfo(
                    name: name,
                    isRequired: isRequired,
                    path: url.path,
                    version: version,
                    isInstalled: true,
                    purpose: purpose,
                    installCommand: installCmd
                ))
            } else {
                results.append(DependencyInfo(
                    name: name,
                    isRequired: isRequired,
                    path: nil,
                    version: nil,
                    isInstalled: false,
                    purpose: purpose,
                    installCommand: installCmd
                ))
            }
        }
        
        return results
    }
}
