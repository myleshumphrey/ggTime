//
//  MessageEncodingTests.swift
//  GG Time Tests
//
//  Unit tests for MessageEncoding utility
//

import XCTest
@testable import ggTime_MessagesExtension

final class MessageEncodingTests: XCTestCase {
    
    // MARK: - Encoding Tests
    
    func testEncodeSimpleSession() {
        // Given
        let session = GameSession(
            gameName: "Valorant",
            startTime: Date(),
            hostName: "TestPlayer"
        )
        
        // When
        let url = MessageEncoding.encode(session: session)
        
        // Then
        XCTAssertNotNil(url, "Encoding should produce a valid URL")
        XCTAssertEqual(url?.scheme, "ggtime")
        XCTAssertEqual(url?.host, "session")
    }
    
    func testEncodeSessionWithParticipants() {
        // Given
        let participants = [
            GameSession.Participant(name: "Player1", status: .confirmed),
            GameSession.Participant(name: "Player2", status: .maybe),
            GameSession.Participant(name: "Player3", status: .differentTime, joinTime: Date())
        ]
        let session = GameSession(
            gameName: "Minecraft",
            startTime: Date(),
            hostName: "Host",
            participants: participants
        )
        
        // When
        let url = MessageEncoding.encode(session: session)
        
        // Then
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("data=") ?? false)
    }
    
    // MARK: - Decoding Tests
    
    func testDecodeValidURL() {
        // Given
        let originalSession = GameSession(
            gameName: "League of Legends",
            startTime: Date(),
            hostName: "TestHost"
        )
        let url = MessageEncoding.encode(session: originalSession)
        
        // When
        let decodedSession = MessageEncoding.decode(from: url)
        
        // Then
        XCTAssertNotNil(decodedSession)
        XCTAssertEqual(decodedSession?.gameName, originalSession.gameName)
        XCTAssertEqual(decodedSession?.hostName, originalSession.hostName)
        XCTAssertEqual(decodedSession?.id, originalSession.id)
    }
    
    func testDecodeNilURL() {
        // When
        let session = MessageEncoding.decode(from: nil)
        
        // Then
        XCTAssertNil(session)
    }
    
    func testDecodeInvalidScheme() {
        // Given
        let invalidURL = URL(string: "https://example.com")
        
        // When
        let session = MessageEncoding.decode(from: invalidURL)
        
        // Then
        XCTAssertNil(session)
    }
    
    func testDecodeInvalidHost() {
        // Given
        let invalidURL = URL(string: "ggtime://wronghost?data=test")
        
        // When
        let session = MessageEncoding.decode(from: invalidURL)
        
        // Then
        XCTAssertNil(session)
    }
    
    func testDecodeMissingData() {
        // Given
        let invalidURL = URL(string: "ggtime://session")
        
        // When
        let session = MessageEncoding.decode(from: invalidURL)
        
        // Then
        XCTAssertNil(session)
    }
    
    func testDecodeInvalidBase64() {
        // Given
        let invalidURL = URL(string: "ggtime://session?data=invalid!!!")
        
        // When
        let session = MessageEncoding.decode(from: invalidURL)
        
        // Then
        XCTAssertNil(session)
    }
    
    // MARK: - Round-Trip Tests
    
    func testEncodeDecodeRoundTrip() {
        // Given
        let originalSession = GameSession(
            gameName: "Apex Legends",
            startTime: Date(),
            hostName: "Host",
            participants: [
                GameSession.Participant(name: "Alice", status: .confirmed),
                GameSession.Participant(name: "Bob", status: .maybe)
            ]
        )
        
        // When
        let url = MessageEncoding.encode(session: originalSession)
        let decodedSession = MessageEncoding.decode(from: url)
        
        // Then
        XCTAssertNotNil(decodedSession)
        XCTAssertEqual(decodedSession, originalSession)
    }
    
    func testRoundTripWithDifferentTimeParticipants() {
        // Given
        let differentTime = Date().addingTimeInterval(3600)
        let originalSession = GameSession(
            gameName: "Call of Duty",
            startTime: Date(),
            hostName: "Host",
            participants: [
                GameSession.Participant(name: "Early", status: .confirmed),
                GameSession.Participant(name: "Late", status: .differentTime, joinTime: differentTime),
                GameSession.Participant(name: "Maybe", status: .maybe),
                GameSession.Participant(name: "Busy", status: .cantJoin)
            ]
        )
        
        // When
        let url = MessageEncoding.encode(session: originalSession)
        let decodedSession = MessageEncoding.decode(from: url)
        
        // Then
        XCTAssertNotNil(decodedSession)
        XCTAssertEqual(decodedSession?.confirmedCount, 1)
        XCTAssertEqual(decodedSession?.differentTimeCount, 1)
        XCTAssertEqual(decodedSession?.maybeCount, 1)
        XCTAssertEqual(decodedSession?.cantJoinCount, 1)
        
        // Verify the different time is preserved
        let lateParticipant = decodedSession?.differentTimeParticipants.first
        XCTAssertEqual(lateParticipant?.name, "Late")
        XCTAssertNotNil(lateParticipant?.joinTime)
    }
    
    func testRoundTripPreservesAllData() {
        // Given
        let id = UUID()
        let startTime = Date()
        let createdAt = Date().addingTimeInterval(-3600)
        
        let originalSession = GameSession(
            id: id,
            gameName: "Fortnite",
            startTime: startTime,
            hostName: "TestHost",
            participants: [
                GameSession.Participant(
                    id: UUID(),
                    name: "Player1",
                    status: .confirmed,
                    joinedAt: createdAt
                )
            ],
            createdAt: createdAt
        )
        
        // When
        let url = MessageEncoding.encode(session: originalSession)
        let decodedSession = MessageEncoding.decode(from: url)
        
        // Then
        XCTAssertEqual(decodedSession?.id, id)
        XCTAssertEqual(decodedSession?.gameName, "Fortnite")
        XCTAssertEqual(decodedSession?.hostName, "TestHost")
        XCTAssertEqual(decodedSession?.participants.count, 1)
        XCTAssertEqual(decodedSession?.participants.first?.name, "Player1")
    }
    
    // MARK: - Validation Tests
    
    func testIsValidSessionURL() {
        // Given
        let validSession = GameSession(
            gameName: "Test",
            startTime: Date(),
            hostName: "Host"
        )
        let validURL = MessageEncoding.encode(session: validSession)
        let invalidURL = URL(string: "https://example.com")
        
        // Then
        XCTAssertTrue(MessageEncoding.isValidSessionURL(validURL))
        XCTAssertFalse(MessageEncoding.isValidSessionURL(invalidURL))
        XCTAssertFalse(MessageEncoding.isValidSessionURL(nil))
    }
    
    // MARK: - Quick Info Extraction Tests
    
    func testExtractQuickInfo() {
        // Given
        let gameName = "Rocket League"
        let startTime = Date()
        let session = GameSession(
            gameName: gameName,
            startTime: startTime,
            hostName: "Host"
        )
        let url = MessageEncoding.encode(session: session)
        
        // When
        let info = MessageEncoding.extractQuickInfo(from: url)
        
        // Then
        XCTAssertNotNil(info)
        XCTAssertEqual(info?.gameName, gameName)
        XCTAssertEqual(info?.startTime.timeIntervalSince1970, startTime.timeIntervalSince1970, accuracy: 1.0)
    }
    
    func testExtractQuickInfoFromInvalidURL() {
        // Given
        let invalidURL = URL(string: "https://example.com")
        
        // When
        let info = MessageEncoding.extractQuickInfo(from: invalidURL)
        
        // Then
        XCTAssertNil(info)
    }
    
    // MARK: - Edge Cases
    
    func testEncodeLongGameName() {
        // Given
        let longName = String(repeating: "A", count: 500)
        let session = GameSession(
            gameName: longName,
            startTime: Date(),
            hostName: "Host"
        )
        
        // When
        let url = MessageEncoding.encode(session: session)
        let decodedSession = MessageEncoding.decode(from: url)
        
        // Then
        XCTAssertNotNil(url)
        XCTAssertEqual(decodedSession?.gameName, longName)
    }
    
    func testEncodeSpecialCharacters() {
        // Given
        let specialName = "🎮 Game with émoji & sp€cial ch@rs! 🚀"
        let session = GameSession(
            gameName: specialName,
            startTime: Date(),
            hostName: "Hóst Nåme"
        )
        
        // When
        let url = MessageEncoding.encode(session: session)
        let decodedSession = MessageEncoding.decode(from: url)
        
        // Then
        XCTAssertNotNil(url)
        XCTAssertEqual(decodedSession?.gameName, specialName)
        XCTAssertEqual(decodedSession?.hostName, "Hóst Nåme")
    }
    
    func testEncodeManyParticipants() {
        // Given
        let participants = (0..<50).map { i in
            GameSession.Participant(
                name: "Player\(i)",
                status: i % 4 == 0 ? .confirmed : i % 4 == 1 ? .maybe : i % 4 == 2 ? .differentTime : .cantJoin,
                joinTime: i % 4 == 2 ? Date().addingTimeInterval(Double(i) * 3600) : nil
            )
        }
        let session = GameSession(
            gameName: "Large Session",
            startTime: Date(),
            hostName: "Host",
            participants: participants
        )
        
        // When
        let url = MessageEncoding.encode(session: session)
        let decodedSession = MessageEncoding.decode(from: url)
        
        // Then
        XCTAssertNotNil(url)
        XCTAssertEqual(decodedSession?.participants.count, 50)
    }
    
    // MARK: - Performance Tests
    
    func testEncodingPerformance() {
        let session = GameSession(
            gameName: "Performance Test",
            startTime: Date(),
            hostName: "Host",
            participants: (0..<20).map { i in
                GameSession.Participant(name: "Player\(i)", status: .confirmed)
            }
        )
        
        measure {
            for _ in 0..<100 {
                _ = MessageEncoding.encode(session: session)
            }
        }
    }
    
    func testDecodingPerformance() {
        let session = GameSession(
            gameName: "Performance Test",
            startTime: Date(),
            hostName: "Host",
            participants: (0..<20).map { i in
                GameSession.Participant(name: "Player\(i)", status: .confirmed)
            }
        )
        let url = MessageEncoding.encode(session: session)!
        
        measure {
            for _ in 0..<100 {
                _ = MessageEncoding.decode(from: url)
            }
        }
    }
}

