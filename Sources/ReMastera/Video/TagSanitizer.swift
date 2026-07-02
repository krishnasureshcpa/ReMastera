import Foundation

public struct TagSanitizer {
    /// Sanitizes, lowercases, deduplicates, and alphabetizes processing tags.
    public static func sanitize(_ tags: [String]) -> [String] {
        let cleaned = tags.map { tag in
            tag.lowercased()
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .components(separatedBy: CharacterSet.alphanumerics.inverted)
                .joined(separator: "")
        }
        .filter { !$0.isEmpty }
        
        let unique = Set(cleaned)
        return unique.sorted()
    }
}
