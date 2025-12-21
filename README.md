# Gym Planner iOS App

A SwiftUI-based iOS app for planning and tracking gym exercises with image attachments.

## Features

- Create and manage a list of exercises
- Add exercise details: name, sets, reps, weight, and notes
- Attach photos to exercises
- Collapsible image display for better UI organization
- Persistent data storage using JSON files
- Image storage in app's documents directory

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Project Structure

```
gym_menu/
├── Models/
│   └── Exercise.swift
├── ViewModels/
│   ├── ExerciseListViewModel.swift
│   └── ExerciseDetailViewModel.swift
├── Views/
│   ├── ContentView.swift
│   ├── ExerciseListView.swift
│   ├── ExerciseDetailView.swift
│   └── Components/
│       └── CollapsibleImageView.swift
├── Services/
│   ├── DataPersistenceService.swift
│   └── ImageStorageService.swift
├── GymPlannerApp.swift
└── Info.plist
```

## Setup Instructions

1. Open Xcode and create a new iOS App project
2. Set the minimum deployment target to iOS 17.0
3. Copy all the files from this repository into your Xcode project
4. Ensure the Info.plist includes the NSPhotoLibraryUsageDescription key (already included)
5. Build and run the app

## Usage

- Tap the "+" button to add a new exercise
- Fill in exercise details (name, sets, reps, weight, notes)
- Tap "Select Photo" to attach an image from your photo library
- Tap "Show Image" / "Hide Image" to toggle image visibility
- Swipe left on an exercise to delete it
- Tap an exercise to edit it

## Data Storage

- Exercise data is stored in `Documents/exercises.json`
- Images are stored in `Documents/Images/` directory
- All data persists between app launches
