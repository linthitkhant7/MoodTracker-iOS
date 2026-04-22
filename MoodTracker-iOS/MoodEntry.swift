//
//  MoodEntry.swift
//  MoodTracker-iOS
//
//  Created by Lin Thit on 4/22/26.
//

import Foundation
import SwiftData

enum MoodLevel: Int, Codable, CaseIterable {
    case veryBad = 1
    case bad = 2
    case neutral = 3
    case good = 4
    case veryGood = 5
    
    var label: String {
        switch self {
        case .veryBad: return "Very Bad"
        case .bad: return "Bad"
        case .neutral: return "Neutral"
        case .good: return "Good"
        case .veryGood: return "Very Good"
        }
    }
    
    var emoji: String {
        switch self {
        case .veryBad: return "😞"
        case .bad: return "😕"
        case .neutral: return "😐"
        case .good: return "🙂"
        case .veryGood: return "😄"
        }
    }
}

@Model
class MoodEntry {
    var id: UUID
    var date: Date
    var moodLevel: MoodLevel
    var note: String
    var emotions: [String]
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        moodLevel: MoodLevel,
        note: String = "",
        emotions: [String] = []
    ) {
        self.id = id
        self.date = date
        self.moodLevel = moodLevel
        self.note = note
        self.emotions = emotions
    }
}
