//
//  CheckInView.swift
//  MoodTracker-iOS
//
//  Created by Lin Thit on 4/23/26.
//

import SwiftUI

struct CheckInView: View {
    @Environment(\.dismiss) private var dismiss
    var viewModel: MoodViewModel
    
    @State private var selectedMood: MoodLevel = .neutral
    @State private var note: String = ""
    @State private var selectedEmotions: [String] = []
    
    let availableEmotions = [
        "Anxious", "Calm", "Grateful", "Lonely",
        "Excited", "Tired", "Hopeful", "Sad",
        "Confident", "Overwhelmed", "Happy", "Angry"
    ]
    
    private var canSave: Bool {
        !selectedEmotions.isEmpty || !note.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    
                    // MARK: - Mood Selector
                    VStack(spacing: 12) {
                        Text("How are you feeling?")
                            .font(.headline)
                        HStack(spacing: 16) {
                            ForEach(MoodLevel.allCases, id: \.self) { mood in
                                Button {
                                    selectedMood = mood
                                } label: {
                                    VStack(spacing: 4) {
                                        Text(mood.emoji)
                                            .font(.system(size: 36))
                                        Text(mood.label)
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(8)
                                    .background(
                                        selectedMood == mood ?
                                        Color.indigo.opacity(0.2) : Color.clear
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                selectedMood == mood ?
                                                Color.indigo : Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // MARK: - Emotion Tags
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tag your emotions")
                            .font(.headline)
                        FlowLayout(spacing: 8) {
                            ForEach(availableEmotions, id: \.self) { emotion in
                                Button {
                                    toggleEmotion(emotion)
                                } label: {
                                    Text(emotion)
                                        .font(.subheadline)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(
                                            selectedEmotions.contains(emotion) ?
                                            Color.indigo : Color(.systemGray5)
                                        )
                                        .foregroundStyle(
                                            selectedEmotions.contains(emotion) ?
                                                .white : .primary
                                        )
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // MARK: - Journal Note
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Add a note")
                            .font(.headline)
                        TextField(
                            "What's on your mind today?",
                            text: $note,
                            axis: .vertical
                        )
                        .lineLimit(4...6)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // MARK: - Save Button
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            saveEntry()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Save Entry")
                                .font(.headline)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canSave ? Color.indigo : Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .animation(.easeInOut, value: canSave)
                    }
                    .disabled(!canSave)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Log Mood")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func toggleEmotion(_ emotion: String) {
        if selectedEmotions.contains(emotion) {
            selectedEmotions.removeAll { $0 == emotion }
        } else {
            selectedEmotions.append(emotion)
        }
    }
    
    private func saveEntry() {
        viewModel.addEntry(
            moodLevel: selectedMood,
            note: note,
            emotions: selectedEmotions
        )
        dismiss()
    }
}

// MARK: - FlowLayout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        return CGSize(
            width: proposal.width ?? 0,
            height: rows.map { $0.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0 }.reduce(0, +) + spacing * CGFloat(rows.count - 1)
        )
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            let rowHeight = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            for subview in row {
                let size = subview.sizeThatFits(.unspecified)
                subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
                x += size.width + spacing
            }
            y += rowHeight + spacing
        }
    }
    
    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[LayoutSubview]] {
        var rows: [[LayoutSubview]] = [[]]
        var x: CGFloat = 0
        let maxWidth = proposal.width ?? 0
        for subview in subviews {
            let width = subview.sizeThatFits(.unspecified).width
            if x + width > maxWidth && !rows[rows.count - 1].isEmpty {
                rows.append([])
                x = 0
            }
            rows[rows.count - 1].append(subview)
            x += width + spacing
        }
        return rows
    }
}
