# MoodTracker iOS 💜

A native iOS mental health mood tracking app built with Swift and SwiftUI.

## Screenshots

| Home | Check-In | History | Settings |
|------|----------|---------|----------|
| <img src="home.png" width="200"> | <img src="checkin.png" width="200"> | <img src="history.png" width="200"> | <img src="settings.png" width="200"> |

## Overview

MoodTracker helps users log their daily mood, track emotional 
patterns over time, and gain insights into their mental wellbeing 
through beautiful charts and health data integration.

Built as a portfolio project demonstrating modern iOS development 
practices including SwiftData persistence, HealthKit integration, 
Swift concurrency and unit testing.

## Features

- 📊 Daily mood check-in with 5 mood levels and emotion tagging
- 📝 Journal notes per mood entry
- 📈 Mood trend chart showing last 7 days
- 🔥 Daily streak tracking
- 💜 Weekly mood average with progress indicator
- 🌙 HealthKit integration for sleep and mindfulness data
- 🔔 Customizable daily reminder notifications
- 🗑️ Swipe to delete entries
- ⏰ Time-based greetings

## Tech Stack

- **Language:** Swift 5.9
- **UI Framework:** SwiftUI
- **Data Persistence:** SwiftData
- **Architecture:** MVVM
- **Concurrency:** async/await with structured concurrency
- **Charts:** Swift Charts
- **Health Data:** HealthKit
- **Notifications:** UserNotifications
- **Testing:** XCTest with Swift Testing

## Architecture

MoodTracker/
- Models/
  - MoodEntry.swift (SwiftData model)
  - MoodLevel enum (Mood levels with emoji and labels)
- ViewModels/
  - MoodViewModel.swift (@Observable ViewModel)
- Views/
  - HomeView.swift (Main dashboard)
  - CheckInView.swift (Mood logging screen)
  - HistoryView.swift (Charts and history)
  - SettingsView.swift (Notifications and health settings)
- Services/
  - HealthKitService.swift (HealthKit integration)
  - NotificationService.swift (Local notifications)
- Tests/
  - MoodViewModelTests.swift (Unit tests)
 
## Key Technical Decisions

**SwiftData over CoreData** — Chosen for its modern Swift-native
API and seamless SwiftUI integration using the @Model macro.

**@Observable over ObservableObject** — Modern Swift observation
framework that eliminates the need for Combine and @Published
property wrappers.

**async let for parallel fetching** — HealthKit sleep and
mindfulness data fetched concurrently for better performance.

**In-memory containers for testing** — Unit tests use
ModelConfiguration(isStoredInMemoryOnly: true) to ensure
test isolation and never touch production data.

## Requirements

- iOS 17.0+
- Xcode 15.0+
- iPhone with Health app for HealthKit features

## Author

**Lin Thit Khant**
iOS Developer | Swift & SwiftUI | Healthcare Mobile Apps

[![GitHub](https://img.shields.io/badge/GitHub-linthitkhant7-black)](https://github.com/linthitkhant7)
