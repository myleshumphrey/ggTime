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

class MessagesViewController: MSMessagesAppViewController {
    
    // MARK: - Properties
    
    /// Current active conversation
    private var activeConversation: MSConversation?
    
    /// Current game session being displayed/edited
    private var currentSession: GameSession?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("✅ GG Time extension loaded")
    }
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
        activeConversation = conversation
        
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
        activeConversation = nil
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
                self?.dismiss()
            }
        )
        
        let hostingController = UIHostingController(rootView: sessionView)
        presentSwiftUIView(hostingController)
    }
    
    /// Presents the session bubble view (showing participants and join buttons)
    private func presentSessionBubble(session: GameSession, conversation: MSConversation) {
        print("💬 Presenting session bubble: \(session.gameName)")
        
        let currentUserName = getCurrentUserName(from: conversation)
        
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
            }
        )
        
        let hostingController = UIHostingController(rootView: bubbleView)
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
                self?.dismiss()
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
    
    // MARK: - Message Creation
    
    /// Creates an MSMessage for a gaming session
    private func createMessage(for session: GameSession, in conversation: MSConversation) -> MSMessage {
        let message = MSMessage(session: conversation.selectedMessage?.session ?? MSSession())
        
        // Encode session data in URL
        message.url = MessageEncoding.encode(session: session)
        
        // Create message layout
        let layout = MSMessageTemplateLayout()
        layout.image = createSessionImage(for: session)
        layout.imageTitle = session.gameName
        layout.caption = "\(session.formattedDate) at \(session.formattedTime)"
        layout.subcaption = "Hosted by \(session.hostName)"
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
        let updatedMessage = MSMessage(session: selectedMessage.session)
        updatedMessage.url = MessageEncoding.encode(session: session)
        
        // Update layout
        let layout = MSMessageTemplateLayout()
        layout.image = createSessionImage(for: session)
        layout.imageTitle = session.gameName
        layout.caption = "\(session.formattedDate) at \(session.formattedTime)"
        layout.subcaption = "Hosted by \(session.hostName)"
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
        // Try to get local participant name
        if let localParticipant = conversation.localParticipantIdentifier {
            // Use a shortened version of the UUID as fallback
            let shortID = String(localParticipant.uuidString.prefix(8))
            return "User-\(shortID)"
        }
        return "Guest"
    }
    
    /// Creates a summary of participants for the message caption
    private func participantsSummary(for session: GameSession) -> String {
        let total = session.confirmedCount + session.maybeCount
        if total == 0 {
            return "No one joined yet"
        } else if session.confirmedCount > 0 {
            return "\(session.confirmedCount) confirmed"
        } else {
            return "\(session.maybeCount) maybe"
        }
    }
    
    /// Creates a summary for participant updates
    private func participantUpdateSummary(for session: GameSession) -> String {
        let total = session.confirmedCount + session.maybeCount
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
            
            // Game name
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]
            
            let textRect = CGRect(x: 20, y: 130, width: 260, height: 50)
            session.gameName.draw(in: textRect, withAttributes: attributes)
        }
        
        return image
    }
    
    /// Dismisses the extension
    private func dismiss() {
        requestPresentationStyle(.compact)
    }
}

