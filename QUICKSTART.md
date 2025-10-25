# ⚡ GG Time - Quick Start

Get up and running in 5 minutes!

---

## 🚀 Fast Track Setup

### 1️⃣ Create Xcode Project (2 min)
```
1. Open Xcode
2. File → New → Project
3. iOS → App
4. Product Name: "GGTime"
5. Interface: SwiftUI, Language: Swift
6. Save to: /Users/myleshumphrey/repos/ggTime
```

### 2️⃣ Add iMessage Extension (1 min)
```
1. Click + in targets list
2. iOS → iMessage Extension
3. Product Name: "GGTimeMessagesExtension"
4. Finish → Activate
```

### 3️⃣ Add Files to Targets (2 min)
Drag these folders into **GGTimeMessagesExtension** group in Xcode:
- ✅ `Models/` folder (contains GameSession.swift)
- ✅ `Views/` folder (contains SessionView.swift, SessionBubbleView.swift)
- ✅ `Helpers/` folder (contains MessageEncoding.swift)
- ✅ `MessagesViewController.swift` (replace the generated one)

**Important**: When dragging, ensure only **GGTimeMessagesExtension** target is checked!

### 4️⃣ Configure Deployment Target (Important!)
```
1. Select GGTime target → General tab
2. Set "iOS" under Minimum Deployments to: 15.0
3. Select GGTimeMessagesExtension target → General tab
4. Set "iOS" under Minimum Deployments to: 15.0
5. Clean build (⇧⌘K)
```

**⚠️ If you get a deployment target error, see `FIX_DEPLOYMENT_TARGET.md`**

### 5️⃣ Build & Run
```
1. Connect your iPhone
2. Select GGTime scheme
3. Press ⌘R
4. Wait for installation
```

### 6️⃣ Test in Messages
```
1. Open Messages app on iPhone
2. Open any conversation
3. Tap ⊕ (App Store icon)
4. Find GG Time icon
5. Tap it → Create a session!
```

---

## ✅ Verification Checklist

After setup, verify:
- [ ] Project builds without errors
- [ ] Extension appears in Messages app
- [ ] Can create a gaming session
- [ ] Session card displays with game name and time
- [ ] Join button works and adds your name
- [ ] Card updates without creating duplicate messages

---

## 🐛 Quick Troubleshooting

**Problem**: "iOS doesn't match deployment target" error
- **Fix**: See `FIX_DEPLOYMENT_TARGET.md` - Set both targets to iOS 15.0

**Problem**: Extension doesn't appear in Messages
- **Fix**: Make sure you're on a real device (not Simulator)

**Problem**: Build errors about GameSession not found
- **Fix**: Verify files are added to GGTimeMessagesExtension target (check File Inspector)

**Problem**: App crashes when opening extension
- **Fix**: Check Xcode console for errors, verify Info.plist configuration

**Problem**: Can't tap Join/Maybe buttons
- **Fix**: Make sure MessagesViewController callbacks are properly connected

---

## 📚 Next Steps

Once it works:
1. ✅ Read **README.md** for full feature documentation
2. ✅ Check **PROJECT_STRUCTURE.md** to understand the code
3. ✅ Review **SETUP_GUIDE.md** for detailed configuration
4. ✅ Customize popular games in `SessionView.swift`
5. ✅ Design app icons for distribution

---

## 🎮 Usage Example

**Creating a session:**
```
1. Tap GG Time in Messages
2. Select "Valorant" or type custom game
3. Choose time (e.g., 7:30 PM)
4. Tap "Share Session"
```

**Joining a session:**
```
1. Friend receives session card
2. Tap "Join" (confirmed) or "Maybe" (interested)
3. Card updates to show your name
```

**Leaving a session:**
```
1. Tap the session card again
2. Tap "Leave Session"
3. Your name is removed
```

---

## 💡 Pro Tips

- **Popular Games**: Customize the preset list in `SessionView.swift` line 29
- **Color Theme**: Change `.purple` to any color throughout the app
- **Testing**: Use two devices or send to a friend for full testing
- **Debugging**: Check Xcode console for helpful emoji logs (✅ ❌ 📨)

---

## 📞 Need Help?

1. **Setup Issues**: See `SETUP_GUIDE.md`
2. **Code Questions**: See `PROJECT_STRUCTURE.md`
3. **Features**: See `README.md`

---

## 🎯 What You Built

✅ **Full iMessage extension** with SwiftUI
✅ **Interactive message cards** that update live
✅ **Game session coordination** with participants
✅ **No backend required** - fully local
✅ **Clean architecture** - easy to extend

---

**Total Setup Time**: ~5 minutes
**Total Code**: ~1,200 lines of clean, documented Swift
**Result**: A fully functional gaming coordination app!

---

🎮 **Now go coordinate some epic gaming sessions!** 🎮

