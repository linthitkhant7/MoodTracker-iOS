//
//  MoodViewModel.swift
//  MoodTracker-iOS
//
//  Created by Lin Thit on 4/23/26.
//

import Foundation
import SwiftData

@Observable
class MoodViewModel {
    private var context: ModelContext
    let healthKitService = HealthKitService()
    let notificationService = NotificationService()
    
    var entries: [MoodEntry] = []
    var isLoading: Bool = false
    var sleepHours: Double = 0
    var mindfulMinutes: Double = 0
    var notificationsGranted: Bool = false
    
    init(context: ModelContext) {
        self.context = context
        fetchEntries()
    }
    
    // MARK: - Setup Services
    func setupServices() async {
        await requestHealthKit()
        await requestNotifications()
    }
    
    // MARK: - HealthKit
    func requestHealthKit() async {
        do {
            try await healthKitService.requestAuthorization()
            await fetchHealthData()
        } catch {
            print("HealthKit authorization failed: \(error)")
        }
    }
    
    func fetchHealthData() async {
        async let sleep = healthKitService.fetchLastNightSleepHours()
        async let mindful = healthKitService.fetchTodayMindfulMinutes()
        let (sleepResult, mindfulResult) = await (sleep, mindful)
        sleepHours = sleepResult
        mindfulMinutes = mindfulResult
    }
    
    // MARK: - Notifications
    func requestNotifications() async {
        do {
            notificationsGranted = try await notificationService.requestAuthorization()
            if notificationsGranted {
                await notificationService.scheduleDailyReminder(hour: 20, minute: 0)
            }
        } catch {
            print("Notification authorization failed: \(error)")
        }
    }
    
    
    // MARK: - Fetch
    func fetchEntries() {
        isLoading = true
        let descriptor = FetchDescriptor<MoodEntry>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        do {
            entries = try context.fetch(descriptor)
        } catch {
            print("Failed to fetch entries: \(error)")
        }
        isLoading = false
    }
    
    // MARK: - Add
    func addEntry(moodLevel: MoodLevel, note: String, emotions: [String]) {
        let entry = MoodEntry(
            moodLevel: moodLevel,
            note: note,
            emotions: emotions
        )
        context.insert(entry)
        saveContext()
        fetchEntries()
    }
    
    // MARK: - Delete
    func deleteEntry(_ entry: MoodEntry) {
        context.delete(entry)
        saveContext()
        fetchEntries()
    }
    
    // MARK: - Save
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
