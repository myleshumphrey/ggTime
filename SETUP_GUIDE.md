# 🛠️ GG Time - Xcode Project Setup Guide

This guide will walk you through setting up the GG Time iMessage extension in Xcode from the existing code structure.

---

## Step 1: Create the Main App Target

1. **Open Xcode**
2. **File → New → Project**
3. Choose **iOS → App**
4. Configure:
   - **Product Name**: `GGTime`
   - **Team**: Select your development team
   - **Organization Identifier**: `com.yourname` (or your preferred identifier)
   - **Bundle Identifier**: `com.yourname.GGTime`
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Storage**: None (or your preference)
   - **Include Tests**: ✅ (optional)

5. **Save Location**: Navigate to `/Users/myleshumphrey/repos/ggTime` and save

---

## Step 2: Add iMessage Extension Target

1. In Xcode, select the **GGTime project** in the Project Navigator
2. At the bottom of the target list, click the **+** button
3. Choose **iOS → Application Extension → iMessage Extension**
4. Configure:
   - **Product Name**: `GGTimeMessagesExtension`
   - **Team**: Same as main app
   - **Organization Identifier**: Should auto-populate
   - **Bundle Identifier**: `com.yourname.GGTime.MessagesExtension`
   - **Starting Point**: Messages Extension
   - **Include Stickers**: ❌ (unchecked)

5. Click **Finish**
6. When prompted "Activate 'GGTimeMessagesExtension' scheme?", click **Activate**

---

## Step 3: Configure File Structure

### 3.1: Replace Generated Files

The Xcode wizard creates some default files. Replace/update them with our custom files:

1. **Delete** the auto-generated files in `GGTimeMessagesExtension`:
   - `MessagesViewController.swift` (we have a better one)
   - Any other generated Swift files

2. **Keep** the following generated files:
   - `Info.plist` (but replace contents with ours)
   - `MainInterface.storyboard` (replace contents with ours)
   - `Assets.xcassets` folder (merge with ours)

### 3.2: Add Source Files to Extension Target

Drag the following folders/files into the **GGTimeMessagesExtension** group in Xcode:

**From `GGTimeMessagesExtension/Models/`:**
- `GameSession.swift`

**From `GGTimeMessagesExtension/Views/`:**
- `SessionView.swift`
- `SessionBubbleView.swift`

**From `GGTimeMessagesExtension/Helpers/`:**
- `MessageEncoding.swift`

**From `GGTimeMessagesExtension/`:**
- `MessagesViewController.swift`

When dragging, ensure:
- ✅ **Copy items if needed** is checked
- ✅ **GGTimeMessagesExtension** target is selected
- ❌ **GGTime** target should NOT be selected (for extension files)

---

## Step 4: Configure Info.plist Files

### 4.1: Main App Info.plist

Replace `/Users/myleshumphrey/repos/ggTime/GGTime/Info.plist` contents with the provided one, or ensure it contains:

```xml
<key>CFBundleDisplayName</key>
<string>GG Time</string>
```

### 4.2: Extension Info.plist

Replace `/Users/myleshumphrey/repos/ggTime/GGTimeMessagesExtension/Info.plist` with the provided one, ensuring:

```xml
<key>NSExtension</key>
<dict>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.messages-extension</string>
    <key>NSExtensionPrincipalClass</key>
    <string>$(PRODUCT_MODULE_NAME).MessagesViewController</string>
</dict>
```

---

## Step 5: Configure Build Settings

### 5.1: Main App Target (GGTime)

1. Select **GGTime** target
2. Go to **Build Settings**
3. Set:
   - **iOS Deployment Target**: `15.0` or higher
   - **Swift Language Version**: `Swift 5`

### 5.2: Extension Target (GGTimeMessagesExtension)

1. Select **GGTimeMessagesExtension** target
2. Go to **Build Settings**
3. Set:
   - **iOS Deployment Target**: `15.0` or higher
   - **Swift Language Version**: `Swift 5`
   - **Supports Mac Designed for iPad**: `No`

---

## Step 6: Configure Signing & Capabilities

### 6.1: Main App (GGTime)

1. Select **GGTime** target
2. Go to **Signing & Capabilities** tab
3. Configure:
   - **Team**: Select your development team
   - **Bundle Identifier**: Verify it matches `com.yourname.GGTime`
   - **Signing Certificate**: Automatically manage signing (✅)

### 6.2: Extension (GGTimeMessagesExtension)

1. Select **GGTimeMessagesExtension** target
2. Go to **Signing & Capabilities** tab
3. Configure:
   - **Team**: Same as main app
   - **Bundle Identifier**: Verify it matches `com.yourname.GGTime.MessagesExtension`
   - **Signing Certificate**: Automatically manage signing (✅)

---

## Step 7: Verify File Target Membership

For each Swift file, verify it's assigned to the correct target:

1. Select a file in Project Navigator
2. Open **File Inspector** (right panel)
3. Check **Target Membership**:

**Files should belong to GGTimeMessagesExtension ONLY:**
- ✅ `MessagesViewController.swift`
- ✅ `GameSession.swift`
- ✅ `SessionView.swift`
- ✅ `SessionBubbleView.swift`
- ✅ `MessageEncoding.swift`

**Files should belong to GGTime ONLY:**
- (Any main app files you add later)

---

## Step 8: Build the Project

1. Select the **GGTime** scheme (or **GGTimeMessagesExtension**)
2. Choose your iPhone as the destination (not Simulator for full testing)
3. Press **⌘B** to build
4. Fix any compilation errors if they appear

### Common Build Issues:

**Issue**: "Cannot find type 'GameSession' in scope"
- **Fix**: Make sure `GameSession.swift` is added to the GGTimeMessagesExtension target

**Issue**: "Use of undeclared type 'MSMessage'"
- **Fix**: Add `import Messages` at the top of the file

**Issue**: SwiftUI compilation errors
- **Fix**: Ensure deployment target is iOS 15.0+

---

## Step 9: Run on Device

1. **Connect your iPhone** via USB or WiFi
2. **Trust the device** if prompted
3. Select your iPhone from the device menu
4. Press **⌘R** to build and run
5. The GG Time app will install (it's a container app, mostly empty)
6. **Open the Messages app** on your device

---

## Step 10: Enable Extension in Messages

1. Open **Messages** app on your iPhone
2. Open any conversation (or create a new one)
3. Tap the **App Store icon** (⊕ button) next to the message field
4. Swipe left through the app drawer to find **GG Time**
5. If you don't see it:
   - Tap the **···** (More) button
   - Find **GG Time** and toggle it ON
   - Tap **Done**

---

## Step 11: Test the Extension

1. **Tap the GG Time icon** in Messages
2. You should see the game/time picker interface
3. **Select or type a game name**
4. **Choose a time**
5. **Tap "Share Session"**
6. A session card should appear in the conversation
7. **Tap "Join" or "Maybe"** to test interactions
8. The card should update without creating a new message

---

## Troubleshooting

### Extension doesn't appear in Messages
- Make sure you're testing on a **real device** (not Simulator)
- Verify the extension target builds successfully
- Check that Info.plist has the correct NSExtension configuration
- Try restarting the Messages app

### Build errors
- Clean build folder: **Product → Clean Build Folder** (⇧⌘K)
- Delete derived data: **File → Project Settings → Derived Data → Delete**
- Verify all files have correct target membership

### Extension crashes on launch
- Check Xcode console for error messages
- Verify MessagesViewController is set as NSExtensionPrincipalClass
- Ensure all SwiftUI views compile without errors

### Can't interact with session cards
- Verify MessageEncoding properly encodes/decodes sessions
- Check that callbacks (onJoin, onMaybe, onLeave) are properly connected
- Look for console logs showing session updates

---

## Debugging Tips

### View Console Logs
1. With the app running, open **Xcode**
2. Open **Console** (⌘⇧C)
3. Filter for your app/extension name
4. Look for logs like:
   - ✅ Session created and shared
   - 📨 Received session update
   - ✅ Encoded/Decoded session

### Use Print Debugging
Add strategic `print()` statements:
- In `MessagesViewController.willBecomeActive(with:)` to see when extension loads
- In `createAndShareSession()` to confirm session creation
- In `MessageEncoding.encode/decode` to verify data transformation

### Test Encoding/Decoding
In `MessagesViewController.viewDidLoad()`, add:
```swift
#if DEBUG
MessageEncoding.testEncodeDecode()
#endif
```

---

## Next Steps

Once everything is working:

1. ✅ **Customize the UI** - Change colors, fonts, layouts
2. ✅ **Add more games** to the popular games list
3. ✅ **Design app icons** (required for TestFlight/App Store)
4. ✅ **Test with friends** on real devices
5. ✅ **Implement notifications** (bonus feature)
6. ✅ **Prepare for TestFlight** distribution

---

## File Checklist

Ensure these files exist and are in the correct locations:

```
ggTime/
├── GGTime/
│   ├── Info.plist ✅
│   └── Assets.xcassets/ ✅
│       ├── AppIcon.appiconset/
│       └── AccentColor.colorset/
│
├── GGTimeMessagesExtension/
│   ├── MessagesViewController.swift ✅
│   ├── Models/
│   │   └── GameSession.swift ✅
│   ├── Views/
│   │   ├── SessionView.swift ✅
│   │   └── SessionBubbleView.swift ✅
│   ├── Helpers/
│   │   └── MessageEncoding.swift ✅
│   ├── Base.lproj/
│   │   └── MainInterface.storyboard ✅
│   ├── Assets.xcassets/ ✅
│   │   └── iMessage App Icon.stickersiconset/
│   └── Info.plist ✅
│
├── .gitignore ✅
├── README.md ✅
└── SETUP_GUIDE.md ✅ (this file)
```

---

## Success Criteria

You'll know the setup is complete when:

- ✅ Project builds without errors
- ✅ Extension appears in Messages app
- ✅ Can create a gaming session
- ✅ Session card displays correctly
- ✅ Join/Maybe buttons work
- ✅ Session updates without creating duplicate messages
- ✅ Console shows proper logs

---

## Questions?

Refer to:
- `README.md` for overall project documentation
- Apple's [Messages Framework Documentation](https://developer.apple.com/documentation/messages)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)

---

**Happy coding! 🎮**

