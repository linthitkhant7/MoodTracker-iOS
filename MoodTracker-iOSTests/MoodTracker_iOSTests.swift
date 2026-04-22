//
//  MoodTracker_iOSTests.swift
//  MoodTracker-iOSTests
//
//  Created by Lin Thit on 4/21/26.
//

import Testing
import SwiftData
@testable import MoodTracker_iOS

struct MoodTracker_iOSTests {

    @Test func moodLevelLabelsAndEmojisMatchExpectedValues() {
        let expectedPairs: [(MoodLevel, String, String)] = [
            (.veryBad, "Very Bad", "😞"),
            (.bad, "Bad", "😕"),
            (.neutral, "Neutral", "😐"),
            (.good, "Good", "🙂"),
            (.veryGood, "Very Good", "😄")
        ]

        for (level, expectedLabel, expectedEmoji) in expectedPairs {
            #expect(level.label == expectedLabel)
            #expect(level.emoji == expectedEmoji)
        }
    }

    @Test func insertsAndFetchesMoodEntryFromInMemorySwiftData() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: MoodEntry.self, configurations: configuration)
        let context = ModelContext(container)

        let savedEntry = MoodEntry(
            date: Date(timeIntervalSince1970: 1_717_171_717),
            moodLevel: .good,
            note: "Feeling steady and focused",
            emotions: ["calm", "hopeful"]
        )
        context.insert(savedEntry)
        try context.save()

        let descriptor = FetchDescriptor<MoodEntry>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let entries = try context.fetch(descriptor)

        #expect(entries.count == 1)
        #expect(entries.first?.moodLevel == .good)
        #expect(entries.first?.note == "Feeling steady and focused")
        #expect(entries.first?.emotions == ["calm", "hopeful"])
    }

}
