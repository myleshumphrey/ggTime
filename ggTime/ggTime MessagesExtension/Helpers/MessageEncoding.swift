//
//  MessageEncoding.swift
//  GG Time
//
//  Handles encoding and decoding GameSession data to/from URL components
//  for iMessage transmission.
//

import Foundation

/// Utility for encoding/decoding GameSession objects to URL format for iMessage
enum MessageEncoding {
    
    // MARK: - Constants
    
    private static let scheme = "ggtime"
    private static let host = "session"
    
    // MARK: - Encoding
    
    /// Encodes a GameSession into a URL that can be attached to an MSMessage
    /// - Parameter session: The gaming session to encode
    /// - Returns: URL containing the encoded session data, or nil if encoding fails
    static func encode(session: GameSession) -> URL? {
        // Convert session to JSON
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        guard let jsonData = try? encoder.encode(session) else {
            print("❌ Failed to encode GameSession to JSON")
            return nil
        }
        
        // Convert JSON to base64 string for URL safety
        let base64String = jsonData.base64EncodedString()
        
        // Create URL components
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.queryItems = [
            URLQueryItem(name: "data", value: base64String)
        ]
        
        guard let url = components.url else {
            print("❌ Failed to create URL from components")
            return nil
        }
        
        print("✅ Encoded session: \(session.gameName) at \(session.formattedTime)")
        return url
    }
    
    // MARK: - Decoding
    
    /// Decodes a GameSession from a URL received in an MSMessage
    /// - Parameter url: The URL containing encoded session data
    /// - Returns: Decoded GameSession, or nil if decoding fails
    static func decode(from url: URL?) -> GameSession? {
        guard let url = url else {
            print("❌ No URL provided for decoding")
            return nil
        }
        
        // Validate URL scheme and host
        guard url.scheme == scheme, url.host == host else {
            print("❌ Invalid URL scheme or host: \(url)")
            return nil
        }
        
        // Extract query parameters
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems,
              let base64String = queryItems.first(where: { $0.name == "data" })?.value else {
            print("❌ Failed to extract data from URL query parameters")
            return nil
        }
        
        // Decode base64 string to data
        guard let jsonData = Data(base64Encoded: base64String) else {
            print("❌ Failed to decode base64 string")
            return nil
        }
        
        // Decode JSON to GameSession
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let session = try? decoder.decode(GameSession.self, from: jsonData) else {
            print("❌ Failed to decode JSON to GameSession")
            return nil
        }
        
        print("✅ Decoded session: \(session.gameName) at \(session.formattedTime)")
        return session
    }
    
    // MARK: - Validation
    
    /// Checks if a URL contains valid GG Time session data
    /// - Parameter url: The URL to validate
    /// - Returns: True if the URL can be decoded to a valid session
    static func isValidSessionURL(_ url: URL?) -> Bool {
        return decode(from: url) != nil
    }
    
    // MARK: - URL Info Extraction (for Quick Previews)
    
    /// Extracts basic session info without full decoding (useful for quick previews)
    /// - Parameter url: The URL to extract info from
    /// - Returns: Tuple of (gameName, startTime) or nil if extraction fails
    static func extractQuickInfo(from url: URL?) -> (gameName: String, startTime: Date)? {
        guard let session = decode(from: url) else { return nil }
        return (session.gameName, session.startTime)
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension MessageEncoding {
    /// Creates a sample URL for testing purposes
    static func createSampleURL() -> URL? {
        let sampleSession = GameSession(
            gameName: "Valorant",
            startTime: Date().addingTimeInterval(3600),
            hostName: "TestUser",
            participants: []
        )
        return encode(session: sampleSession)
    }
    
    /// Tests the encode/decode cycle
    static func testEncodeDecode() {
        print("🧪 Testing encode/decode cycle...")
        
        let originalSession = GameSession(
            gameName: "League of Legends",
            startTime: Date().addingTimeInterval(7200),
            hostName: "Alex",
            participants: [
                .init(name: "Sam", status: .confirmed),
                .init(name: "Jordan", status: .maybe)
            ]
        )
        
        guard let url = encode(session: originalSession) else {
            print("❌ Encoding failed")
            return
        }
        
        guard let decodedSession = decode(from: url) else {
            print("❌ Decoding failed")
            return
        }
        
        if originalSession == decodedSession {
            print("✅ Encode/decode test passed!")
        } else {
            print("❌ Decoded session doesn't match original")
        }
    }
}
#endif

