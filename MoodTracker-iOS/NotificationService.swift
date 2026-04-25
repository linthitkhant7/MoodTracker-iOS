//
//  NotificationService.swift
//  MoodTracker-iOS
//
//  Created by Lin Thit on 4/25/26.
//

import Foundation
import UserNotifications

class NotificationService {
    private let center = UNUserNotificationCenter.current()
    
    // MARK: - Request Authorization
    func requestAuthorization() async throws -> Bool {
        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        return granted
    }
    
    // MARK: - Schedule Daily Reminder
    func scheduleDailyReminder(hour: Int, minute: Int) async {
        // Remove existing notifications first
        center.removePendingNotificationRequests(withIdentifiers: ["dailyMoodReminder"])
        
        let content = UNMutableNotificationContent()
        content.title = "How are you feeling? 😊"
        content.body = "Take a moment to log your mood today."
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        
        let request = UNNotificationRequest(
            identifier: "dailyMoodReminder",
            content: content,
            trigger: trigger
        )
        
        do {
            try await center.add(request)
            print("Daily reminder schedules for \(hour):\(String(format: "%02d", minute))")
        } catch {
            print("Failed to schedule notification: \(error)")
        }
    }
    
    // MARK: - Cancel Reminder
    func cancelDailyReminder() {
        center.removePendingNotificationRequests(withIdentifiers: ["dailyMoodReminder"])
    }
    
    // MARK: - Check Authorization Status
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }
}
