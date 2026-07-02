import Foundation
import ReMasteraCore

print("==================================================")
print("Running ReMastera Plain Assertions Test Suite...")
print("==================================================")

// 1. Tag alphabetization and sanitization tests
func testTagSanitizationAndAlphabetization() {
    print("Running tag sanitization...")
    let inputTags = ["Upscaled", "Subtitles", "kodak!", "hdr10", "Subtitles"]
    let expected = ["hdr10", "kodak", "subtitles", "upscaled"]
    
    let result = TagSanitizer.sanitize(inputTags)
    assert(result == expected, "Tag sanitization failed: \(result)")
}

func testEmptyTagInput() {
    print("Running empty tag check...")
    let inputTags: [String] = []
    let result = TagSanitizer.sanitize(inputTags)
    assert(result.isEmpty, "Empty tags should return empty list")
}

// 2. Estimated file size calculation tests
func testEstimatedFileSizeCalculation() {
    print("Running size estimation...")
    let estimate = SizeEstimator.estimateSize(
        durationSeconds: 180,
        videoBitrateMbps: 5.0,
        audioBitrateKbps: 192.0
    )
    assert(estimate == 116_820_000, "Size estimation calculation is wrong: \(estimate)")
}

// 3. Preset bitrate values verification
func testPresetBitratesCheck() {
    print("Running preset bitrate check...")
    assert(Preset.fastPreview.videoBitrateMbps == 2.0)
    assert(Preset.fastPreview.audioBitrateKbps == 128.0)
    
    assert(Preset.compact4K.videoBitrateMbps == 5.0)
    assert(Preset.compact4K.audioBitrateKbps == 192.0)
    
    assert(Preset.balanced4K.videoBitrateMbps == 10.0)
    assert(Preset.balanced4K.audioBitrateKbps == 256.0)
    
    assert(Preset.archival4K.videoBitrateMbps == 25.0)
    assert(Preset.archival4K.audioBitrateKbps == 320.0)
    
    assert(Preset.originalResolution.videoBitrateMbps == 6.0)
    assert(Preset.originalResolution.audioBitrateKbps == 192.0)
}

// 4. Output path mirroring tests
func testOutputPathConstructionAndFolderMirroring() {
    print("Running output path mirroring...")
    let sourceURL = URL(fileURLWithPath: "/Volumes/Media/SpanishMovies/Classics/Movie1.mp4")
    let inputDir = URL(fileURLWithPath: "/Volumes/Media/SpanishMovies")
    let outputDir = URL(fileURLWithPath: "/Volumes/Media/Processed")
    let tags = ["upscaled", "hdr10"]
    
    let expectedPath = "/Volumes/Media/Processed/SpanishMovies_processed/Classics/Movie1 hdr10 upscaled.mp4"
    
    let outputURL = OutputPathBuilder.buildOutputPath(
        sourceURL: sourceURL,
        inputDirectoryURL: inputDir,
        outputDirectoryURL: outputDir,
        tags: tags,
        overwritePolicy: .replaceExisting
    )
    
    assert(outputURL.path == expectedPath, "Output path mirroring failed: \(outputURL.path)")
}

// 5. Dependency scanner lookup logic
func testLocateToolsPathDetection() {
    print("Running tools detection check...")
    let missingTool = DependencyDetector.locateTool("non-existent-tool-remastera")
    assert(missingTool == nil, "Missing tool should be nil")
    
    let checkTool = DependencyDetector.locateTool("ls")
    assert(checkTool != nil, "Standard tool ls should be found")
}

// 6. Pipeline cancellation state behavior tests
@MainActor func testPipelineCancellationStateUpdates() {
    print("Running cancellation state check...")
    let sourceURL = URL(fileURLWithPath: "/tmp/source.mp4")
    let destURL = URL(fileURLWithPath: "/tmp/dest.mp4")
    let job = Job(sourceURL: sourceURL, destinationURL: destURL)
    let tempDir = URL(fileURLWithPath: "/tmp/job-temp")
    
    let context = PipelineContext(job: job, tempDirectoryURL: tempDir)
    assert(!context.isCancelled)
    
    context.isCancelled = true
    assert(context.isCancelled)
}

// Execute all tests
testTagSanitizationAndAlphabetization()
testEmptyTagInput()
testEstimatedFileSizeCalculation()
testPresetBitratesCheck()
testOutputPathConstructionAndFolderMirroring()
testLocateToolsPathDetection()
testPipelineCancellationStateUpdates()

print("==================================================")
print("All unit tests passed successfully!")
print("==================================================")
