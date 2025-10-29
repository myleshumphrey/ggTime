# 🚀 GG Time - App Store Submission Checklist

## 📋 Pre-Submission Requirements

### 1. ✅ Code & Testing
- [ ] Clean build with no warnings
- [ ] Tested on physical iPhone (not just simulator)
- [ ] Tested with multiple participants on different devices
- [ ] Tested all 4 join options (Join, Maybe, Different Time, Can't Join)
- [ ] Tested recently played games feature
- [ ] Tested leaving and rejoining sessions
- [ ] Verified personalized messages display correctly
- [ ] Tested the extension in both compact and expanded views

### 2. 📱 App Store Connect Setup

#### A. Create App Record
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click **"My Apps"** → **"+"** → **"New App"**
3. Fill in required info:
   - **Platform**: iOS
   - **Name**: GG Time
   - **Primary Language**: English
   - **Bundle ID**: Select your bundle ID (e.g., `machix.ggTime`)
   - **SKU**: A unique identifier (e.g., `ggTime-001`)
   - **User Access**: Full Access (if you have other team members)

#### B. App Information
- [ ] Upload app icon (1024x1024 PNG, no transparency)
- [ ] App Privacy: Fill out privacy questionnaire
  - Answer "No" to data collection questions (your app uses local storage only)
- [ ] Age Rating: Complete questionnaire
  - Should be "4+" (no objectionable content)

#### C. Pricing and Availability
- [ ] Set pricing (Free)
- [ ] Select countries/regions for availability
- [ ] Review availability

### 3. 📝 App Store Listing

#### A. Screenshots (REQUIRED)
You need screenshots for different device sizes. Create these:
- **iPhone 6.7" Display** (iPhone 15 Pro Max, etc.): 1290 x 2796 pixels
- **iPhone 6.5" Display** (iPhone 11 Pro Max, etc.): 1242 x 2688 pixels
- **iPhone 5.5" Display** (iPhone 8 Plus, etc.): 1242 x 2208 pixels

**Screenshots should show:**
1. Main app interface (creating a session)
2. Session bubble with personalized message
3. Join options screen with 4 buttons
4. Recently played games
5. Participants list showing different statuses

#### B. Description (Up to 4000 characters)
Write compelling copy about GG Time's features:
- ✅ Quick gaming session coordination
- ✅ Personalized invites
- ✅ Four response options
- ✅ Recently played games
- ✅ Real-time participant updates
- ✅ Local storage only (privacy-first)

#### C. Keywords (Up to 100 characters)
Suggested: `gaming, coordination, iMessage, friends, multiplayer, sessions, planning, quick`

#### D. App Preview (Optional but Recommended)
Video showing app in action (up to 30 seconds)

### 4. 🔐 Build Submission

#### A. Configure in Xcode
1. Select your project → "ggTime"
2. **Signing & Capabilities** tab
3. Choose your Team (Apple Developer account)
4. Ensure "Automatically manage signing" is checked
5. Select correct Bundle Identifier

#### B. Create Archive
1. In Xcode, select **"Any iOS Device"** (not simulator)
2. **Product** → **Archive**
3. Wait for archive to complete
4. Window opens showing archives

#### C. Upload to App Store
1. In Organizer window, click **"Distribute App"**
2. Choose **"App Store Connect"**
3. Click **"Upload"**
4. Follow wizard:
   - Select your team
   - Choose distribution certificate
   - Select provisioning profile
   - Review and upload

#### D. Submit for Review
1. Go back to App Store Connect
2. Select your app
3. Click **"Prepare for Submission"**
4. Select the build you just uploaded
5. Fill out remaining info
6. Click **"Submit for Review"**

### 5. 📦 Required Assets

#### A. App Icon
- **Format**: PNG
- **Size**: 1024 x 1024 pixels
- **Requirements**:
  - No transparency
  - No rounded corners (iOS will add them)
  - No text unless it's part of your design
  - Square aspect ratio

#### B. Privacy Policy (REQUIRED even for free apps!)
Create a simple privacy policy stating:
- What data you collect (game names, times)
- How you use it (locally on device only)
- Who you share it with (nobody - local only)
- Your contact information

**Quick Template:**
```
Privacy Policy for GG Time

GG Time does not collect, store, or transmit any user data to external servers. 
All data (game sessions, participant information) is stored locally on your device 
using iOS UserDefaults.

We do not:
- Collect personal information
- Track user activity
- Share data with third parties
- Use analytics or tracking

Contact: your-email@example.com
```

### 6. ⚠️ Common Issues & Solutions

#### Issue: Missing App Icon
**Solution**: Add 1024x1024 icon to AppIcon asset in Xcode

#### Issue: Missing Compliance
**Solution**: Check "No" for encryption export compliance (local storage only)

#### Issue: Missing Export Compliance Info
**Solution**: Answer "No" to encryption questions

#### Issue: Invalid Bundle Identifier
**Solution**: Ensure bundle ID matches in:
- Xcode project settings
- App Store Connect
- Certificates/Profiles

### 7. 🧪 TestFlight Setup (RECOMMENDED)

Before public release, test with TestFlight:
1. Upload build to TestFlight
2. Add internal/external testers
3. Share TestFlight link
4. Get feedback and fix issues
5. Submit to App Store after testing

### 8. ⏱️ Timeline Expectations

- **Apple Review**: 24-48 hours typically
- **First Submission**: May require 2-3 iterations if issues found
- **Total Time**: 3-7 days for approval (first time)

### 9. ✅ Pre-Submission Checklist

Run through this final checklist:
- [ ] App builds without errors
- [ ] Tested on real device
- [ ] Icon is 1024x1024 PNG
- [ ] Screenshots are correct sizes
- [ ] Description is compelling
- [ ] Keywords are relevant
- [ ] Privacy policy is created and accessible
- [ ] Pricing is set
- [ ] Build is uploaded to App Store Connect
- [ ] All required fields are filled
- [ ] Age rating is accurate
- [ ] Export compliance is completed
- [ ] App doesn't crash on launch
- [ ] All features work as expected

### 10. 🎯 Post-Submission

- [ ] Monitor App Store Connect for status updates
- [ ] Check email for review feedback
- [ ] If rejected, address issues and resubmit
- [ ] Once approved, promote your app!

## 🚨 CRITICAL: Before You Submit

1. **Test the actual iMessage extension** - not just in simulator
2. **Remove all debug print statements** (or make them DEBUG-only)
3. **Test on iOS 15.0+** (your deployment target)
4. **Verify the 4-button layout works** properly
5. **Check that personalized messages** display correctly
6. **Test with actual contacts** (not just self-messages)

## 💡 Tips for Faster Approval

- Respond to reviewer feedback quickly
- Make sure all features work as described
- Provide reviewer notes if you need special testing
- Test thoroughly before submitting
- Follow App Store Review Guidelines
- Keep the app simple and functional

## 📞 Need Help?

- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

---

**Good luck with your submission! 🎉**

