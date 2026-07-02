import Foundation

public struct DenoiseStage: PipelineStage {
    public let id = "denoise"
    public let displayName = "Denoising"
    
    public init() {}
    
    public func run(context: PipelineContext) async throws {
        guard context.job.isDenoiseEnabled else {
            context.addLog("Denoising disabled. Skipping.")
            return
        }
        
        context.addLog("Applying Standard Denoise filter (hqdn3d).")
        // Standard high-quality 3D denoiser filter parameter: luma_spatial:chroma_spatial:luma_tmp:chroma_tmp
        context.videoFilters.append("hqdn3d=1.5:1.5:6:6")
    }
}
