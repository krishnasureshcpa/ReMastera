import Foundation

@MainActor
public protocol PipelineStage {
    var id: String { get }
    var displayName: String { get }
    func run(context: PipelineContext) async throws
}
