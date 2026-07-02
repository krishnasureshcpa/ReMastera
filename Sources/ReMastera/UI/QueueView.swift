import SwiftUI
import AppKit

public struct QueueView: View {
    @Bindable var queueManager: QueueManager
    @State private var expandedJobLogs = Set<UUID>()
    
    public init(queueManager: QueueManager) {
        self.queueManager = queueManager
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Friendly Header
            HStack {
                VStack(alignment: .leading, spacing: ReMasteraDesign.space4) {
                    Text("Render Queue")
                        .font(ReMasteraType.heading(28))
                        .foregroundStyle(ReMasteraDesign.heading)
                    Text("Monitor active streams, intercept outputs, and debug failures.")
                        .font(ReMasteraType.body(15))
                        .foregroundStyle(ReMasteraDesign.body)
                }
                Spacer()
            }
            .padding(ReMasteraDesign.space32)
            
            SectionDivider()
            
            if queueManager.jobs.isEmpty {
                VStack(spacing: ReMasteraDesign.space24) {
                    Image(systemName: "film.stack.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(ReMasteraDesign.borderSubtle)
                    
                    VStack(spacing: ReMasteraDesign.space8) {
                        Text("Queue Empty")
                            .font(ReMasteraType.heading(20))
                            .foregroundStyle(ReMasteraDesign.heading)
                        Text("No active processing streams.")
                            .font(ReMasteraType.body(14))
                            .foregroundStyle(ReMasteraDesign.body)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: ReMasteraDesign.space16) {
                        ForEach(queueManager.jobs) { job in
                            JobCard(
                                job: job,
                                isExpanded: expandedJobLogs.contains(job.id),
                                toggleExpand: {
                                    withAnimation(ReMasteraDesign.springBouncy) {
                                        if expandedJobLogs.contains(job.id) {
                                            expandedJobLogs.remove(job.id)
                                        } else {
                                            expandedJobLogs.insert(job.id)
                                        }
                                    }
                                }
                            )
                        }
                    }
                    .padding(ReMasteraDesign.space32)
                }
            }
        }
        .background(ReMasteraDesign.background)
    }
}

struct JobCard: View {
    let job: Job
    let isExpanded: Bool
    let toggleExpand: () -> Void
    
    @State private var isHovered = false
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: toggleExpand) {
                HStack(spacing: ReMasteraDesign.space16) {
                    // Status Icon
                    ZStack {
                        Circle()
                            .fill(statusColor.opacity(0.15))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: statusIcon)
                            .font(.system(size: 20))
                            .foregroundStyle(statusColor)
                    }
                    
                    VStack(alignment: .leading, spacing: ReMasteraDesign.space4) {
                        Text(job.sourceURL.lastPathComponent)
                            .font(ReMasteraType.label(16))
                            .foregroundStyle(ReMasteraDesign.heading)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        
                        HStack(spacing: ReMasteraDesign.space8) {
                            Text(job.preset.displayName)
                                .font(ReMasteraType.caption(12))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(ReMasteraDesign.brand.opacity(0.15))
                                .foregroundStyle(ReMasteraDesign.brandDeep)
                                .clipShape(Capsule())
                            
                            if job.isDenoiseEnabled { enhancementTag("Denoise") }
                            if job.isFilmLookEnabled { enhancementTag("Film") }
                            if job.isSubtitleEnabled { enhancementTag("Subs") }
                            if job.isUpscaleEnabled { enhancementTag("Upscale") }
                            if job.isHdr10Enabled { enhancementTag("HDR") }
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: ReMasteraDesign.space8) {
                        Text(job.status.rawValue.uppercased())
                            .font(ReMasteraType.label(12))
                            .foregroundStyle(statusColor)
                        
                        if job.status == .processing {
                            ProgressView(value: job.progress)
                                .progressViewStyle(.linear)
                                .tint(ReMasteraDesign.brand)
                                .frame(width: 80)
                        } else if job.status == .completed {
                            Button("Reveal") {
                                NSWorkspace.shared.activateFileViewerSelecting([job.destinationURL])
                            }
                            .font(ReMasteraType.caption(12))
                            .buttonStyle(.link)
                        }
                    }
                }
                .padding(ReMasteraDesign.space16)
                .background(isHovered ? ReMasteraDesign.surfaceElevated : ReMasteraDesign.surface)
            }
            .buttonStyle(.plain)
            .onHover { hovering in isHovered = hovering }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
            
            if isExpanded {
                Divider().background(ReMasteraDesign.borderSubtle)
                
                ScrollView {
                    Text(job.logs.isEmpty ? "Waiting for engine output..." : job.logs.joined(separator: "\n"))
                        .font(ReMasteraType.code(12))
                        .foregroundStyle(ReMasteraDesign.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(ReMasteraDesign.space16)
                }
                .frame(height: 150)
                .background(ReMasteraDesign.surfaceElevated)
            }
        }
        .remasteraCard(interactive: false)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(ReMasteraDesign.springBouncy, value: isPressed)
    }
    
    private var statusColor: Color {
        switch job.status {
        case .queued: return ReMasteraDesign.bodySubtle
        case .processing: return ReMasteraDesign.brand
        case .completed: return ReMasteraDesign.success
        case .failed: return ReMasteraDesign.error
        case .cancelled: return ReMasteraDesign.warning
        }
    }
    
    private var statusIcon: String {
        switch job.status {
        case .queued: return "clock.fill"
        case .processing: return "bolt.fill"
        case .completed: return "checkmark.circle.fill"
        case .failed: return "exclamationmark.triangle.fill"
        case .cancelled: return "xmark.octagon.fill"
        }
    }
    
    @ViewBuilder
    private func enhancementTag(_ text: String) -> some View {
        Text(text)
            .font(ReMasteraType.caption(11))
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(ReMasteraDesign.surfaceElevated)
            .foregroundStyle(ReMasteraDesign.body)
            .clipShape(Capsule())
    }
}
