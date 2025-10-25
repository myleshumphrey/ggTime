# 📁 GG Time - Project Structure Reference

Quick reference for understanding the codebase organization.

---

## Directory Tree

```
ggTime/
│
├── 📱 GGTime/                               # Main app container (required for extensions)
│   ├── Info.plist                           # Main app configuration
│   └── Assets.xcassets/                     # App icons and colors
│       ├── AppIcon.appiconset/              # Main app icon
│       └── AccentColor.colorset/            # App accent color
│
├── 💬 GGTimeMessagesExtension/              # iMessage Extension
│   │
│   ├── 🎮 MessagesViewController.swift      # CORE - Messages framework integration
│   │   └── Handles: Creating, sending, and updating messages
│   │
│   ├── 📦 Models/
│   │   └── GameSession.swift                # DATA MODEL - Session structure
│   │       └── Properties: id, gameName, startTime, hostName, participants
│   │       └── Methods: addingOrUpdatingParticipant(), removingParticipant()
│   │
│   ├── 🎨 Views/
│   │   ├── SessionView.swift                # CREATE VIEW - Game & time picker
│   │   │   └── Features: Game selection, time picker, share button
│   │   │
│   │   └── SessionBubbleView.swift          # DISPLAY VIEW - Session card
│   │       └── Features: Participant list, Join/Maybe buttons, live updates
│   │
│   ├── 🔧 Helpers/
│   │   └── MessageEncoding.swift            # URL encoding/decoding
│   │       └── Functions: encode(session:), decode(from:)
│   │       └── Format: ggtime://session?data=<base64-json>
│   │
│   ├── 📐 Base.lproj/
│   │   └── MainInterface.storyboard         # Extension UI container
│   │
│   ├── 🎨 Assets.xcassets/                  # Extension icons
│   │   └── iMessage App Icon.stickersiconset/
│   │
│   └── Info.plist                           # Extension configuration
│       └── Key: NSExtensionPrincipalClass = MessagesViewController
│
├── 📝 README.md                             # Main documentation
├── 🛠️ SETUP_GUIDE.md                        # Xcode setup instructions
├── 📁 PROJECT_STRUCTURE.md                  # This file
└── 🚫 .gitignore                            # Git ignore rules

```

---

## Key Files Explained

### 🎮 MessagesViewController.swift
**Purpose**: Main coordinator between iMessage and our app

**Key Methods**:
- `willBecomeActive(with:)` - Called when extension opens
- `createAndShareSession()` - Creates new gaming session
- `joinSession()` / `leaveSession()` - Handles participation
- `createMessage(for:)` - Builds MSMessage with layout
- `updateMessage(with:)` - Updates existing message

**Flow**:
```
User taps extension → willBecomeActive → Show SessionView
User shares → createAndShareSession → Insert MSMessage
Friend taps Join → joinSession → Update MSMessage
```

---

### 📦 GameSession.swift
**Purpose**: Core data model representing a gaming session

**Structure**:
```swift
GameSession
├── id: UUID
├── gameName: String
├── startTime: Date
├── hostName: String
├── participants: [Participant]
│   ├── id: UUID
│   ├── name: String
│   ├── status: ParticipantStatus (.confirmed | .maybe)
│   └── joinedAt: Date
└── createdAt: Date
```

**Key Features**:
- Codable (can be encoded to JSON)
- Immutable with functional updates
- Computed properties for formatting

---

### 🎨 SessionView.swift
**Purpose**: SwiftUI view for creating a new session

**Components**:
- TextField for custom game name
- Grid of popular game buttons
- DatePicker for start time
- Share and Cancel buttons

**User Flow**:
1. User enters/selects game
2. User picks time
3. User taps Share
4. Callback to MessagesViewController
5. Message is created and sent

---

### 💬 SessionBubbleView.swift
**Purpose**: SwiftUI view displaying the session card

**Components**:
- Header (game name, time, host)
- Participant lists (confirmed & maybe)
- Action buttons (Join/Maybe or Leave)

**State Management**:
- Shows different buttons based on user's participation
- Highlights current user in participant list
- Updates dynamically as people join

---

### 🔧 MessageEncoding.swift
**Purpose**: Converts GameSession ↔ URL for iMessage

**Encoding Process**:
```
GameSession
  → JSON (Codable)
  → Base64 string
  → URL: ggtime://session?data=<base64>
```

**Decoding Process**:
```
URL: ggtime://session?data=<base64>
  → Base64 string
  → JSON
  → GameSession
```

**Why URLs?**
- iMessage messages are lightweight
- URL is the standard way to pass data in MSMessage
- Allows deep linking and message updates

---

## Data Flow Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    iMessage Conversation                 │
└───────────────────────┬─────────────────────────────────┘
                        │
                        │ User taps GG Time icon
                        ↓
┌─────────────────────────────────────────────────────────┐
│              MessagesViewController                      │
│  ┌───────────────────────────────────────────────────┐  │
│  │  Checks: New session or existing message?         │  │
│  └───────────┬───────────────────────┬────────────────┘  │
│              ↓                       ↓                    │
│      ┌──────────────┐        ┌─────────────────┐        │
│      │ SessionView  │        │ SessionBubbleView│        │
│      │ (Create)     │        │ (Display)        │        │
│      └──────┬───────┘        └────────┬─────────┘        │
│             │                         │                   │
│             │ onShare                 │ onJoin/onMaybe    │
│             ↓                         ↓                   │
│  ┌──────────────────────────────────────────────────┐   │
│  │        Create/Update GameSession                  │   │
│  └───────────────────┬───────────────────────────────┘   │
└──────────────────────┼───────────────────────────────────┘
                       │
                       ↓
              ┌─────────────────┐
              │ MessageEncoding │
              │  encode(session)│
              └────────┬─────────┘
                       │
                       ↓ URL with session data
              ┌─────────────────┐
              │   MSMessage     │
              │  + Layout       │
              └────────┬─────────┘
                       │
                       ↓ Insert/Update
┌─────────────────────────────────────────────────────────┐
│              iMessage Conversation                       │
│         [Session Card Appears/Updates]                   │
└─────────────────────────────────────────────────────────┘
```

---

## Message Update Flow

**Key Concept**: Using `MSSession` to update the same message instead of creating new ones

```
1. User A creates session
   └─> MSMessage(session: newSession)
       └─> Inserted into conversation

2. User B taps "Join"
   └─> Decode session from message.url
   └─> Add User B to participants
   └─> MSMessage(session: sameSession)  ← SAME session!
       └─> Inserted (replaces previous)

3. User C sees updated card
   └─> No new message bubble
   └─> Just one card with updated participants
```

---

## State Management

### Session State
- Stored in message URL (encoded)
- No local persistence needed
- Each message update carries full state

### User State
- Current user identified by `conversation.localParticipantIdentifier`
- Participation tracked in session.participants array

### UI State
- SwiftUI @State variables manage local UI
- Callbacks propagate changes to MessagesViewController
- ViewController updates message, which updates UI

---

## Extension Lifecycle

```
Extension Launch
  ↓
viewDidLoad()
  ↓
willBecomeActive(with: conversation)
  ├─> Check conversation.selectedMessage
  ├─> Decode existing session if present
  └─> Present appropriate view
  ↓
[User Interaction]
  ↓
didReceive(_ message:)  ← Message updates
  ↓
willTransition(to: .compact/.expanded)  ← Size changes
  ↓
didResignActive(with:)
  ↓
Extension Closes
```

---

## Testing Checklist

### Unit Testing
- ✅ GameSession model logic
- ✅ MessageEncoding encode/decode
- ✅ Participant management

### UI Testing
- ✅ SessionView displays correctly
- ✅ SessionBubbleView renders properly
- ✅ Popular game selection
- ✅ Time picker functionality

### Integration Testing
- ✅ Message creation
- ✅ Message updates (not duplicates)
- ✅ Multiple users joining
- ✅ Leave functionality

### Device Testing
- ✅ Real iMessage conversation
- ✅ Multiple devices
- ✅ Different iOS versions

---

## Performance Considerations

### Message Size
- Keep session data lightweight
- Base64 encoding adds ~33% size overhead
- JSON is text-based and efficient

### Update Frequency
- Updates only happen on user action
- No polling or background updates
- Efficient for battery and network

### Memory
- SwiftUI views are lightweight
- No heavy image processing
- Session objects are small

---

## Security Considerations

### Data Privacy
- All data stays in iMessage
- No external server communication
- Participant names visible to all in conversation

### URL Validation
- Always validate scheme and host
- Handle decode failures gracefully
- Don't trust external URLs

---

## Expansion Ideas

### Easy Additions
- More popular games
- Custom color themes
- Different time formats

### Medium Complexity
- Local notifications
- Calendar integration
- Game icons/images
- Recent games list

### Advanced Features
- CloudKit sync (cross-device)
- Game stats tracking
- Voice channel integration
- Rich push notifications

---

## Code Style Guidelines

### Swift
- Use clear, descriptive names
- Prefer immutability (let over var)
- Functional updates for models
- Comprehensive comments for complex logic

### SwiftUI
- Separate views into components
- Use @State for local state only
- Callbacks for parent communication
- Preview providers for all views

### Organization
- Models: Pure data structures
- Views: SwiftUI components
- Helpers: Utilities and extensions
- ViewController: Messages integration

---

## Dependencies

### Frameworks Used
- **Messages**: Core iMessage integration
- **SwiftUI**: Modern UI framework
- **Foundation**: Standard Swift libraries

### No Third-Party Dependencies
- Keeps extension lightweight
- Easier App Store approval
- No external security concerns

---

## Build Configuration

### Deployment Target
- iOS 15.0+ (supports most devices from 2017 onwards)
- iPhone and iPad supported

### Capabilities
- No special capabilities required
- No background modes needed
- Standard iMessage extension entitlements

---

**Quick Tips**:
- 🔍 Search "TODO" in code for expansion points
- 📝 All major functions are documented
- 🐛 Use print() logs for debugging
- 🧪 Test on real device for best results

---

*Last updated: 2025-10-24*

