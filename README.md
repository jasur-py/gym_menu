# 💪 GymPlanner - iOS Workout Tracking App

<div align="center">

[![iOS](https://img.shields.io/badge/iOS-17.0+-000000?style=flat&logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9+-orange?style=flat&logo=swift&logoColor=white)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-blue?style=flat&logo=swift&logoColor=white)](https://developer.apple.com/xcode/swiftui/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A modern, feature-rich iOS workout tracking app built with SwiftUI and MVVM architecture.

[Features](#-features) • [Screenshots](#-screenshots) • [Installation](#-installation) • [Usage](#-usage) • [Architecture](#-architecture)

</div>

---

## ✨ Features

### 🏋️ Exercise Management
- ✅ **Create & Edit Exercises** - Add detailed workout information
- ✅ **Multiple Sets** - Track individual sets with separate reps and weight
- ✅ **Weight Units** - Toggle between kg and lb
- ✅ **Exercise Notes** - Add custom notes and instructions
- ✅ **Multi-Image Support** - Attach up to 10 photos per exercise
- ✅ **Horizontal Image Gallery** - Swipe through exercise photos

### 🎯 Training Groups
- ✅ **Custom Groups** - Organize exercises into training groups
- ✅ **Color-Coded Tabs** - Visual organization with custom colors
- ✅ **Multi-Group Assignment** - Assign exercises to up to 7 groups
- ✅ **"All Exercises" View** - See all exercises across all groups
- ✅ **Group Management** - Add, edit, delete, and reorder groups

### 🎨 Customization
- ✅ **Light/Dark Mode** - System, Light, or Dark theme options
- ✅ **Background Colors** - 8 predefined background color options
- ✅ **Custom Header** - Beautiful gradient or custom image header
- ✅ **Configurable Settings** - Personalize your workout experience

### 🔄 Drag & Drop
- ✅ **Exercise Reordering** - Long-press and drag to reorder exercises
- ✅ **Per-Tab Sorting** - Each training group maintains its own order
- ✅ **Tab Reordering** - Drag training group tabs to rearrange
- ✅ **Persistent Order** - Sorting preferences saved automatically

### 📅 Additional Features
- ✅ **Calendar View** - Track workout dates with graphical calendar
- ✅ **Data Persistence** - All data saved locally and securely
- ✅ **Swipe to Delete** - Quick exercise removal
- ✅ **Offline-First** - Works without internet connection
- ✅ **Privacy-Focused** - All data stays on your device

---

## 📱 Screenshots

### Main Interface
<img src="Screenshots/main_page.png" alt="Main View" width="300"/>

*Exercise list with custom training group tabs*

### Training Groups
<img src="Screenshots/training_groups.png" alt="Training Groups" width="300"/>

*Create, manage and organize your training groups*

### Exercise Details
<img src="Screenshots/exercise_detail.png" alt="Exercise Detail" width="300"/>

*Add/Edit exercise with sets, images, and notes*

### Settings
<img src="Screenshots/settings.png" alt="Settings" width="300"/>

*Customize appearance, weight units, and background*

### Calendar & Dark Mode
<img src="Screenshots/calendar.png" alt="Calendar View" width="300"/>

*Calendar view for workout tracking*

---

## 🛠 Requirements

- **iOS**: 17.0 or later
- **Xcode**: 15.0 or later
- **Swift**: 5.9 or later
- **Device**: iPhone (optimized for iPhone 12 and newer)

---

## 📥 Installation

### Option 1: Clone and Run in Simulator

```bash
# Clone the repository
git clone https://github.com/jasur-py/gym_menu.git

# Navigate to project directory
cd gym_menu

# Open in Xcode
open GymPlanner/GymPlanner.xcodeproj

# Select a simulator (e.g., iPhone 15 Pro)
# Press Cmd + R to build and run
```

### Option 2: Install on Physical Device

1. **Open Xcode** and load the project
2. **Connect your iPhone** via USB cable
3. **Select your device** from the device selector (top-left)
4. **Configure Signing**:
   - Select project in navigator
   - Go to "Signing & Capabilities" tab
   - Choose your Apple Developer team
   - Change Bundle Identifier to something unique (e.g., `com.yourname.GymPlanner`)
5. **Trust Developer** (first time only):
   - On iPhone: Settings → General → VPN & Device Management
   - Tap your Apple ID and select "Trust"
6. **Build and Run** (Cmd + R)

---

## 🎯 Usage

### Getting Started

1. **Launch the app** - You'll see the main exercise list
2. **Create a training group**:
   - Tap the folder icon (📁) in top-left
   - Tap "+" to add a new group
   - Choose a name and color
   
3. **Add your first exercise**:
   - Tap the "+" button in top-right
   - Enter exercise name
   - Select training group(s)
   - Add sets with reps and weight
   - Attach photos (optional)
   - Add notes (optional)
   - Tap "Save"

### Managing Exercises

- **Edit**: Tap the pencil icon (✏️) on any exercise
- **Delete**: Swipe left on an exercise → "Delete"
- **Reorder**: Long-press an exercise and drag to new position
- **View Details**: Tap an exercise to expand/collapse
- **Add Images**: Tap "📷 Select Photos" in edit mode

### Organizing Workouts

- **Switch Groups**: Tap any training group tab at the top
- **View All**: Tap "All Exercises" to see everything
- **Reorder Tabs**: Long-press and drag tabs left/right
- **Edit Groups**: Tap folder icon → Edit/Delete groups

### Customization

- **Settings**: Tap gear icon (⚙️) in top-left
- **Change Theme**: Select System, Light, or Dark mode
- **Weight Units**: Toggle between kg and lb
- **Background**: Choose from 8 color options

### Calendar

- **Open Calendar**: Tap calendar icon (📅) at bottom-left
- **Select Date**: Tap any date in the calendar
- **Close**: Tap X or tap outside the calendar

---

## 🏗 Architecture

### Design Pattern: MVVM (Model-View-ViewModel)

```
┌─────────────────────────────────────────────────┐
│                    Views                        │
│  (SwiftUI Components - UI Layer)                │
│  • ExerciseListView                             │
│  • ExerciseDetailView                           │
│  • SettingsView                                 │
│  • TrainingGroupView                            │
└───────────────┬─────────────────────────────────┘
                │
                ↓ Binding / ObservedObject
┌─────────────────────────────────────────────────┐
│                 ViewModels                      │
│  (Business Logic Layer)                         │
│  • ExerciseListViewModel                        │
│  • ExerciseDetailViewModel                      │
│  • TrainingGroupViewModel                       │
└───────────────┬─────────────────────────────────┘
                │
                ↓ Uses
┌─────────────────────────────────────────────────┐
│            Models & Services                    │
│  (Data Layer)                                   │
│  • Exercise, ExerciseSet, TrainingGroup         │
│  • DataPersistenceService                       │
│  • ImageStorageService                          │
│  • SettingsService                              │
└─────────────────────────────────────────────────┘
```

### Key Components

#### Models
- **`Exercise`** - Exercise data structure with sets, notes, and images
- **`ExerciseSet`** - Individual set with reps and weight
- **`TrainingGroup`** - Training group with name, color, and exercise order

#### ViewModels
- **`ExerciseListViewModel`** - Manages exercise list, filtering, and sorting
- **`ExerciseDetailViewModel`** - Handles exercise creation/editing
- **`TrainingGroupViewModel`** - Manages training groups and their order

#### Services
- **`DataPersistenceService`** - JSON-based data storage
- **`ImageStorageService`** - Image file management
- **`SettingsService`** - User preferences persistence

#### Views
- **`ExerciseListView`** - Main list with tabs and drag-drop
- **`ExerciseDetailView`** - Exercise creation/editing form
- **`SettingsView`** - App customization interface
- **`TrainingGroupView`** - Training group management

---

## 📂 Project Structure

```
gym_menu/
├── GymPlanner/
│   └── GymPlanner.xcodeproj/          # Xcode project file
├── GymPlannerApp.swift                # App entry point
├── Models/
│   ├── Exercise.swift                 # Exercise data model
│   ├── ExerciseSet.swift              # Set data model
│   └── TrainingGroup.swift            # Training group model
├── ViewModels/
│   ├── ExerciseListViewModel.swift    # Exercise list logic
│   ├── ExerciseDetailViewModel.swift  # Exercise detail logic
│   └── TrainingGroupViewModel.swift   # Training group logic
├── Views/
│   ├── ContentView.swift              # Root view
│   ├── ExerciseListView.swift         # Main exercise list
│   ├── ExerciseDetailView.swift       # Exercise form
│   ├── SettingsView.swift             # Settings page
│   ├── TrainingGroupView.swift        # Group management
│   └── Components/
│       ├── CollapsibleImageView.swift # Single image viewer
│       └── HorizontalImageView.swift  # Image gallery
├── Services/
│   ├── DataPersistenceService.swift   # JSON persistence
│   ├── ImageStorageService.swift      # Image file storage
│   └── SettingsService.swift          # Settings management
├── Assets/
│   └── AppIcon.appiconset/            # App icon
├── README.md                          # This file
└── Screenshots/                       # App screenshots (for README)
```

---

## 💾 Data Storage

### Local Storage (Documents Directory)

All data is stored locally on your device:

```
Documents/
├── exercises.json              # Exercise data
├── trainingGroups.json         # Training group data
├── settings.json               # User preferences
└── Images/
    ├── [UUID].jpg              # Exercise images
    ├── [UUID].jpg
    └── ...
```

### Data Models

**Exercise JSON Structure:**
```json
{
  "id": "UUID",
  "name": "Bench Press",
  "sets": [
    { "reps": 10, "weight": 60.0 },
    { "reps": 8, "weight": 70.0 }
  ],
  "notes": "Focus on form",
  "imagePaths": ["UUID.jpg", "UUID.jpg"],
  "groupIds": ["UUID", "UUID"]
}
```

**Training Group JSON Structure:**
```json
{
  "id": "UUID",
  "name": "Push Day",
  "colorData": [0.0, 0.5, 1.0, 1.0],
  "exerciseOrder": ["UUID", "UUID", "UUID"]
}
```

---

## 🔒 Privacy & Security

- ✅ **Local-Only Storage** - All data stays on your device
- ✅ **No Cloud Sync** - Your workouts are private
- ✅ **No Analytics** - Zero tracking or data collection
- ✅ **No Internet Required** - Fully offline app
- ✅ **Photo Permissions** - Only requested when adding images

---

## 🚀 Future Enhancements

Potential features for future versions:

- [ ] iCloud sync across devices
- [ ] Workout history and progress tracking
- [ ] Rest timer between sets
- [ ] Exercise templates and presets
- [ ] Charts and statistics
- [ ] Export workout data (CSV/PDF)
- [ ] Apple Watch companion app
- [ ] Workout reminders and notifications

---

## 🐛 Known Issues

- None currently! 🎉

If you find a bug, please [open an issue](https://github.com/jasur-py/gym_menu/issues).

---

## 🤝 Contributing

Contributions are welcome! If you'd like to contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Jasur Khojiev**
- GitHub: [@jasur-py](https://github.com/jasur-py)
- Repository: [gym_menu](https://github.com/jasur-py/gym_menu)

---

## 🙏 Acknowledgments

- Built with [SwiftUI](https://developer.apple.com/xcode/swiftui/)
- Icons from [SF Symbols](https://developer.apple.com/sf-symbols/)
- Inspired by the fitness community 💪

---

## ⭐ Show Your Support

If you find this project helpful, please consider giving it a ⭐ on GitHub!

---

<div align="center">

**Made with ❤️ and SwiftUI**

[Report Bug](https://github.com/jasur-py/gym_menu/issues) • [Request Feature](https://github.com/jasur-py/gym_menu/issues)

</div>
