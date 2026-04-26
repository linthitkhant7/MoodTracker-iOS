//
//  HomeView.swift
//  MoodTracker-iOS
//
//  Created by Lin Thit on 4/23/26.
//

import SwiftUI

struct HomeView: View {
    @State private var showCheckIn = false
    var viewModel: MoodViewModel
    
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning 🌅"
        case 12..<17: return "Good Afternoon ☀️"
        case 17..<21: return "Good Evening 🌆"
        default: return "Good Night 🌙"
        }
    }
    
    private var averageMoodThisWeek: Double {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let recentEntries = viewModel.entries.filter { $0.date >= weekAgo }
        guard !recentEntries.isEmpty else { return 0 }
        let total = recentEntries.reduce(0) { $0 + $1.moodLevel.rawValue }
        return Double(total) / Double(recentEntries.count)
    }
    
    private var weeklyMoodSummary: String {
        let average = averageMoodThisWeek
        switch average {
        case 0: return "No entries this week"
        case ..<2: return "Tough week 💙 Keep going"
        case ..<3: return "Challenging week 🌱 You're trying"
        case ..<4: return "Decent week 😊 Stay consistent"
        case ..<5: return "Good week 🌟 Keep it up"
        default: return "Amazing week 🚀 You're thriving"
        }
    }
    
    private var currentStreak: Int {
        guard !viewModel.entries.isEmpty else { return 0 }
        let calendar = Calendar.current
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        for entry in viewModel.entries {
            let entryDate = calendar.startOfDay(for: entry.date)
            if entryDate == currentDate {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else if entryDate < currentDate {
                break
            }
        }
        return streak
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text(greetingText)
                            .font(.title)
                            .fontWeight(.bold)
                        Text(Date().formatted(date: .long, time: .omitted))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 32)
                    
                    // MARK: - Streak Card
                    if currentStreak > 0 {
                        HStack(spacing: 12) {
                            Text("🔥")
                                .font(.system(size: 32))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(currentStreak) day streak")
                                    .font(.headline)
                                Text("Keep logging your mood daily")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                    }
                    
                    // Health Summary
                    if viewModel.sleepHours > 0 || viewModel.mindfulMinutes > 0 {
                        HStack(spacing: 12) {
                            if viewModel.sleepHours > 0 {
                                HealthStatCard(
                                    icon: "moon.fill",
                                    value: String(format: "%.1f hrs", viewModel.sleepHours),
                                    label: "Sleep",
                                    color: .indigo
                                )
                            }
                            if viewModel.mindfulMinutes > 0 {
                                HealthStatCard(
                                    icon: "heart.fill",
                                    value: String(format: "%.0f min", viewModel.mindfulMinutes),
                                    label: "Mindful",
                                    color: .pink
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // MARK: - Weekly Summary Card
                    if averageMoodThisWeek > 0 {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("This Week")
                                .font(.headline)
                            Text(weeklyMoodSummary)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            // Mood bar
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(.systemGray5))
                                        .frame(height: 8)
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.indigo)
                                        .frame(
                                            width: geometry.size.width * (averageMoodThisWeek / 5),
                                            height: 8
                                        )
                                }
                            }
                            .frame(height: 8)
                            
                            HStack {
                                Text("Weekly average")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(String(format: "%.1f / 5.0", averageMoodThisWeek))
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.indigo)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                    }
                    
                    // Recent entries or empty state
                    if viewModel.entries.isEmpty {
                        emptyStateView
                    } else {
                        recentEntriesView
                    }
                    
                    Spacer()
                    
                    // Check in button
                    Button {
                        showCheckIn = true
                    } label: {
                        Label("Log Today's Mood", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.indigo)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("MoodTracker")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showCheckIn) {
                CheckInView(viewModel: viewModel)
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Text("😊")
                .font(.system(size: 64))
            Text("No entries yet")
                .font(.title3)
                .fontWeight(.semibold)
            Text("Tap the button below to log your first mood")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Recent Entries
    private var recentEntriesView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.entries, id: \.id) { entry in
                    HStack {
                        Text(entry.moodLevel.emoji)
                            .font(.system(size: 36))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.moodLevel.label)
                                .font(.headline)
                            Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
            }
        }
    }
    
    // MARK: - Health Stat Card
    struct HealthStatCard: View {
        let icon: String
        let value: String
        let label: String
        let color: Color
        
        var body: some View {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                VStack(alignment: .leading, spacing: 2) {
                    Text(value)
                        .font(.headline)
                    Text(label)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
