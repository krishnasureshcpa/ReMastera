import Foundation

public enum OverwritePolicy: String, Codable, CaseIterable {
    case createNumberedCopy = "numbered-copy"
    case replaceExisting = "replace"
    case skipExisting = "skip"
}

public struct OutputPathBuilder {
    /// Builds a deterministic output URL mirroring the input folder structure and appending tags.
    public static func buildOutputPath(
        sourceURL: URL,
        inputDirectoryURL: URL?,
        outputDirectoryURL: URL,
        tags: [String],
        overwritePolicy: OverwritePolicy = .createNumberedCopy
    ) -> URL {
        let fileManager = FileManager.default
        
        // 1. Resolve output subpath for folder batch mirroring
        var targetDirectoryURL = outputDirectoryURL
        if let inputDir = inputDirectoryURL {
            let inputDirName = inputDir.lastPathComponent
            let processedFolderName = "\(inputDirName)_processed"
            
            // Find relative path from inputDir to sourceURL
            let sourcePath = sourceURL.deletingLastPathComponent().path
            let inputPath = inputDir.path
            
            if sourcePath.hasPrefix(inputPath) {
                let relativeSubpath = String(sourcePath.dropFirst(inputPath.count))
                // Clean leading/trailing slashes
                let cleanSubpath = relativeSubpath.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
                
                targetDirectoryURL = outputDirectoryURL.appendingPathComponent(processedFolderName)
                if !cleanSubpath.isEmpty {
                    targetDirectoryURL = targetDirectoryURL.appendingPathComponent(cleanSubpath)
                }
            } else {
                targetDirectoryURL = outputDirectoryURL.appendingPathComponent(processedFolderName)
            }
        }
        
        // 2. Prepare filename with sanitized tags
        let fileExtension = sourceURL.pathExtension
        let originalName = sourceURL.deletingPathExtension().lastPathComponent
        let sanitizedTags = TagSanitizer.sanitize(tags)
        
        var newFileName = originalName
        if !sanitizedTags.isEmpty {
            let tagsString = sanitizedTags.joined(separator: " ")
            newFileName = "\(originalName) \(tagsString)"
        }
        
        var finalURL = targetDirectoryURL.appendingPathComponent(newFileName).appendingPathExtension(fileExtension)
        
        // 3. Resolve overwrite policy
        if fileManager.fileExists(atPath: finalURL.path) {
            switch overwritePolicy {
            case .replaceExisting, .skipExisting:
                // Return finalURL directly; the encoder stage will handle skip/replace logic
                break
            case .createNumberedCopy:
                var counter = 2
                while true {
                    let numberedName = "\(newFileName) \(counter)"
                    let checkURL = targetDirectoryURL.appendingPathComponent(numberedName).appendingPathExtension(fileExtension)
                    if !fileManager.fileExists(atPath: checkURL.path) {
                        finalURL = checkURL
                        break
                    }
                    counter += 1
                }
            }
        }
        
        return finalURL
    }
}
