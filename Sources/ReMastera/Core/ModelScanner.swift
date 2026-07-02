import Foundation

public struct ModelScanner {
    /// Scans standard model directories (Homebrew, Downloads, Cache) for .bin/.pt files and symlinks them
    public static func scanForAudioModels() {
        let fileManager = FileManager.default
        let homeDir = fileManager.homeDirectoryForCurrentUser
        
        let searchPaths: [URL] = [
            homeDir.appendingPathComponent("Downloads"),
            homeDir.appendingPathComponent(".cache/whisper"),
            homeDir.appendingPathComponent(".cache/huggingface"),
            URL(fileURLWithPath: "/opt/homebrew/share")
        ]
        
        let remasteraModelDir = homeDir.appendingPathComponent(".remastera/models")
        
        do {
            try fileManager.createDirectory(at: remasteraModelDir, withIntermediateDirectories: true)
            
            for path in searchPaths {
                guard fileManager.fileExists(atPath: path.path) else { continue }
                
                // Shallow search to prevent heavy CPU usage/hangs
                if let enumerator = fileManager.enumerator(at: path, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
                    
                    for case let fileURL as URL in enumerator {
                        if fileURL.pathExtension == "bin" || fileURL.pathExtension == "pt" || fileURL.pathExtension == "gguf" {
                            if fileURL.lastPathComponent.lowercased().contains("whisper") || fileURL.lastPathComponent.lowercased().contains("model") {
                                
                                let symlinkPath = remasteraModelDir.appendingPathComponent(fileURL.lastPathComponent)
                                if !fileManager.fileExists(atPath: symlinkPath.path) {
                                    do {
                                        try fileManager.createSymbolicLink(at: symlinkPath, withDestinationURL: fileURL)
                                        print("Created symlink for model: \(fileURL.lastPathComponent)")
                                    } catch {
                                        print("Failed to symlink \(fileURL.lastPathComponent): \(error)")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } catch {
            print("Failed to create model directory: \(error)")
        }
    }
}
