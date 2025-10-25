//
//  GameSession.swift
//  GG Time
//
//  Core data model for a gaming session.
//

import Foundation

/// Represents a gaming session with game details and participants
struct GameSession: Codable, Equatable {
    
    // MARK: - Properties
    
    /// Unique identifier for this session
    let id: UUID
    
    /// Name of the game to play
    let gameName: String
    
    /// Scheduled start time
    let startTime: Date
    
    /// Display name of the session host (creator)
    let hostName: String
    
    /// List of participants who confirmed they're joining
    var participants: [Participant]
    
    /// Timestamp when the session was created
    let createdAt: Date
    
    // MARK: - Nested Types
    
    /// Represents a participant in the gaming session
    struct Participant: Codable, Equatable, Identifiable {
        let id: UUID
        let name: String
        let status: ParticipantStatus
        let joinedAt: Date
        
        init(id: UUID = UUID(), name: String, status: ParticipantStatus, joinedAt: Date = Date()) {
            self.id = id
            self.name = name
            self.status = status
            self.joinedAt = joinedAt
        }
    }
    
    /// Status of a participant's attendance
    enum ParticipantStatus: String, Codable {
        case confirmed = "confirmed"  // Definitely joining
        case maybe = "maybe"          // Might join
    }
    
    // MARK: - Initialization
    
    init(
        id: UUID = UUID(),
        gameName: String,
        startTime: Date,
        hostName: String,
        participants: [Participant] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.gameName = gameName
        self.startTime = startTime
        self.hostName = hostName
        self.participants = participants
        self.createdAt = createdAt
    }
    
    // MARK: - Participant Management
    
    /// Adds or updates a participant in the session
    /// - Parameters:
    ///   - name: Display name of the participant
    ///   - status: Their attendance status
    /// - Returns: Updated session with the participant added/updated
    func addingOrUpdatingParticipant(name: String, status: ParticipantStatus) -> GameSession {
        var updatedParticipants = participants
        
        // Check if participant already exists
        if let index = updatedParticipants.firstIndex(where: { $0.name == name }) {
            // Update existing participant
            updatedParticipants[index] = Participant(
                id: updatedParticipants[index].id,
                name: name,
                status: status,
                joinedAt: updatedParticipants[index].joinedAt
            )
        } else {
            // Add new participant
            updatedParticipants.append(Participant(name: name, status: status))
        }
        
        return GameSession(
            id: id,
            gameName: gameName,
            startTime: startTime,
            hostName: hostName,
            participants: updatedParticipants,
            createdAt: createdAt
        )
    }
    
    /// Removes a participant from the session
    /// - Parameter name: Display name of the participant to remove
    /// - Returns: Updated session with the participant removed
    func removingParticipant(name: String) -> GameSession {
        let updatedParticipants = participants.filter { $0.name != name }
        
        return GameSession(
            id: id,
            gameName: gameName,
            startTime: startTime,
            hostName: hostName,
            participants: updatedParticipants,
            createdAt: createdAt
        )
    }
    
    /// Checks if a specific person is already in the session
    /// - Parameter name: Display name to check
    /// - Returns: True if the person is a participant
    func hasParticipant(name: String) -> Bool {
        return participants.contains { $0.name == name }
    }
    
    /// Gets the status of a specific participant
    /// - Parameter name: Display name to check
    /// - Returns: The participant's status, or nil if not found
    func participantStatus(for name: String) -> ParticipantStatus? {
        return participants.first { $0.name == name }?.status
    }
    
    // MARK: - Computed Properties
    
    /// Total number of confirmed participants
    var confirmedCount: Int {
        return participants.filter { $0.status == .confirmed }.count
    }
    
    /// Total number of maybe participants
    var maybeCount: Int {
        return participants.filter { $0.status == .maybe }.count
    }
    
    /// All confirmed participant names
    var confirmedNames: [String] {
        return participants
            .filter { $0.status == .confirmed }
            .map { $0.name }
    }
    
    /// All maybe participant names
    var maybeNames: [String] {
        return participants
            .filter { $0.status == .maybe }
            .map { $0.name }
    }
    
    /// Formatted time string (e.g., "7:30 PM")
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: startTime)
    }
    
    /// Formatted date string (e.g., "Today", "Tomorrow", or "Dec 25")
    var formattedDate: String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(startTime) {
            return "Today"
        } else if calendar.isDateInTomorrow(startTime) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: startTime)
        }
    }
}

// MARK: - Sample Data (for previews and testing)

extension GameSession {
    /// Sample session for SwiftUI previews
    static let sample = GameSession(
        gameName: "Valorant",
        startTime: Date().addingTimeInterval(3600), // 1 hour from now
        hostName: "Alex",
        participants: [
            Participant(name: "Sam", status: .confirmed),
            Participant(name: "Jordan", status: .maybe)
        ]
    )
}

