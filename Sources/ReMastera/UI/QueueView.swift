import SwiftUI
import AppKit

public struct QueueView: View {
    @Bindable var queueManager: QueueManager
    @State private var expandedJobLogs = Set<UUID>()
    
    public init(queueManager: QueueManager) {
        self.queueManager = queueManager
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Processing Queue")
                    .font(.title2.bold())
                Text("Monitor active render streams and retrieve final output files.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
            
            if queueManager.jobs.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "film.stack")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                        .opacity(0.5)
                    Text("No jobs in the processing queue")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("Go to the Dashboard to add video assets.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(queueManager.jobs) { job in
                        jobRow(job)
                            .padding(.vertical, 8)
                    }
                }
                .listStyle(.plain)
            }
        }
        .padding()
    }
    
    @ViewBuilder
    private func jobRow(_ job: Job) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(job.sourceURL.lastPathComponent)
                        .font(.headline)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        Text(job.preset.displayName)
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("Est. Size: \(SizeEstimator.formatBytes(job.fileSizeEstimate))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        if let actual = job.actualFileSize {
                            Text("•")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("Actual Size: \(SizeEstimator.formatBytes(actual))")
                                .font(.caption.bold())
                                .foregroundStyle(.green)
                        }
                    }
                }
                
                Spacer()
                
                statusBadge(job.status)
                
                HStack(spacing: 8) {
                    if job.status == .completed {
                        Button(action: { revealInFinder(job.destinationURL) }) {
                            Image(systemName: "folder")
                                .help("Reveal in Finder")
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    if job.status == .failed || job.status == .cancelled {
                        Button(action: { queueManager.retryJob(job: job) }) {
                            Image(systemName: "arrow.clockwise")
                                .help("Retry Job")
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    if job.status == .processing || job.status == .queued {
                        Button(action: { queueManager.cancelJob(job: job) }) {
                            Image(systemName: "stop.fill")
                                .help("Stop Processing")
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Button(action: { queueManager.removeJob(job: job) }) {
                        Image(systemName: "trash")
                            .help("Remove Job")
                    }
                    .buttonStyle(.bordered)
                }
            }
            
            if job.status == .processing {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Stage: \(job.currentStage)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(Int(job.progress * 100))%")
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                    ProgressView(value: job.progress, total: 1.0)
                        .progressViewStyle(.linear)
                }
            }
            
            if let errorDesc = job.errorDescription {
                Text("Error: \(errorDesc)")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(4)
            }
            
            // Collapsible Logs Panel
            let isExpanded = Binding(
                get: { expandedJobLogs.contains(job.id) },
                set: { expanded in
                    if expanded {
                        expandedJobLogs.insert(job.id)
                    } else {
                        expandedJobLogs.remove(job.id)
                    }
                }
            )
            
            DisclosureGroup("View Console Transcript", isExpanded: isExpanded) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        if job.logs.isEmpty {
                            Text("No console logs printed yet.")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(job.logs, id: \.self) { log in
                                Text(log)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .padding(8)
                }
                .frame(maxHeight: 120)
                .background(Color(nsColor: .textBackgroundColor))
                .cornerRadius(6)
                .padding(.top, 4)
            }
            .font(.caption)
        }
        .padding()
        .background(Color.secondary.opacity(0.04))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary.opacity(0.08), lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private func statusBadge(_ status: JobStatus) -> some View {
        Text(status.displayName)
            .font(.caption.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(badgeColor(status).opacity(0.15))
            .foregroundStyle(badgeColor(status))
            .cornerRadius(4)
    }
    
    private func badgeColor(_ status: JobStatus) -> Color {
        switch status {
        case .queued: return .blue
        case .processing: return .orange
        case .completed: return .green
        case .failed: return .red
        case .cancelled: return .gray
        }
    }
    
    private func revealInFinder(_ url: URL) {
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
}
