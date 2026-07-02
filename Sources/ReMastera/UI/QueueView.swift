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
            // Header
            HStack {
                VStack(alignment: .leading, spacing: ReMasteraDesign.space4) {
                    Text("RENDER QUEUE")
                        .font(ReMasteraType.heading(24))
                        .foregroundStyle(ReMasteraDesign.heading)
                    Text("Monitor active streams, intercept outputs, and debug failures.")
                        .font(ReMasteraType.body(14))
                        .foregroundStyle(ReMasteraDesign.body)
                }
                Spacer()
            }
            .padding(ReMasteraDesign.space32)
            
            SectionDivider()
            
            if queueManager.jobs.isEmpty {
                VStack(spacing: ReMasteraDesign.space24) {
                    Image(systemName: "film.stack")
                        .font(.system(size: 64, weight: .ultraLight))
                        .foregroundStyle(ReMasteraDesign.borderSubtle)
                    
                    VStack(spacing: ReMasteraDesign.space8) {
                        Text("QUEUE EMPTY")
                            .font(ReMasteraType.label(16))
                            .tracking(2)
                            .foregroundStyle(ReMasteraDesign.heading)
                        Text("No active processing streams.")
                            .font(ReMasteraType.caption(12))
                            .foregroundStyle(ReMasteraDesign.fgDisabled)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: ReMasteraDesign.space16) {
                        ForEach(queueManager.jobs) { job in
                            JobTerminalRow(
                                job: job,
                                isExpanded: Binding(
                                    get: { expandedJobLogs.contains(job.id) },
                                    set: { expanded in
                                        if expanded { expandedJobLogs.insert(job.id) }
                                        else { expandedJobLogs.remove(job.id) }
                                    }
                                ),
                                onRetry: { queueManager.retryJob(job: job) },
                                onCancel: { queueManager.cancelJob(job: job) },
                                onRemove: { queueManager.removeJob(job: job) }
                            )
                        }
                    }
                    .padding(ReMasteraDesign.space32)
                }
            }
        }
    }
}

struct JobTerminalRow: View {
    let job: Job
    @Binding var isExpanded: Bool
    let onRetry: () -> Void
    let onCancel: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack(alignment: .center) {
                // Status Indicator
                Circle()
                    .fill(statusColor(job.status))
                    .frame(width: 8, height: 8)
                    .shadow(color: statusColor(job.status).opacity(0.8), radius: 4)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(job.sourceURL.lastPathComponent)
                        .font(ReMasteraType.label(14))
                        .foregroundStyle(ReMasteraDesign.heading)
                        .lineLimit(1)
                    
                    HStack(spacing: ReMasteraDesign.space8) {
                        Text(job.preset.displayName)
                            .foregroundStyle(ReMasteraDesign.brand)
                        Text("•")
                            .foregroundStyle(ReMasteraDesign.borderSubtle)
                        Text("EST: \(SizeEstimator.formatBytes(job.fileSizeEstimate))")
                        
                        if let actual = job.actualFileSize {
                            Text("•")
                                .foregroundStyle(ReMasteraDesign.borderSubtle)
                            Text("ACTUAL: \(SizeEstimator.formatBytes(actual))")
                                .foregroundStyle(ReMasteraDesign.success)
                        }
                    }
                    .font(ReMasteraType.caption(10))
                    .foregroundStyle(ReMasteraDesign.fgDisabled)
                }
                
                Spacer()
                
                Text(job.status.displayName.uppercased())
                    .font(ReMasteraType.caption(10))
                    .tracking(1.5)
                    .foregroundStyle(statusColor(job.status))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor(job.status).opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(statusColor(job.status).opacity(0.3), lineWidth: 1)
                    )
            }
            .padding(ReMasteraDesign.space16)
            .background(ReMasteraDesign.surfaceElevated)
            
            // Progress Bar (if processing)
            if job.status == .processing {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(ReMasteraDesign.surface)
                        
                        Rectangle()
                            .fill(ReMasteraDesign.warning)
                            .frame(width: geo.size.width * job.progress)
                    }
                }
                .frame(height: 2)
                
                HStack {
                    Text("STAGE: \(job.currentStage.uppercased())")
                        .font(ReMasteraType.caption(9))
                        .tracking(1)
                        .foregroundStyle(ReMasteraDesign.warning)
                    Spacer()
                    Text("\(Int(job.progress * 100))%")
                        .font(ReMasteraType.caption(10))
                        .foregroundStyle(ReMasteraDesign.warning)
                }
                .padding(ReMasteraDesign.space8)
                .background(ReMasteraDesign.surfaceElevated.opacity(0.5))
            }
            
            // Error Display
            if let errorDesc = job.errorDescription {
                HStack(alignment: .top) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(ReMasteraDesign.error)
                    Text("ERR: \(errorDesc)")
                        .font(ReMasteraType.caption(11))
                        .foregroundStyle(ReMasteraDesign.error)
                    Spacer()
                }
                .padding(ReMasteraDesign.space12)
                .background(ReMasteraDesign.error.opacity(0.1))
            }
            
            // Controls & Logs Toggle
            HStack {
                Button(action: { withAnimation { isExpanded.toggle() } }) {
                    HStack(spacing: 4) {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.system(size: 10))
                        Text(isExpanded ? "HIDE CONSOLE" : "VIEW CONSOLE")
                    }
                    .font(ReMasteraType.caption(10))
                    .tracking(1)
                    .foregroundStyle(isExpanded ? ReMasteraDesign.heading : ReMasteraDesign.fgDisabled)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                // Actions
                HStack(spacing: ReMasteraDesign.space12) {
                    if job.status == .completed {
                        actionButton(icon: "folder", label: "REVEAL", color: ReMasteraDesign.success) {
                            NSWorkspace.shared.activateFileViewerSelecting([job.destinationURL])
                        }
                    }
                    
                    if job.status == .failed || job.status == .cancelled {
                        actionButton(icon: "arrow.clockwise", label: "RETRY", color: ReMasteraDesign.warning) {
                            onRetry()
                        }
                    }
                    
                    if job.status == .processing || job.status == .queued {
                        actionButton(icon: "stop.fill", label: "HALT", color: ReMasteraDesign.error) {
                            onCancel()
                        }
                    }
                    
                    actionButton(icon: "trash", label: "DROP", color: ReMasteraDesign.fgDisabled) {
                        onRemove()
                    }
                }
            }
            .padding(ReMasteraDesign.space12)
            .background(ReMasteraDesign.surfaceElevated)
            
            // Logs Terminal
            if isExpanded {
                Divider().background(ReMasteraDesign.borderSubtle)
                ScrollView {
                    VStack(alignment: .leading, spacing: 2) {
                        if job.logs.isEmpty {
                            Text("> awaiting execution stream...")
                                .foregroundStyle(ReMasteraDesign.fgDisabled)
                        } else {
                            ForEach(job.logs, id: \.self) { log in
                                Text(log)
                                    .foregroundStyle(ReMasteraDesign.body)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .font(ReMasteraType.caption(10))
                    .padding(ReMasteraDesign.space12)
                }
                .frame(maxHeight: 160)
                .background(ReMasteraDesign.black)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase))
        .overlay(
            RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase)
                .stroke(ReMasteraDesign.borderSubtle, lineWidth: 1)
        )
    }
    
    private func statusColor(_ status: JobStatus) -> Color {
        switch status {
        case .queued: return ReMasteraDesign.brandSoft
        case .processing: return ReMasteraDesign.warning
        case .completed: return ReMasteraDesign.success
        case .failed: return ReMasteraDesign.error
        case .cancelled: return ReMasteraDesign.fgDisabled
        }
    }
    
    @ViewBuilder
    private func actionButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                Text(label)
                    .font(ReMasteraType.caption(10))
                    .tracking(1)
            }
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(ReMasteraDesign.surface)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(ReMasteraDesign.borderSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
