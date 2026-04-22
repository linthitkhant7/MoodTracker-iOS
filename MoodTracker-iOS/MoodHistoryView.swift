//
//  MoodHistoryView.swift
//  MoodTracker-iOS
//
//  Created by Codex on 4/22/26.
//

import SwiftUI
import SwiftData

struct MoodHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MoodEntry.date, order: .reverse) private var entries: [MoodEntry]

    var body: some View {
        NavigationStack {
            Group {
                if entries.isEmpty {
                    ContentUnavailableView(
                        "No Entries Yet",
                        systemImage: "square.and.pencil",
                        description: Text("Save your first mood check-in to start tracking trends.")
                    )
                } else {
                    List {
                        ForEach(entries) { entry in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(entry.moodLevel.emoji)
                                    Text(entry.moodLevel.label)
                                        .font(.headline)
                                    Spacer()
                                    Text(entry.date, format: .dateTime.month().day().hour().minute())
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                if !entry.note.isEmpty {
                                    Text(entry.note)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete(perform: deleteEntries)
                    }
                }
            }
            .navigationTitle("Mood History")
        }
    }

    private func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(entries[index])
        }
    }
}

#Preview {
    MoodHistoryView()
        .modelContainer(for: MoodEntry.self, inMemory: true)
}
