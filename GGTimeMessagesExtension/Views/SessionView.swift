//
//  SessionView.swift
//  GG Time
//
//  SwiftUI view for creating a new gaming session.
//  Allows users to pick a game and choose a start time.
//

import SwiftUI

/// Main view for creating a new gaming session
struct SessionView: View {
    
    // MARK: - Properties
    
    /// The game name being entered
    @State private var gameName: String = ""
    
    /// The selected start time
    @State private var startTime: Date = Date().addingTimeInterval(3600) // Default: 1 hour from now
    
    /// Selected popular game (if any)
    @State private var selectedPopularGame: String? = nil
    
    /// Callback when user taps "Share"
    let onShare: (String, Date) -> Void
    
    /// Callback when user taps "Cancel"
    let onCancel: () -> Void
    
    // MARK: - Popular Games
    
    private let popularGames = [
        "🎮 Valorant",
        "⚔️ League of Legends",
        "🔫 Call of Duty",
        "🏗️ Fortnite",
        "🎯 Apex Legends",
        "⛏️ Minecraft",
        "🚀 Rocket League",
        "👾 Among Us"
    ]
    
    // MARK: - Computed Properties
    
    /// Whether the share button should be enabled
    private var canShare: Bool {
        return !effectiveGameName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    /// The game name to use (custom or selected popular game)
    private var effectiveGameName: String {
        if let selected = selectedPopularGame {
            return selected
        }
        return gameName
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.purple)
                        
                        Text("Plan a Gaming Session")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Let your friends know when you're playing")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Game Selection Section
                    VStack(alignment: .leading, spacing: 12) {
                        Label("What game?", systemImage: "gamecontroller")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        // Custom game name input
                        TextField("Enter game name...", text: $gameName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disabled(selectedPopularGame != nil)
                            .onChange(of: gameName) { _ in
                                if !gameName.isEmpty {
                                    selectedPopularGame = nil
                                }
                            }
                        
                        Text("or pick a popular game:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                        
                        // Popular games grid
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(popularGames, id: \.self) { game in
                                PopularGameButton(
                                    title: game,
                                    isSelected: selectedPopularGame == game
                                ) {
                                    if selectedPopularGame == game {
                                        selectedPopularGame = nil
                                    } else {
                                        selectedPopularGame = game
                                        gameName = ""
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Time Selection Section
                    VStack(alignment: .leading, spacing: 12) {
                        Label("When?", systemImage: "clock")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        DatePicker(
                            "Start Time",
                            selection: $startTime,
                            in: Date()...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .padding(.vertical, 8)
                        
                        // Time preview
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.purple)
                            Text(formatDateTime(startTime))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            onShare(effectiveGameName, startTime)
                        }) {
                            HStack {
                                Image(systemName: "paperplane.fill")
                                Text("Share Session")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(canShare ? Color.purple : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(!canShare)
                        
                        Button(action: onCancel) {
                            Text("Cancel")
                                .foregroundColor(.secondary)
                                .padding(.vertical, 8)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Formats a date/time in a friendly way
    private func formatDateTime(_ date: Date) -> String {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        
        if calendar.isDateInToday(date) {
            dateFormatter.dateFormat = "'Today at' h:mm a"
        } else if calendar.isDateInTomorrow(date) {
            dateFormatter.dateFormat = "'Tomorrow at' h:mm a"
        } else {
            dateFormatter.dateFormat = "MMM d 'at' h:mm a"
        }
        
        return dateFormatter.string(from: date)
    }
}

// MARK: - Popular Game Button

struct PopularGameButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14))
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? Color.purple : Color.gray.opacity(0.2))
                .cornerRadius(10)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct SessionView_Previews: PreviewProvider {
    static var previews: some View {
        SessionView(
            onShare: { game, time in
                print("Share: \(game) at \(time)")
            },
            onCancel: {
                print("Cancelled")
            }
        )
    }
}
#endif

