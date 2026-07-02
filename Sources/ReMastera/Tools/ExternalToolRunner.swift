import Foundation

public enum ToolError: Error, LocalizedError {
    case executionFailed(String)
    case cancelled
    case nonZeroExitCode(Int32)
    
    public var errorDescription: String? {
        switch self {
        case .executionFailed(let msg): return "Tool execution failed: \(msg)"
        case .cancelled: return "Operation cancelled by user."
        case .nonZeroExitCode(let code): return "Process exited with non-zero code \(code)."
        }
    }
}

public struct ExternalToolRunner {
    /// Executes a command-line tool asynchronously, streaming output and supporting cancellation.
    public static func run(
        executableURL: URL,
        arguments: [String],
        onOutput: @escaping @Sendable (String) -> Void
    ) async throws {
        let process = Process()
        process.executableURL = executableURL
        process.arguments = arguments
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        // Wrap execution in a task that handles cancellation
        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                // Set up block to read file handles
                let outputHandle = outputPipe.fileHandleForReading
                let errorHandle = errorPipe.fileHandleForReading
                
                outputHandle.readabilityHandler = { handle in
                    let data = handle.availableData
                    if data.isEmpty {
                        outputHandle.readabilityHandler = nil
                    } else if let line = String(data: data, encoding: .utf8) {
                        onOutput(line.trimmingCharacters(in: .newlines))
                    }
                }
                
                errorHandle.readabilityHandler = { handle in
                    let data = handle.availableData
                    if data.isEmpty {
                        errorHandle.readabilityHandler = nil
                    } else if let line = String(data: data, encoding: .utf8) {
                        onOutput(line.trimmingCharacters(in: .newlines))
                    }
                }
                
                process.terminationHandler = { completedProcess in
                    // Clean up handlers
                    outputPipe.fileHandleForReading.readabilityHandler = nil
                    errorPipe.fileHandleForReading.readabilityHandler = nil
                    
                    let exitCode = completedProcess.terminationStatus
                    if exitCode == 0 {
                        continuation.resume()
                    } else {
                        continuation.resume(throwing: ToolError.nonZeroExitCode(exitCode))
                    }
                }
                
                do {
                    try process.run()
                } catch {
                    outputPipe.fileHandleForReading.readabilityHandler = nil
                    errorPipe.fileHandleForReading.readabilityHandler = nil
                    continuation.resume(throwing: ToolError.executionFailed(error.localizedDescription))
                }
            }
        } onCancel: {
            if process.isRunning {
                process.terminate()
            }
        }
    }
    
    /// Executes a tool synchronously to fetch metadata or check version (ideal for quick commands).
    public static func runSync(executableURL: URL, arguments: [String]) throws -> String {
        let process = Process()
        process.executableURL = executableURL
        process.arguments = arguments
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        try process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        
        let exitCode = process.terminationStatus
        if exitCode != 0 {
            throw ToolError.nonZeroExitCode(exitCode)
        }
        
        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
