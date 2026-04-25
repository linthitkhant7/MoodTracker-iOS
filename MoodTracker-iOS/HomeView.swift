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
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("How are you feeling?")
                            .font(.title)
                            .fontWeight(.bold)
                        Text(Date().formatted(date: .long, time: .omitted))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 32)
                    
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
