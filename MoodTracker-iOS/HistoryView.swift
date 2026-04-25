//
//  HistoryView.swift
//  MoodTracker-iOS
//
//  Created by Lin Thit on 4/24/26.
//

import SwiftUI
import Charts

struct HistoryView: View {
    var viewModel: MoodViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // MARK: - Mood Chart
                    if viewModel.entries.isEmpty {
                        emptyStateView
                    } else {
                        moodChartView
                        entriesListView
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Mood History")
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Text("📊")
                .font(.system(size: 64))
            Text("No history yet")
                .font(.title3)
                .fontWeight(.semibold)
            Text("Start logging your mood to see trends here")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Mood Chart
    private var moodChartView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mood Trend")
                .font(.headline)
            
            Chart {
                ForEach(viewModel.entries.prefix(7).reversed(), id: \.id) { entry in
                    LineMark(
                        x: .value("Date", entry.date, unit: .day),
                        y: .value("Mood", entry.moodLevel.rawValue)
                    )
                    .foregroundStyle(Color.indigo)
                    .interpolationMethod(.catmullRom)
                    
                    PointMark(
                        x: .value("Date", entry.date, unit: .day),
                        y: .value("Mood", entry.moodLevel.rawValue)
                    )
                    .foregroundStyle(Color.indigo)
                    .annotation(position: .top) {
                        Text(entry.moodLevel.emoji)
                            .font(.caption)
                    }
                }
            }
            .chartYScale(domain: 1...5)
            .chartYAxis {
                AxisMarks(values: [1, 2, 3, 4, 5]) { value in
                    AxisValueLabel {
                        if let intValue = value.as(Int.self),
                           let mood = MoodLevel(rawValue: intValue) {
                            Text(mood.emoji)
                        }
                    }
                }
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Entries List
    private var entriesListView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All Entries")
                .font(.headline)
            
            List {
                ForEach(viewModel.entries, id: \.id) { entry in
                    HStack(alignment: .top, spacing: 12) {
                        Text(entry.moodLevel.emoji)
                            .font(.system(size: 32))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(entry.moodLevel.label)
                                    .font(.headline)
                                Spacer()
                                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            if !entry.emotions.isEmpty {
                                Text(entry.emotions.joined(separator: " · "))
                                    .font(.caption)
                                    .foregroundStyle(.indigo)
                            }
                            
                            if !entry.note.isEmpty {
                                Text(entry.note)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                        }
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            viewModel.deleteEntry(entry)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.plain)
            .frame(minHeight: 300)
        }
    }
}
