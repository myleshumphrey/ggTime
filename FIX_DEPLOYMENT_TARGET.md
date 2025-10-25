# 🔧 Fix Deployment Target Error

If you're seeing this error:
```
MH-iPhone (3)'s iOS 18.6.2 doesn't match ggTime.app's iOS 26.0 deployment target
```

**The deployment target is set too high!** Follow these steps to fix it:

---

## Quick Fix (2 minutes)

### Step 1: Open Your Project in Xcode
1. Open Xcode
2. Open your `ggTime.xcodeproj` file

### Step 2: Select the GGTime Target
1. Click on the **blue project icon** at the top of the left sidebar
2. In the main editor, you'll see **TARGETS** list
3. Select **GGTime** (the main app target)

### Step 3: Change Deployment Target
1. Make sure you're on the **General** tab
2. Find **Minimum Deployments** section (near the top)
3. Click the dropdown for **iOS**
4. Change it from whatever it is (probably 26.0 or something high) to: **`15.0`**

### Step 4: Repeat for Extension Target
1. Still in TARGETS list, now select **GGTimeMessagesExtension**
2. Go to **General** tab
3. Find **Minimum Deployments**
4. Change iOS to: **`15.0`**

### Step 5: Clean and Rebuild
1. Press **⇧⌘K** (Shift-Command-K) to clean
2. Press **⌘B** (Command-B) to build
3. Press **⌘R** (Command-R) to run

---

## ✅ Verification

After changing:
- [ ] Both targets show iOS 15.0 as deployment target
- [ ] Project builds without errors
- [ ] App installs on your device
- [ ] Extension appears in Messages

---

## 📱 What iOS 15.0 Supports

Changing to iOS 15.0 means your app will work on:
- **iPhone 13** series and newer
- **iPhone 12** series
- **iPhone 11** series
- **iPhone XS / XR** and newer
- **iPhone SE (2nd gen)** and newer
- Most iPhones from **2017 onwards**

That covers the vast majority of active iPhones!

---

## Alternative: Use iOS 14.0

If you want even broader compatibility, you can set it to **iOS 14.0**, but:
- Make sure all SwiftUI features we use are compatible
- Test thoroughly on iOS 14 devices
- Some newer SwiftUI APIs may not be available

**Recommended: Stick with iOS 15.0** for the best balance of compatibility and features.

---

## Why Did This Happen?

When you created the Xcode project, Xcode may have auto-selected the latest iOS version as the deployment target. This is common and easy to fix!

The deployment target just tells Xcode "this app should run on iOS XX and newer."

---

## Still Having Issues?

### Error: "Deployment target is higher than maximum supported"
- Update Xcode to the latest version
- Your Xcode might be too old

### Error: Build fails after changing deployment target
- Clean build folder: **Product → Clean Build Folder**
- Delete derived data: **Window → Devices and Simulators → Show in Finder → Delete DerivedData**
- Restart Xcode

### Can't find Deployment Target setting
1. Make sure you're selecting the **TARGET** (not the PROJECT)
2. Should be in the **General** tab at the top
3. Look for "Minimum Deployments" or "Deployment Info"

---

## Quick Visual Guide

```
Xcode Interface:
┌─────────────────────────────────────────────────────────┐
│  Project Navigator                                      │
│  ├── 📘 ggTime (blue icon) ← CLICK THIS                 │
│  │   ├── GGTime                                         │
│  │   ├── GGTimeMessagesExtension                        │
│                                                          │
│  Main Editor (when project selected):                   │
│  ┌──────────────────────────────────────────────────┐   │
│  │ PROJECT               TARGETS                    │   │
│  │ □ ggTime              ✓ GGTime ← SELECT THIS     │   │
│  │                       □ GGTimeMessagesExtension  │   │
│  │                                                  │   │
│  │ General | Signing & Capabilities | Build Settings│   │
│  │ ───────────────────────────────────────────────  │   │
│  │                                                  │   │
│  │ Minimum Deployments                              │   │
│  │ iOS: [15.0        ▼] ← CHANGE THIS               │   │
│  │                                                  │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

---

## After You Fix It

Once your deployment target is set to iOS 15.0:
1. The error message should disappear
2. Your app will install on your iPhone
3. You can continue with testing!

---

**Quick Summary:**
1. Open project in Xcode
2. Select GGTime target → General → iOS: 15.0
3. Select GGTimeMessagesExtension target → General → iOS: 15.0  
4. Clean and rebuild (⇧⌘K then ⌘R)
5. Done! ✅

---

*After fixing, continue with QUICKSTART.md to test your extension!*

