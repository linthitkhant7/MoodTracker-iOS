//
//  HealthKitService.swift
//  MoodTracker-iOS
//
//  Created by Lin Thit on 4/25/26.
//

import Foundation
import HealthKit

class HealthKitService {
    private let healthStore = HKHealthStore()
    
    // MARK: - Types to read
    private let typesToRead: Set<HKObjectType> = [
        HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
        HKObjectType.categoryType(forIdentifier: .mindfulSession)!
    ]
    
    // MARK: - Request Authorization
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
    }
    
    // MARK: - Fetch Sleep Hours
    func fetchLastNightSleepHours() async -> Double {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.categorySample(type: sleepType, predicate: predicate)],
            sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)]
        )
        do {
            let samples = try await descriptor.result(for: healthStore)
            let totalSeconds = samples
                .filter { $0.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue }
                .reduce(0) { $0 + $1.endDate.timeIntervalSince($1.startDate)}
            return totalSeconds / 3600
        } catch {
            print("Failed to fetch sleep: \(error)")
            return 0
        }
    }
    
    // MARK: - Fetch Mindful Minutes
    func fetchTodayMindfulMinutes() async -> Double {
        let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay, end: now,
            options: .strictStartDate
        )
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.categorySample(type: mindfulType, predicate: predicate)], sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)]
        )
        do {
            let samples = try await descriptor.result(for: healthStore)
            let totalSeconds = samples
                .reduce(0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
            return totalSeconds / 60
        } catch {
            print("Failed to fetch mindful minutes: \(error)")
            return 0
        }
    }
    
    
}
