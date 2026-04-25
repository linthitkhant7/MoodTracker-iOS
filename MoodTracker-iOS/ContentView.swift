//
//  ContentView.swift
//  MoodTracker-iOS
//
//  Created by Lin Thit on 4/21/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: MoodViewModel?
    
    var body: some View {
        Group {
            if let viewModel {
                TabView {
                    HomeView(viewModel: viewModel)
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                    
                    HistoryView(viewModel: viewModel)
                        .tabItem {
                            Label("History", systemImage: "chart.line.uptrend.xyaxis")
                        }
                }
            }
        }
        .onAppear {
            viewModel = MoodViewModel(context: modelContext)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: MoodEntry.self, inMemory: true)
}					
