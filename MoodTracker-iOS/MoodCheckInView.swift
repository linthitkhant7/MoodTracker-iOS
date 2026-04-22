//
//  MoodCheckInView.swift
//  MoodTracker-iOS
//
//  Created by Codex on 4/22/26.
//

import SwiftUI
import SwiftData
import Combine
import Foundation

struct MoodCheckInView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var selectedMood: MoodLevel = .neutral
    @State private var note = ""
    @State private var emotionsInput = ""
    @State private var showValidationError = false

    private let debugServerEndpoint = "http://127.0.0.1:7673/ingest/8e1bbd19-1625-4880-9af3-ec7f73d35853"
    private let debugSessionId = "6ae963"

    var body: some View {
        NavigationStack {
            Form {

                // MARK: - Mood Section
                Section("How are you feeling?") {
                    ForEach(MoodLevel.allCases, id: \.self) { mood in
                        moodButton(for: mood)
                    }

                    if showValidationError {
                        Text("Please select a mood before saving.")
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }
                }

                // MARK: - Note Section
                Section("Journal (Optional)") {
                    TextField("Write a short note", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }

                // MARK: - Emotions Section
                Section("Emotions (Optional)") {
                    TextField("e.g. calm, anxious, hopeful", text: $emotionsInput)
                        .textInputAutocapitalization(.never)
                }

                // MARK: - Save Button
                Section {
                    Button("Save Entry", action: saveEntry)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Mood Check-In")

            // View appeared log
            .onAppear {
                debugLog(
                    hypothesisId: "H3",
                    location: "MoodCheckInView.swift:onAppear",
                    message: "View appeared",
                    data: ["initialMood": selectedMood.rawValue]
                )
            }

            // State change log
            .onChange(of: selectedMood) { oldValue, newValue in
                debugLog(
                    hypothesisId: "H2",
                    location: "MoodCheckInView.swift:onChange",
                    message: "Mood changed",
                    data: [
                        "old": oldValue.rawValue,
                        "new": newValue.rawValue
                    ]
                )
            }
        }
    }

    @ViewBuilder
    private func moodButton(for mood: MoodLevel) -> some View {
        Button {
            handleMoodSelection(mood)
        } label: {
            moodRow(for: mood)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func moodRow(for mood: MoodLevel) -> some View {
        HStack {
            Text(mood.emoji)
            Text(mood.label)
            Spacer()

            if selectedMood == mood {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.accentColor)
            }
        }
    }

    // MARK: - Save Entry
    private func saveEntry() {

        debugLog(
            hypothesisId: "H3",
            location: "MoodCheckInView.swift:saveEntry",
            message: "Save triggered",
            data: [
                "mood": selectedMood.rawValue,
                "noteLength": note.count,
                "emotionsLength": emotionsInput.count
            ]
        )

        let emotions = emotionsInput
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let entry = MoodEntry(
            moodLevel: selectedMood,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            emotions: emotions
        )

        modelContext.insert(entry)

        // Reset state
        note = ""
        emotionsInput = ""
        selectedMood = .neutral
        showValidationError = false

        debugLog(
            hypothesisId: "H3",
            location: "MoodCheckInView.swift:saveComplete",
            message: "Entry saved",
            data: [
                "resetMood": selectedMood.rawValue,
                "emotionCount": emotions.count
            ]
        )
    }

    // MARK: - Debug Logger
    private func debugLog(
        hypothesisId: String,
        location: String,
        message: String,
        data: [String: Any]
    ) {
        let payload: [String: Any] = [
            "sessionId": debugSessionId,
            "runId": "run-1",
            "hypothesisId": hypothesisId,
            "location": location,
            "message": message,
            "data": data,
            "timestamp": Int(Date().timeIntervalSince1970 * 1000)
        ]

        guard JSONSerialization.isValidJSONObject(payload),
              let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            return
        }

        guard let url = URL(string: debugServerEndpoint) else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(debugSessionId, forHTTPHeaderField: "X-Debug-Session-Id")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request).resume()
    }
    private func handleMoodSelection(_ mood: MoodLevel) {
        debugLog(
            hypothesisId: "H2",
            location: "MoodCheckInView.swift:Action-Before",
            message: "Mood tapped",
            data: [
                "tappedMood": mood.rawValue,
                "selectedBefore": selectedMood.rawValue
            ]
        )

        selectedMood = mood
        showValidationError = false

        debugLog(
            hypothesisId: "H2",
            location: "MoodCheckInView.swift:Action-After",
            message: "Mood updated",
            data: [
                "selectedAfter": selectedMood.rawValue
            ]
        )
    }
}

#Preview {
    MoodCheckInView()
        .modelContainer(for: MoodEntry.self, inMemory: true)
}
