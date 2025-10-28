//
//  MessagesViewController.swift
//  GG Time Messages Extension
//
//  Main view controller that integrates with the Messages framework.
//  Handles creating, sending, and updating gaming session messages.
//

import UIKit
import Messages
import SwiftUI
import Contacts

class MessagesViewController: MSMessagesAppViewController {
    
    // MARK: - Properties
    
    /// Current game session being displayed/edited
    private var currentSession: GameSession?
    
    /// Contact store for retrieving contact names
    private let contactStore = CNContactStore()
    
    /// Cache for participant names to avoid repeated contact lookups
    private var nameCache: [UUID: String] = [:]
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("✅ GG Time extension loaded - v2.0 with 4-button layout")
    }
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
        
        // Check if we're viewing an existing session
        if let message = conversation.selectedMessage,
           let session = MessageEncoding.decode(from: message.url) {
            currentSession = session
            presentSessionBubble(session: session, conversation: conversation)
        } else {
            // Show create session view
            presentCreateSessionView()
        }
    }
    
    override func didResignActive(with conversation: MSConversation) {
        super.didResignActive(with: conversation)
    }
    
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        super.didReceive(message, conversation: conversation)
        
        // Decode the received session
        if let session = MessageEncoding.decode(from: message.url) {
            currentSession = session
            print("📨 Received session update: \(session.gameName)")
        }
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        super.didStartSending(message, conversation: conversation)
        print("📤 Started sending message")
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        super.didCancelSending(message, conversation: conversation)
        print("❌ Cancelled sending message")
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        super.willTransition(to: presentationStyle)
        
        guard let conversation = activeConversation else { return }
        
        // Update view based on presentation style
        switch presentationStyle {
        case .compact:
            // Show compact bubble view
            if let session = currentSession {
                presentSessionBubble(session: session, conversation: conversation)
            }
        case .expanded:
            // Show full create/edit view
            if let message = conversation.selectedMessage,
               let session = MessageEncoding.decode(from: message.url) {
                currentSession = session
                presentSessionBubble(session: session, conversation: conversation)
            } else {
                presentCreateSessionView()
            }
        case .transcript:
            break
        @unknown default:
            break
        }
    }
    
    // MARK: - View Presentation
    
    /// Presents the create session view (game + time picker)
    private func presentCreateSessionView() {
        print("🎮 Presenting create session view")
        
        let sessionView = SessionView(
            onShare: { [weak self] gameName, startTime in
                self?.createAndShareSession(gameName: gameName, startTime: startTime)
            },
            onCancel: { [weak self] in
                self?.requestDismiss()
            }
        )
        
        let hostingController = UIHostingController(rootView: sessionView)
        presentSwiftUIView(hostingController)
    }
    
    /// Presents the session bubble view (showing participants and join buttons)
    private func presentSessionBubble(session: GameSession, conversation: MSConversation) {
        print("💬 Presenting session bubble: \(session.gameName)")
        
        let currentUserName = getCurrentUserName(from: conversation)
        print("🔍 DEBUG: currentUserName = \(currentUserName)")
        print("🔍 DEBUG: participants = \(session.participants)")
        print("🔍 DEBUG: hasParticipant = \(session.hasParticipant(name: currentUserName))")
        
        let bubbleView = SessionBubbleView(
            session: session,
            currentUserName: currentUserName,
            isInteractive: true,
            onJoin: { [weak self] in
                self?.joinSession(status: .confirmed)
            },
            onMaybe: { [weak self] in
                self?.joinSession(status: .maybe)
            },
            onLeave: { [weak self] in
                self?.leaveSession()
            },
            onJoinDifferentTime: { [weak self] in
                self?.presentJoinTimePicker()
            },
            onCantJoin: { [weak self] in
                self?.joinSession(status: .cantJoin)
            }
        )
        
        let hostingController = UIHostingController(rootView: bubbleView)
        presentSwiftUIView(hostingController)
    }
    
    /// Presents the join time picker view
    private func presentJoinTimePicker() {
        print("⏰ Presenting join time picker")
        
        let timePickerView = JoinTimePickerView(
            onConfirm: { [weak self] joinTime in
                self?.joinSessionAtDifferentTime(joinTime: joinTime)
            },
            onCancel: { [weak self] in
                self?.requestDismiss()
            }
        )
        
        let hostingController = UIHostingController(rootView: timePickerView)
        presentSwiftUIView(hostingController)
    }
    
    /// Helper to present a SwiftUI view
    private func presentSwiftUIView(_ hostingController: UIHostingController<some View>) {
        // Remove existing child view controllers
        for child in children {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
        
        // Add new hosting controller
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }
    
    // MARK: - Session Actions
    
    /// Creates and shares a new gaming session
    private func createAndShareSession(gameName: String, startTime: Date) {
        guard let conversation = activeConversation else {
            print("❌ No active conversation")
            return
        }
        
        let hostName = getCurrentUserName(from: conversation)
        let session = GameSession(
            gameName: gameName,
            startTime: startTime,
            hostName: hostName
        )
        
        currentSession = session
        
        // Create and insert message
        let message = createMessage(for: session, in: conversation)
        conversation.insert(message) { [weak self] error in
            if let error = error {
                print("❌ Error inserting message: \(error.localizedDescription)")
            } else {
                print("✅ Session created and shared: \(gameName)")
                self?.requestDismiss()
            }
        }
    }
    
    /// Adds current user to the session
    private func joinSession(status: GameSession.ParticipantStatus) {
        guard let conversation = activeConversation,
              let session = currentSession else {
            print("❌ No active conversation or session")
            return
        }
        
        let userName = getCurrentUserName(from: conversation)
        let updatedSession = session.addingOrUpdatingParticipant(name: userName, status: status)
        currentSession = updatedSession
        
        // Update the message
        updateMessage(with: updatedSession, in: conversation)
        
        print("✅ \(userName) joined as \(status.rawValue)")
    }
    
    /// Removes current user from the session
    private func leaveSession() {
        guard let conversation = activeConversation,
              let session = currentSession else {
            print("❌ No active conversation or session")
            return
        }
        
        let userName = getCurrentUserName(from: conversation)
        let updatedSession = session.removingParticipant(name: userName)
        currentSession = updatedSession
        
        // Update the message
        updateMessage(with: updatedSession, in: conversation)
        
        print("✅ \(userName) left the session")
    }
    
    /// Adds current user to the session at a different time
    private func joinSessionAtDifferentTime(joinTime: Date) {
        guard let conversation = activeConversation,
              let session = currentSession else {
            print("❌ No active conversation or session")
            return
        }
        
        let userName = getCurrentUserName(from: conversation)
        let updatedSession = session.addingOrUpdatingParticipant(
            name: userName, 
            status: .differentTime, 
            joinTime: joinTime
        )
        currentSession = updatedSession
        
        // Update the message
        updateMessage(with: updatedSession, in: conversation)
        
        print("✅ \(userName) joined at different time: \(joinTime)")
    }
    
    // MARK: - Message Creation
    
    /// Creates an MSMessage for a gaming session
    private func createMessage(for session: GameSession, in conversation: MSConversation) -> MSMessage {
        let message = MSMessage(session: conversation.selectedMessage?.session ?? MSSession())
        
        // Encode session data in URL
        message.url = MessageEncoding.encode(session: session)
        
        // Create message layout
        let layout = MSMessageTemplateLayout()
        layout.image = createSessionImage(for: session)
        layout.caption = "\(session.formattedDate) at \(session.formattedTime)"
        layout.subcaption = "\(session.hostName) is dropping in at \(session.formattedTime)"
        layout.trailingCaption = participantsSummary(for: session)
        
        message.layout = layout
        message.summaryText = "\(session.hostName) wants to play \(session.gameName) at \(session.formattedTime)"
        
        return message
    }
    
    /// Updates an existing message with new session data
    private func updateMessage(with session: GameSession, in conversation: MSConversation) {
        guard let selectedMessage = conversation.selectedMessage else {
            print("❌ No message selected for update")
            return
        }
        
        // Create updated message with the same session
        let updatedMessage = MSMessage(session: selectedMessage.session ?? MSSession())
        updatedMessage.url = MessageEncoding.encode(session: session)
        
        // Update layout
        let layout = MSMessageTemplateLayout()
        layout.image = createSessionImage(for: session)
        layout.caption = "\(session.formattedDate) at \(session.formattedTime)"
        layout.subcaption = "\(session.hostName) is dropping in at \(session.formattedTime)"
        layout.trailingCaption = participantsSummary(for: session)
        
        updatedMessage.layout = layout
        updatedMessage.summaryText = participantUpdateSummary(for: session)
        
        // Insert updated message
        conversation.insert(updatedMessage) { error in
            if let error = error {
                print("❌ Error updating message: \(error.localizedDescription)")
            } else {
                print("✅ Message updated successfully")
            }
        }
        
        // Refresh the view
        presentSessionBubble(session: session, conversation: conversation)
    }
    
    // MARK: - Helper Methods
    
    /// Gets the current user's display name from the conversation
    private func getCurrentUserName(from conversation: MSConversation) -> String {
        let localParticipant = conversation.localParticipantIdentifier
        
        // Check cache first
        if let cachedName = nameCache[localParticipant] {
            return cachedName
        }
        
        // Try to get the contact name
        let displayName = getContactName(for: localParticipant) ?? generateFriendlyName(from: localParticipant)
        
        // Cache the result
        nameCache[localParticipant] = displayName
        
        return displayName
    }
    
    /// Attempts to retrieve contact name for a participant
    /// - Parameter identifier: The participant's UUID
    /// - Returns: Contact name if found and authorized, nil otherwise
    private func getContactName(for identifier: UUID) -> String? {
        // Check authorization status
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        
        guard authorizationStatus == .authorized else {
            // Don't request permission in iMessage extensions - it's not user-friendly
            return nil
        }
        
        // In a real app, you might map the UUID to a phone number or email
        // For now, we'll return nil as iMessage doesn't provide direct contact mapping
        // This is a placeholder for future enhancement
        return nil
    }
    
    /// Generates a friendly display name from UUID
    /// - Parameter identifier: The participant's UUID
    /// - Returns: A user-friendly name like "Player ABC123"
    private func generateFriendlyName(from identifier: UUID) -> String {
        let uuidString = identifier.uuidString
        
        // Take first 6 characters for a shorter, friendlier ID
        let shortID = String(uuidString.prefix(6))
        
        return "Player \(shortID)"
    }
    
    /// Creates a summary of participants for the message caption
    private func participantsSummary(for session: GameSession) -> String {
        let total = session.confirmedCount + session.maybeCount + session.differentTimeCount + session.cantJoinCount
        if total == 0 {
            return "No one joined yet"
        } else if session.confirmedCount > 0 {
            return "\(session.confirmedCount) confirmed"
        } else if session.differentTimeCount > 0 {
            return "\(session.differentTimeCount) different time"
        } else if session.maybeCount > 0 {
            return "\(session.maybeCount) maybe"
        } else if session.cantJoinCount > 0 {
            return "\(session.cantJoinCount) can't join"
        }
        return "No one joined yet"
    }
    
    /// Creates a summary for participant updates
    private func participantUpdateSummary(for session: GameSession) -> String {
        let total = session.confirmedCount + session.maybeCount + session.differentTimeCount + session.cantJoinCount
        if total == 0 {
            return "\(session.gameName) session at \(session.formattedTime)"
        }
        return "\(total) people interested in \(session.gameName)"
    }
    
    /// Creates an image for the message bubble
    private func createSessionImage(for session: GameSession) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 300, height: 200))
        
        let image = renderer.image { ctx in
            // Background gradient
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    UIColor.systemPurple.cgColor,
                    UIColor.systemPurple.withAlphaComponent(0.7).cgColor
                ] as CFArray,
                locations: [0, 1]
            )!
            
            ctx.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: 300, y: 200),
                options: []
            )
            
            // Game controller icon
            let iconSize: CGFloat = 60
            let iconRect = CGRect(
                x: (300 - iconSize) / 2,
                y: 50,
                width: iconSize,
                height: iconSize
            )
            
            if let icon = UIImage(systemName: "gamecontroller.fill")?
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: iconSize))
                .withTintColor(.white, renderingMode: .alwaysOriginal) {
                icon.draw(in: iconRect)
            }
            
            // Personalized message text with better spacing
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.lineSpacing = 4 // Add spacing between lines
            
            // Line 1: "Myles wants to play"
            let line1Attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 17, weight: .medium),
                .foregroundColor: UIColor.white
            ]
            let line1 = "\(session.hostName) wants to play"
            let line1Size = (line1 as NSString).size(withAttributes: line1Attributes)
            let line1Rect = CGRect(x: (300 - line1Size.width) / 2, y: 115, width: line1Size.width, height: line1Size.height)
            line1.draw(in: line1Rect, withAttributes: line1Attributes)
            
            // Line 2: Game name (larger, bold)
            let line2Attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 22),
                .foregroundColor: UIColor.white
            ]
            let line2 = session.gameName
            let line2Size = (line2 as NSString).size(withAttributes: line2Attributes)
            let line2Rect = CGRect(x: (300 - line2Size.width) / 2, y: 140, width: line2Size.width, height: line2Size.height)
            line2.draw(in: line2Rect, withAttributes: line2Attributes)
            
            // Line 3: Date and time
            let line3Attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 17, weight: .medium),
                .foregroundColor: UIColor.white
            ]
            let line3 = "\(session.formattedDate) at \(session.formattedTime)"
            let line3Size = (line3 as NSString).size(withAttributes: line3Attributes)
            let line3Rect = CGRect(x: (300 - line3Size.width) / 2, y: 170, width: line3Size.width, height: line3Size.height)
            line3.draw(in: line3Rect, withAttributes: line3Attributes)
        }
        
        return image
    }
    
    /// Dismisses the extension
    private func requestDismiss() {
        requestPresentationStyle(.compact)
    }
}

