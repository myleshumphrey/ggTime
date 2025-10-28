//
//  SessionBubbleView.swift
//  GG Time
//
//  SwiftUI view for displaying a gaming session card in iMessage.
//  Shows game details, participants, and Join/Maybe buttons.
//

import SwiftUI

/// View that displays a gaming session card (used in iMessage bubble)
struct SessionBubbleView: View {
    
    // MARK: - Properties
    
    /// The gaming session to display
    let session: GameSession
    
    /// Current user's display name (optional, used to highlight their status)
    let currentUserName: String?
    
    /// Callback when user taps "Join"
    let onJoin: (() -> Void)?
    
    /// Callback when user taps "Maybe"
    let onMaybe: (() -> Void)?
    
    /// Callback when user taps "Leave"
    let onLeave: (() -> Void)?
    
    /// Callback when user taps "Join at Different Time"
    let onJoinDifferentTime: (() -> Void)?
    
    /// Callback when user taps "Can't Join"
    let onCantJoin: (() -> Void)?
    
    /// Whether this is an interactive bubble (false for compact/message history view)
    let isInteractive: Bool
    
    // MARK: - Initialization
    
    init(
        session: GameSession,
        currentUserName: String? = nil,
        isInteractive: Bool = true,
        onJoin: (() -> Void)? = nil,
        onMaybe: (() -> Void)? = nil,
        onLeave: (() -> Void)? = nil,
        onJoinDifferentTime: (() -> Void)? = nil,
        onCantJoin: (() -> Void)? = nil
    ) {
        self.session = session
        self.currentUserName = currentUserName
        self.isInteractive = isInteractive
        self.onJoin = onJoin
        self.onMaybe = onMaybe
        self.onLeave = onLeave
        self.onJoinDifferentTime = onJoinDifferentTime
        self.onCantJoin = onCantJoin
        
        print("🔍 SessionBubbleView init - hasParticipant: \(session.hasParticipant(name: currentUserName ?? ""))")
        print("🔍 SessionBubbleView init - onCantJoin callback: \(onCantJoin != nil ? "SET" : "NIL")")
    }
    
    // MARK: - Computed Properties
    
    /// User's current participation status
    private var userStatus: GameSession.ParticipantStatus? {
        guard let userName = currentUserName else { return nil }
        return session.participantStatus(for: userName)
    }
    
    /// Whether the current user is participating
    private var isUserParticipating: Bool {
        guard let userName = currentUserName else { return false }
        return session.hasParticipant(name: userName)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with game name and time
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "gamecontroller.fill")
                        .foregroundColor(.purple)
                    Text(session.gameName)
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(session.formattedDate) at \(session.formattedTime)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "person.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Hosted by \(session.hostName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .padding()
            .background(Color.purple.opacity(0.1))
            
            Divider()
            
            // Participants section
            VStack(alignment: .leading, spacing: 12) {
                if session.confirmedCount > 0 {
                    ParticipantRow(
                        icon: "checkmark.circle.fill",
                        color: .green,
                        title: "Confirmed (\(session.confirmedCount))",
                        names: session.confirmedNames,
                        currentUserName: currentUserName
                    )
                }
                
                if session.maybeCount > 0 {
                    ParticipantRow(
                        icon: "questionmark.circle.fill",
                        color: .orange,
                        title: "Maybe (\(session.maybeCount))",
                        names: session.maybeNames,
                        currentUserName: currentUserName
                    )
                }
                
                if session.differentTimeCount > 0 {
                    DifferentTimeRow(
                        participants: session.differentTimeParticipants,
                        currentUserName: currentUserName
                    )
                }
                
                if session.cantJoinCount > 0 {
                    ParticipantRow(
                        icon: "xmark.circle.fill",
                        color: .red,
                        title: "Can't Join (\(session.cantJoinCount))",
                        names: session.cantJoinNames,
                        currentUserName: currentUserName
                    )
                }
                
                if session.confirmedCount == 0 && session.maybeCount == 0 && session.differentTimeCount == 0 && session.cantJoinCount == 0 {
                    HStack {
                        Image(systemName: "person.2")
                            .foregroundColor(.secondary)
                        Text("No one has joined yet")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
            .padding()
            
            // Action buttons (only if interactive)
            if isInteractive {
                Divider()
                
                let _ = print("🔍 DEBUG: isUserParticipating = \(isUserParticipating), userStatus = \(String(describing: userStatus))")
                
                if isUserParticipating {
                    // User is already participating - show leave button
                    let _ = print("🔍 DEBUG: Showing Leave button")
                    Button(action: {
                        onLeave?()
                    }) {
                        HStack {
                            Image(systemName: "xmark.circle")
                            Text("Leave Session")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.red)
                    }
                } else {
                    // User hasn't joined - show all 4 join options
                    let _ = print("🔍 DEBUG: Showing 4-button layout")
                    VStack(spacing: 0) {
                        // Top row: Join and Maybe buttons
                        HStack(spacing: 0) {
                            Button(action: {
                                onJoin?()
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title3)
                                    Text("Join")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .foregroundColor(.white)
                                .background(Color.green)
                            }
                            
                            Divider()
                            
                            Button(action: {
                                onMaybe?()
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: "questionmark.circle.fill")
                                        .font(.title3)
                                    Text("Maybe")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .foregroundColor(.white)
                                .background(Color.orange)
                            }
                        }
                        
                        Divider()
                        
                        // Bottom row: Different Time and Can't Join buttons
                        HStack(spacing: 0) {
                            Button(action: {
                                onJoinDifferentTime?()
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: "clock.arrow.circlepath")
                                        .font(.title3)
                                    Text("Different Time")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .foregroundColor(.white)
                                .background(Color.blue)
                            }
                            
                            Divider()
                            
                            Button(action: {
                                onCantJoin?()
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title3)
                                    Text("Can't Join")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .foregroundColor(.white)
                                .background(Color.red)
                            }
                        }
                    }
                }
            }
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.purple.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Different Time Row

struct DifferentTimeRow: View {
    let participants: [(name: String, joinTime: Date)]
    let currentUserName: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundColor(.blue)
                Text("Different Time (\(participants.count))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(participants, id: \.name) { participant in
                    DifferentTimeTag(
                        name: participant.name,
                        joinTime: participant.joinTime,
                        isCurrentUser: participant.name == currentUserName
                    )
                }
            }
        }
    }
}

// MARK: - Different Time Tag

struct DifferentTimeTag: View {
    let name: String
    let joinTime: Date
    let isCurrentUser: Bool
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: joinTime)
    }
    
    var body: some View {
        HStack(spacing: 6) {
            Text(name)
                .font(.caption)
                .fontWeight(isCurrentUser ? .bold : .regular)
                .foregroundColor(isCurrentUser ? .blue : .primary)
            
            Text("at \(formattedTime)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.blue.opacity(isCurrentUser ? 0.3 : 0.15))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCurrentUser ? Color.blue : Color.clear, lineWidth: 1)
        )
    }
}

// MARK: - Participant Row

struct ParticipantRow: View {
    let icon: String
    let color: Color
    let title: String
    let names: [String]
    let currentUserName: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            WrappingHStack(spacing: 6) {
                ForEach(names, id: \.self) { name in
                    ParticipantTag(
                        name: name,
                        isCurrentUser: name == currentUserName,
                        color: color
                    )
                }
            }
        }
    }
}

// MARK: - Participant Tag

struct ParticipantTag: View {
    let name: String
    let isCurrentUser: Bool
    let color: Color
    
    var body: some View {
        Text(name)
            .font(.caption)
            .fontWeight(isCurrentUser ? .bold : .regular)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(isCurrentUser ? 0.3 : 0.15))
            .foregroundColor(isCurrentUser ? color.darker() : .primary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isCurrentUser ? color : Color.clear, lineWidth: 1)
            )
    }
}

// MARK: - Wrapping HStack (for wrapping participant tags - iOS 15+ Compatible)

/// Simple horizontal stack for participant tags
/// Note: This uses a basic HStack. For perfect wrapping, you'd need iOS 16+ Layout protocol.
/// This works well enough for most cases on iOS 15.
struct WrappingHStack<Content: View>: View {
    let spacing: CGFloat
    let content: Content
    
    init(spacing: CGFloat = 8, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }
    
    var body: some View {
        // Simple horizontal stack that works on iOS 15+
        // Participant tags will display in a row
        HStack(spacing: spacing) {
            content
        }
    }
}

// MARK: - Color Extension

extension Color {
    /// Returns a darker version of the color
    func darker(by percentage: CGFloat = 0.3) -> Color {
        return self.opacity(1.0 - percentage)
    }
}

// MARK: - Preview

#if DEBUG
struct SessionBubbleView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Session with participants
            SessionBubbleView(
                session: GameSession.sample,
                currentUserName: "Sam",
                isInteractive: true,
                onJoin: { print("Join") },
                onMaybe: { print("Maybe") },
                onLeave: { print("Leave") },
                onJoinDifferentTime: { print("Join at Different Time") }
            )
            .padding()
            
            // Empty session
            SessionBubbleView(
                session: GameSession(
                    gameName: "Apex Legends",
                    startTime: Date().addingTimeInterval(7200),
                    hostName: "Taylor"
                ),
                currentUserName: "Alex",
                isInteractive: true,
                onJoin: { print("Join") },
                onMaybe: { print("Maybe") },
                onLeave: { print("Leave") },
                onJoinDifferentTime: { print("Join at Different Time") }
            )
            .padding()
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif

