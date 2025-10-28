//
//  GameSessionTests.swift
//  GG Time Tests
//
//  Unit tests for GameSession model
//

import XCTest
@testable import ggTime_MessagesExtension

final class GameSessionTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testSessionInitialization() {
        // Given
        let gameName = "Valorant"
        let startTime = Date()
        let hostName = "TestPlayer"
        
        // When
        let session = GameSession(
            gameName: gameName,
            startTime: startTime,
            hostName: hostName
        )
        
        // Then
        XCTAssertEqual(session.gameName, gameName)
        XCTAssertEqual(session.startTime, startTime)
        XCTAssertEqual(session.hostName, hostName)
        XCTAssertTrue(session.participants.isEmpty)
        XCTAssertNotNil(session.id)
    }
    
    func testSessionWithParticipants() {
        // Given
        let participants = [
            GameSession.Participant(name: "Player1", status: .confirmed),
            GameSession.Participant(name: "Player2", status: .maybe)
        ]
        
        // When
        let session = GameSession(
            gameName: "Minecraft",
            startTime: Date(),
            hostName: "Host",
            participants: participants
        )
        
        // Then
        XCTAssertEqual(session.participants.count, 2)
        XCTAssertEqual(session.confirmedCount, 1)
        XCTAssertEqual(session.maybeCount, 1)
    }
    
    // MARK: - Participant Management Tests
    
    func testAddingNewParticipant() {
        // Given
        let session = GameSession(
            gameName: "Fortnite",
            startTime: Date(),
            hostName: "Host"
        )
        
        // When
        let updatedSession = session.addingOrUpdatingParticipant(
            name: "NewPlayer",
            status: .confirmed
        )
        
        // Then
        XCTAssertEqual(updatedSession.participants.count, 1)
        XCTAssertEqual(updatedSession.participants[0].name, "NewPlayer")
        XCTAssertEqual(updatedSession.participants[0].status, .confirmed)
        XCTAssertTrue(updatedSession.hasParticipant(name: "NewPlayer"))
    }
    
    func testUpdatingExistingParticipant() {
        // Given
        let participant = GameSession.Participant(name: "Player1", status: .maybe)
        let session = GameSession(
            gameName: "Among Us",
            startTime: Date(),
            hostName: "Host",
            participants: [participant]
        )
        
        // When - Change status from maybe to confirmed
        let updatedSession = session.addingOrUpdatingParticipant(
            name: "Player1",
            status: .confirmed
        )
        
        // Then
        XCTAssertEqual(updatedSession.participants.count, 1)
        XCTAssertEqual(updatedSession.participants[0].status, .confirmed)
        XCTAssertEqual(updatedSession.confirmedCount, 1)
        XCTAssertEqual(updatedSession.maybeCount, 0)
    }
    
    func testAddingParticipantWithDifferentTime() {
        // Given
        let session = GameSession(
            gameName: "Call of Duty",
            startTime: Date(),
            hostName: "Host"
        )
        let differentTime = Date().addingTimeInterval(3600) // 1 hour later
        
        // When
        let updatedSession = session.addingOrUpdatingParticipant(
            name: "LatePlayer",
            status: .differentTime,
            joinTime: differentTime
        )
        
        // Then
        XCTAssertEqual(updatedSession.differentTimeCount, 1)
        XCTAssertEqual(updatedSession.differentTimeParticipants.count, 1)
        XCTAssertEqual(updatedSession.differentTimeParticipants[0].name, "LatePlayer")
        XCTAssertEqual(updatedSession.differentTimeParticipants[0].joinTime, differentTime)
    }
    
    func testRemovingParticipant() {
        // Given
        let participants = [
            GameSession.Participant(name: "Player1", status: .confirmed),
            GameSession.Participant(name: "Player2", status: .maybe),
            GameSession.Participant(name: "Player3", status: .confirmed)
        ]
        let session = GameSession(
            gameName: "Rocket League",
            startTime: Date(),
            hostName: "Host",
            participants: participants
        )
        
        // When
        let updatedSession = session.removingParticipant(name: "Player2")
        
        // Then
        XCTAssertEqual(updatedSession.participants.count, 2)
        XCTAssertFalse(updatedSession.hasParticipant(name: "Player2"))
        XCTAssertTrue(updatedSession.hasParticipant(name: "Player1"))
        XCTAssertTrue(updatedSession.hasParticipant(name: "Player3"))
    }
    
    func testRemovingNonexistentParticipant() {
        // Given
        let participants = [
            GameSession.Participant(name: "Player1", status: .confirmed)
        ]
        let session = GameSession(
            gameName: "Apex Legends",
            startTime: Date(),
            hostName: "Host",
            participants: participants
        )
        
        // When
        let updatedSession = session.removingParticipant(name: "NonexistentPlayer")
        
        // Then
        XCTAssertEqual(updatedSession.participants.count, 1)
    }
    
    // MARK: - Participant Status Tests
    
    func testParticipantStatusCheck() {
        // Given
        let participants = [
            GameSession.Participant(name: "Player1", status: .confirmed),
            GameSession.Participant(name: "Player2", status: .maybe),
            GameSession.Participant(name: "Player3", status: .cantJoin)
        ]
        let session = GameSession(
            gameName: "League of Legends",
            startTime: Date(),
            hostName: "Host",
            participants: participants
        )
        
        // Then
        XCTAssertEqual(session.participantStatus(for: "Player1"), .confirmed)
        XCTAssertEqual(session.participantStatus(for: "Player2"), .maybe)
        XCTAssertEqual(session.participantStatus(for: "Player3"), .cantJoin)
        XCTAssertNil(session.participantStatus(for: "NonexistentPlayer"))
    }
    
    func testHasParticipant() {
        // Given
        let participants = [
            GameSession.Participant(name: "Alice", status: .confirmed),
            GameSession.Participant(name: "Bob", status: .maybe)
        ]
        let session = GameSession(
            gameName: "Overwatch",
            startTime: Date(),
            hostName: "Host",
            participants: participants
        )
        
        // Then
        XCTAssertTrue(session.hasParticipant(name: "Alice"))
        XCTAssertTrue(session.hasParticipant(name: "Bob"))
        XCTAssertFalse(session.hasParticipant(name: "Charlie"))
    }
    
    // MARK: - Count Tests
    
    func testParticipantCounts() {
        // Given
        let participants = [
            GameSession.Participant(name: "P1", status: .confirmed),
            GameSession.Participant(name: "P2", status: .confirmed),
            GameSession.Participant(name: "P3", status: .maybe),
            GameSession.Participant(name: "P4", status: .differentTime, joinTime: Date()),
            GameSession.Participant(name: "P5", status: .cantJoin)
        ]
        let session = GameSession(
            gameName: "Minecraft",
            startTime: Date(),
            hostName: "Host",
            participants: participants
        )
        
        // Then
        XCTAssertEqual(session.confirmedCount, 2)
        XCTAssertEqual(session.maybeCount, 1)
        XCTAssertEqual(session.differentTimeCount, 1)
        XCTAssertEqual(session.cantJoinCount, 1)
    }
    
    func testEmptySessionCounts() {
        // Given
        let session = GameSession(
            gameName: "Test Game",
            startTime: Date(),
            hostName: "Host"
        )
        
        // Then
        XCTAssertEqual(session.confirmedCount, 0)
        XCTAssertEqual(session.maybeCount, 0)
        XCTAssertEqual(session.differentTimeCount, 0)
        XCTAssertEqual(session.cantJoinCount, 0)
    }
    
    // MARK: - Name Lists Tests
    
    func testConfirmedNames() {
        // Given
        let participants = [
            GameSession.Participant(name: "Alice", status: .confirmed),
            GameSession.Participant(name: "Bob", status: .maybe),
            GameSession.Participant(name: "Charlie", status: .confirmed)
        ]
        let session = GameSession(
            gameName: "Test",
            startTime: Date(),
            hostName: "Host",
            participants: participants
        )
        
        // Then
        XCTAssertEqual(session.confirmedNames.count, 2)
        XCTAssertTrue(session.confirmedNames.contains("Alice"))
        XCTAssertTrue(session.confirmedNames.contains("Charlie"))
        XCTAssertFalse(session.confirmedNames.contains("Bob"))
    }
    
    func testMaybeNames() {
        // Given
        let participants = [
            GameSession.Participant(name: "Alice", status: .maybe),
            GameSession.Participant(name: "Bob", status: .confirmed),
            GameSession.Participant(name: "Charlie", status: .maybe)
        ]
        let session = GameSession(
            gameName: "Test",
            startTime: Date(),
            hostName: "Host",
            participants: participants
        )
        
        // Then
        XCTAssertEqual(session.maybeNames.count, 2)
        XCTAssertTrue(session.maybeNames.contains("Alice"))
        XCTAssertTrue(session.maybeNames.contains("Charlie"))
    }
    
    func testCantJoinNames() {
        // Given
        let participants = [
            GameSession.Participant(name: "Alice", status: .cantJoin),
            GameSession.Participant(name: "Bob", status: .confirmed),
            GameSession.Participant(name: "Charlie", status: .cantJoin)
        ]
        let session = GameSession(
            gameName: "Test",
            startTime: Date(),
            hostName: "Host",
            participants: participants
        )
        
        // Then
        XCTAssertEqual(session.cantJoinNames.count, 2)
        XCTAssertTrue(session.cantJoinNames.contains("Alice"))
        XCTAssertTrue(session.cantJoinNames.contains("Charlie"))
    }
    
    func testDifferentTimeParticipants() {
        // Given
        let time1 = Date().addingTimeInterval(3600)
        let time2 = Date().addingTimeInterval(7200)
        let participants = [
            GameSession.Participant(name: "Alice", status: .differentTime, joinTime: time1),
            GameSession.Participant(name: "Bob", status: .confirmed),
            GameSession.Participant(name: "Charlie", status: .differentTime, joinTime: time2)
        ]
        let session = GameSession(
            gameName: "Test",
            startTime: Date(),
            hostName: "Host",
            participants: participants
        )
        
        // Then
        XCTAssertEqual(session.differentTimeParticipants.count, 2)
        XCTAssertTrue(session.differentTimeParticipants.contains { $0.name == "Alice" && $0.joinTime == time1 })
        XCTAssertTrue(session.differentTimeParticipants.contains { $0.name == "Charlie" && $0.joinTime == time2 })
    }
    
    // MARK: - Date Formatting Tests
    
    func testFormattedTime() {
        // Given
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = 14
        components.minute = 30
        let startTime = calendar.date(from: components)!
        
        let session = GameSession(
            gameName: "Test",
            startTime: startTime,
            hostName: "Host"
        )
        
        // Then
        // Time formatting depends on locale, so just verify it's not empty
        XCTAssertFalse(session.formattedTime.isEmpty)
        XCTAssertTrue(session.formattedTime.contains("2") || session.formattedTime.contains("14"))
    }
    
    func testFormattedDateToday() {
        // Given
        let session = GameSession(
            gameName: "Test",
            startTime: Date(),
            hostName: "Host"
        )
        
        // Then
        XCTAssertEqual(session.formattedDate, "Today")
    }
    
    func testFormattedDateTomorrow() {
        // Given
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let session = GameSession(
            gameName: "Test",
            startTime: tomorrow,
            hostName: "Host"
        )
        
        // Then
        XCTAssertEqual(session.formattedDate, "Tomorrow")
    }
    
    func testFormattedDateFuture() {
        // Given
        let futureDate = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
        let session = GameSession(
            gameName: "Test",
            startTime: futureDate,
            hostName: "Host"
        )
        
        // Then
        XCTAssertNotEqual(session.formattedDate, "Today")
        XCTAssertNotEqual(session.formattedDate, "Tomorrow")
        XCTAssertFalse(session.formattedDate.isEmpty)
    }
    
    // MARK: - Codable Tests
    
    func testEncodingAndDecoding() throws {
        // Given
        let participants = [
            GameSession.Participant(name: "Player1", status: .confirmed),
            GameSession.Participant(name: "Player2", status: .maybe)
        ]
        let originalSession = GameSession(
            gameName: "Valorant",
            startTime: Date(),
            hostName: "Host",
            participants: participants
        )
        
        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalSession)
        
        let decoder = JSONDecoder()
        let decodedSession = try decoder.decode(GameSession.self, from: data)
        
        // Then
        XCTAssertEqual(decodedSession.id, originalSession.id)
        XCTAssertEqual(decodedSession.gameName, originalSession.gameName)
        XCTAssertEqual(decodedSession.hostName, originalSession.hostName)
        XCTAssertEqual(decodedSession.participants.count, originalSession.participants.count)
        XCTAssertEqual(decodedSession.confirmedCount, originalSession.confirmedCount)
    }
    
    // MARK: - Equatable Tests
    
    func testEquality() {
        // Given
        let id = UUID()
        let startTime = Date()
        
        let session1 = GameSession(
            id: id,
            gameName: "Game",
            startTime: startTime,
            hostName: "Host"
        )
        
        let session2 = GameSession(
            id: id,
            gameName: "Game",
            startTime: startTime,
            hostName: "Host"
        )
        
        // Then
        XCTAssertEqual(session1, session2)
    }
    
    func testInequality() {
        // Given
        let session1 = GameSession(
            gameName: "Game1",
            startTime: Date(),
            hostName: "Host"
        )
        
        let session2 = GameSession(
            gameName: "Game2",
            startTime: Date(),
            hostName: "Host"
        )
        
        // Then
        XCTAssertNotEqual(session1, session2)
    }
}

