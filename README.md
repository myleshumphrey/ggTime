# 🎮 GG Time

**Make gaming sessions with friends effortless.**

GG Time is an iMessage extension that helps you coordinate gaming sessions without endless back-and-forth messaging. Share what you're playing, when you're playing, and who's joining—all in a single, interactive message card.

---

## ✨ Features

- **Quick Session Creation**: Pick a game and time in seconds
- **Interactive Message Cards**: Friends can join or mark "maybe" right from the message
- **Live Updates**: Session cards update automatically without cluttering your chat
- **Popular Games**: Quick-select from popular games or enter custom titles
- **Smart Time Display**: Shows "Today," "Tomorrow," or specific dates
- **No Backend Required**: Fully local—works without servers or accounts

---

## 📱 Screenshots

*(Add screenshots here when testing in Xcode)*

---

## 🏗️ Project Structure

```
ggTime/
├── GGTime/                          # Main app container (required for iMessage extensions)
│   ├── Info.plist
│   └── Assets.xcassets/
│
└── GGTimeMessagesExtension/         # iMessage Extension
    ├── MessagesViewController.swift # Main Messages integration
    │
    ├── Models/
    │   └── GameSession.swift        # Core data model
    │
    ├── Views/
    │   ├── SessionView.swift        # Create session UI (game + time picker)
    │   └── SessionBubbleView.swift  # Session card display (with Join/Maybe buttons)
    │
    ├── Helpers/
    │   └── MessageEncoding.swift    # URL encoding/decoding for session data
    │
    ├── Base.lproj/
    │   └── MainInterface.storyboard
    │
    ├── Assets.xcassets/
    └── Info.plist
```

---

## 🚀 Getting Started

### Prerequisites

- **Xcode 14.0+**
- **iOS 15.0+** deployment target (supports most devices from 2017+)
- **iPhone or iPad** with iMessage (iMessage extensions don't work in Simulator for full testing)

### Setup Instructions

1. **Clone the Repository**
   ```bash
   cd /Users/myleshumphrey/repos/ggTime
   ```

2. **Create Xcode Project**
   
   Since this is a code-first structure, you'll need to create the Xcode project:
   
   - Open Xcode
   - Select **File → New → Project**
   - Choose **iOS → App**
   - Set:
     - Product Name: `GGTime`
     - Bundle Identifier: `com.yourname.GGTime`
     - Interface: SwiftUI
     - Language: Swift
   - Save to `/Users/myleshumphrey/repos/ggTime`
   
3. **Add iMessage Extension Target**
   
   - Select the project in Xcode
   - Click **+** to add a new target
   - Choose **iMessage Extension**
   - Set:
     - Product Name: `GGTimeMessagesExtension`
     - Bundle Identifier: `com.yourname.GGTime.MessagesExtension`
   
4. **Add Existing Files to Targets**
   
   - Add the Swift files to their respective targets:
     - `MessagesViewController.swift` → GGTimeMessagesExtension
     - `GameSession.swift` → GGTimeMessagesExtension
     - `MessageEncoding.swift` → GGTimeMessagesExtension
     - `SessionView.swift` → GGTimeMessagesExtension
     - `SessionBubbleView.swift` → GGTimeMessagesExtension
   
5. **Configure Info.plist Files**
   
   Make sure the Info.plist files match those provided in the project structure.

6. **Build and Run**
   
   - Select the **GGTime** scheme
   - Choose your iPhone as the destination
   - Build and run (⌘R)

---

## 🧪 Testing

### Testing in iMessage

1. **Deploy to Device**
   - iMessage extensions require a real device (Simulator has limitations)
   - Build and run on your iPhone

2. **Enable the Extension**
   - Open the Messages app
   - Start any conversation
   - Tap the App Store icon (⊕)
   - Swipe to find **GG Time**
   - If not visible, tap **···** and enable it

3. **Create a Session**
   - Tap the GG Time icon
   - Enter a game name or select from popular games
   - Choose a time
   - Tap **Share Session**

4. **Test Interactions**
   - The session card should appear in the conversation
   - Tap **Join** or **Maybe** to participate
   - The card updates without creating new messages

### Testing with Multiple Users

- Send the session to a friend or use multiple devices
- Each person can tap Join/Maybe independently
- The session card shows all participants in real-time

### Debugging Tips

- Use `print()` statements in `MessagesViewController.swift` for debugging
- Check the Xcode console for logs like:
  - ✅ Session created and shared
  - 📨 Received session update
  - ✅ Encoded/Decoded session

---

## 🎨 Customization

### Adding More Games

Edit `SessionView.swift` and add to the `popularGames` array:

```swift
private let popularGames = [
    "🎮 Your Game Here",
    // ... other games
]
```

### Changing Colors

The app uses `.purple` as the primary color. To change it globally:

1. Open `Assets.xcassets/AccentColor.colorset`
2. Set your preferred accent color
3. Update color references in SwiftUI views

### Customizing the Message Bubble

Edit `createSessionImage(for:)` in `MessagesViewController.swift` to customize the image shown in iMessage:

```swift
private func createSessionImage(for session: GameSession) -> UIImage {
    // Customize gradient, icons, fonts, etc.
}
```

---

## 🧩 Technical Details

### How It Works

1. **Session Creation**
   - User fills out game name and time in `SessionView`
   - Creates a `GameSession` object
   - Encodes it to a URL using `MessageEncoding`

2. **Message Sending**
   - `MessagesViewController` creates an `MSMessage` with the encoded URL
   - Uses `MSMessageTemplateLayout` for visual presentation
   - Inserts message into the conversation

3. **Participant Updates**
   - When someone taps Join/Maybe, the session is decoded from the message URL
   - Participant is added to the session
   - Updated session is re-encoded and sent as an update to the **same message session**
   - This prevents creating duplicate messages

4. **Data Encoding**
   - Session data is JSON-encoded, then Base64-encoded into the URL
   - `MessageEncoding.swift` handles all encoding/decoding
   - URL format: `ggtime://session?data=<base64-json>`

### Key Technologies

- **Messages Framework**: `MSMessage`, `MSConversation`, `MSMessageTemplateLayout`
- **SwiftUI**: Modern UI for views
- **Codable**: JSON encoding/decoding
- **URLComponents**: URL parameter handling

---

## 📋 Features Roadmap

### MVP (Current) ✅
- [x] Create gaming sessions
- [x] Share to iMessage
- [x] Join/Maybe participation
- [x] Live session updates
- [x] Popular game presets

### Future Enhancements
- [ ] Local notifications (15 min before session)
- [ ] Calendar integration
- [ ] Game icons/images
- [ ] Recent games list
- [ ] Edit session details
- [ ] Session history
- [ ] Time zone support for friends in different locations
- [ ] Group chat optimization (showing who hasn't responded)
- [ ] Rich activity tracking (iOS 16.1+ Live Activities)

---

## 🐛 Known Issues

1. **User Names**: Currently uses a UUID-based identifier for user names. In production, you'd integrate with Contacts or let users set nicknames.

2. **Simulator Limitations**: Full iMessage interaction testing requires a real device.

3. **Session Persistence**: Sessions are not saved locally. Once the message is deleted, the session is gone (this is by design for MVP).

---

## 🤝 Contributing

This is a personal project, but suggestions and improvements are welcome!

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is available for personal and educational use. Feel free to use it as a reference for building your own iMessage extensions!

---

## 🙏 Acknowledgments

- Apple's Messages Framework Documentation
- SwiftUI Community
- The gaming community that inspired this project

---

## 📞 Support

If you encounter issues:

1. Check that you're testing on a real device
2. Verify the extension is enabled in Messages
3. Review Xcode console logs for error messages
4. Ensure deployment target matches your device iOS version

---

## 🎮 Let's Game!

Built with ❤️ for gamers who are tired of "What time?" "What game?" "Who's playing?" messages.

**GG Time—because planning should be as fun as playing.**

---

### Quick Start Checklist

- [ ] Created Xcode project with App + iMessage Extension targets
- [ ] Added all Swift files to appropriate targets
- [ ] Configured Info.plist files
- [ ] Built and deployed to iPhone
- [ ] Enabled extension in Messages
- [ ] Created first gaming session
- [ ] Tested Join/Maybe functionality
- [ ] Shared with friends!

---

*Note: This project is an MVP (Minimum Viable Product) and serves as a foundation for a full-featured gaming coordination app. The focus is on core functionality and clean architecture.*
