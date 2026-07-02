import Foundation

public struct FilmLookStage: PipelineStage {
    public let id = "film-look"
    public let displayName = "Cinematic Film Look"
    
    public init() {}
    
    public func run(context: PipelineContext) async throws {
        guard context.job.isFilmLookEnabled else {
            context.addLog("Cinematic Film Look disabled. Skipping.")
            return
        }
        
        context.addLog("Applying Kodak 5247-inspired cinematic color balance and curves.")
        //rs/gs/bs: red/green/blue shadow adjustment (green/cyan shadow bias)
        //rm/gm/bm: red/green/blue midtones adjustment (slight warm bias)
        //rh/gh/bh: red/green/blue highlights adjustment (warm amber highlight bias)
        let colorBalanceFilter = "colorbalance=rs=0.05:gs=0.02:bs=-0.04:rm=0.06:gm=0.02:bm=-0.03:rh=0.08:gh=0.03:bh=-0.04"
        let eqFilter = "eq=contrast=1.04:saturation=1.03"
        
        context.videoFilters.append(colorBalanceFilter)
        context.videoFilters.append(eqFilter)
    }
}
