# Setup Guide for Gym Planner iOS App

## Prerequisites

1. **Install Xcode** from the Mac App Store (if not already installed)
   - This includes the iOS Simulator
   - Make sure to accept the license agreement

2. **Verify Installation**
   ```bash
   xcodebuild -version
   ```

## Option 1: Create Project in Xcode (Recommended)

### Step 1: Open Xcode
- Launch Xcode from Applications or Spotlight

### Step 2: Create New Project
1. Click "Create a new Xcode project"
2. Select **iOS** → **App**
3. Click **Next**

### Step 3: Configure Project
- **Product Name**: `GymPlanner`
- **Team**: Select your Apple ID team (or "None" for personal use)
- **Organization Identifier**: `com.yourname` (e.g., `com.jasur`)
- **Interface**: **SwiftUI**
- **Language**: **Swift**
- **Storage**: **None** (we're using file system)
- **Minimum Deployment**: **iOS 17.0**
- Click **Next**

### Step 4: Save Location
- Choose `/Users/jasur.khojiev/Documents/codes/gym_menu/` as the location
- **Important**: Uncheck "Create Git repository" if you see it (or keep it if you want Git)
- Click **Create**

### Step 5: Replace Default Files
1. **Delete** the default `ContentView.swift` that Xcode created
2. **Delete** the default `GymPlannerApp.swift` (or `App.swift`) that Xcode created

### Step 6: Add Our Files to Xcode
1. In Xcode, right-click on the project name in the navigator
2. Select **Add Files to "GymPlanner"...**
3. Navigate to the project folder
4. Select all these folders/files:
   - `Models/`
   - `ViewModels/`
   - `Views/`
   - `Services/`
   - `GymPlannerApp.swift`
5. Make sure **"Copy items if needed"** is **UNCHECKED** (files are already in the right place)
6. Make sure **"Create groups"** is selected
7. Click **Add**

### Step 7: Update Info.plist
1. In Xcode, find `Info.plist` in the project navigator
2. If it's not visible, right-click the project → **New File** → **Property List** → Name it `Info.plist`
3. Open `Info.plist` and add:
   - Key: `NSPhotoLibraryUsageDescription`
   - Type: `String`
   - Value: `This app needs access to your photo library to attach images to exercises.`

   OR simply copy the contents from our `Info.plist` file

### Step 8: Set Minimum Deployment Target
1. Click on the project name in the navigator (top blue icon)
2. Select the **GymPlanner** target
3. Go to **General** tab
4. Under **Deployment Info**, set **iOS** to **17.0**

### Step 9: Build and Run
1. Select a simulator from the device menu (top toolbar):
   - iPhone 15 Pro (or any iOS 17+ simulator)
2. Click the **Play** button (▶️) or press `Cmd + R`
3. The app should build and launch in the simulator!

## Option 2: Use Command Line (Advanced)

If you prefer command line, you can create the project structure and then open it in Xcode:

```bash
# This will be done automatically - the files are already created
# Just open the folder in Xcode and create a new project there
```

## Troubleshooting

### "No such module 'SwiftUI'"
- Make sure you selected SwiftUI when creating the project
- Check that the deployment target is iOS 17.0+

### "Cannot find 'Exercise' in scope"
- Make sure all files were added to the Xcode project
- Check that files are included in the target (select file → File Inspector → Target Membership)

### Simulator Issues
- Open Xcode → **Xcode** → **Settings** → **Platforms** → Download iOS 17 Simulator if needed
- Or use: **Xcode** → **Window** → **Devices and Simulators** → Download simulators

### Photo Library Permission
- The app will request permission when you first try to add a photo
- If it doesn't work, check that `NSPhotoLibraryUsageDescription` is in Info.plist

## Quick Test

Once running:
1. Tap the **+** button to add an exercise
2. Enter a name (e.g., "Bench Press")
3. Add sets, reps, weight
4. Tap "Select Photo" to add an image
5. Tap "Show Image" to see it collapse/expand
6. Save the exercise
7. It should appear in the list!

## Need Help?

If you encounter any issues:
1. Check that all files are added to the Xcode project
2. Verify the deployment target is iOS 17.0
3. Clean build folder: **Product** → **Clean Build Folder** (Shift + Cmd + K)
4. Try building again

