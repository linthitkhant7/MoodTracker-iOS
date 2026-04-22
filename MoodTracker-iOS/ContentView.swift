//
//  ContentView.swift
//  MoodTracker-iOS
//
//  Created by Lin Thit on 4/21/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MoodCheckInView()
                .tabItem {
                    Label("Check-In", systemImage: "square.and.pencil")
                }

            MoodHistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
        }
    }
}

#Preview {
    ContentView()
}
