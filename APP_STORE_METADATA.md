# App Store Connect Metadata — GymPlanner

Use this file as a reference when filling in App Store Connect fields.

---

## App Information

- **App Name**: Gym Planner
- **Subtitle** (30 chars max): Plan, Track & Crush Workouts
- **Bundle ID**: com.jasur.GymPlanner
- **SKU**: GYMPLANNER2026
- **Primary Language**: English (U.S.)
- **Category**: Health & Fitness
- **Secondary Category**: Lifestyle
- **Content Rights**: Does not contain, show, or access third-party content
- **Age Rating**: 4+ (no objectionable content)

---

## Version Information

- **Version**: 1.0.0
- **Build**: 1
- **Copyright**: 2026 Jasur Khojiev

---

## App Store Description

### Promotional Text (170 chars max — can be updated without a new build)

Your all-in-one gym companion. Organize exercises by muscle groups, plan weekly workouts on a calendar, track sets and reps, and never miss a supplement with smart reminders.

### Description (4000 chars max)

Gym Planner is a clean, focused workout organizer built for lifters who want full control over their training without the clutter. No subscriptions. No ads. Just your workouts, your way.

ORGANIZE YOUR EXERCISES
Create a personalized exercise library with custom names, sets, reps, and weight tracking. Attach reference images or animated GIFs to each exercise so you always know the correct form. Assign exercises to multiple training groups like Push, Pull, Legs, or any custom split you prefer.

TRAINING GROUPS
Build your own training split with color-coded groups. Reorder them by priority, rename them anytime, and see all exercises at a glance when you tap into a group. Drag and drop exercises to match your preferred workout order.

WEEKLY CALENDAR PLANNER
Plan your entire training week using an interactive monthly calendar. Drag your training groups onto any date to schedule workouts. See your upcoming week at a glance and stay consistent with your routine.

WORKOUT MODE
Start a workout with built-in timers for active sets and rest periods. Log your reps and weight for each set, and compare against your last session. Stay focused with a clean, distraction-free workout interface.

SUPPLEMENTS REMINDERS
Never forget your creatine, protein, or vitamins again. Set up daily, weekly, monthly, or custom supplement reminders with personalized notes. Notifications arrive right on time so you stay on track.

DAILY MOTIVATION
Start each session with a motivational quote from legendary athletes, coaches, and thinkers. Rate quotes to fine-tune your daily inspiration feed.

FULL IMAGE VIEWER
Tap any exercise image to view it in stunning full screen. Swipe through multiple images and watch GIF animations play at full resolution. A beautifully immersive viewing experience.

DESIGNED FOR YOU
- Light, Dark, or System appearance
- Kilogram or Pound weight units
- Custom background colors
- Modern Liquid Glass design language

No account required. No internet needed. All your data stays on your device.

### Keywords (100 chars max, comma-separated)

gym,planner,workout,fitness,exercise,tracker,training,log,sets,reps,weight,calendar,supplements,timer

---

## What's New in This Version (Release Notes)

Initial release of Gym Planner.

- Create and manage your exercise library
- Organize exercises into custom training groups
- Plan workouts on a monthly calendar with drag-and-drop
- Built-in workout and rest timers
- Attach reference images and GIF animations to exercises
- Full-screen image viewer with swipe navigation
- Supplements reminder with flexible scheduling
- Daily motivational quotes
- Dark mode and custom themes
- Offline-first — no account or internet required

---

## App Review Information

### Contact Information
- **First Name**: Jasur
- **Last Name**: Khojiev
- **Email**: (your email)
- **Phone**: (your phone number)

### Notes for Review
This is a gym workout planning app. It stores all data locally on the device using JSON files and UserDefaults. No server-side component exists. The app requests Photo Library access for attaching exercise reference images and Notification permission for workout and supplement reminders. No account creation is required.

### Demo Account
Not applicable — the app does not require sign-in.

---

## URLs (Required)

### Privacy Policy URL
Host the privacy policy (see PRIVACY_POLICY.md in this repo) at a public URL.
Example: https://jasur-py.github.io/gym_menu/privacy-policy

### Support URL
Example: https://github.com/jasur-py/gym_menu/issues

### Marketing URL (Optional)
Example: https://github.com/jasur-py/gym_menu

---

## Screenshots Required

You need screenshots for at least these device sizes:
1. **6.7-inch** (iPhone 15 Pro Max / iPhone 16 Pro Max) — 1290 x 2796 px
2. **6.5-inch** (iPhone 14 Plus / iPhone 15 Plus) — 1284 x 2778 px (optional if 6.7 provided)
3. **5.5-inch** (iPhone 8 Plus) — 1242 x 2208 px (optional)
4. **iPad Pro 12.9-inch** — 2048 x 2732 px (if supporting iPad)

Minimum 3 screenshots, maximum 10 per device size.

### Recommended Screenshot Flow
1. Main dashboard with workout programs and calendar
2. Exercise list with training group tabs
3. Exercise detail/edit form
4. Full-screen image viewer
5. Workout group with timer
6. Calendar/day planning view
7. Supplements reminder
8. Settings page

---

## Pre-Submission Checklist

- [ ] Apple Developer Program membership is active ($99/year)
- [ ] App icon is 1024x1024 PNG (already set in Assets.xcassets)
- [ ] All required screenshots captured at correct resolutions
- [ ] Privacy Policy hosted at a public URL
- [ ] Support URL is accessible
- [ ] Tested on a real device (not just simulator)
- [ ] Archive built with Release configuration
- [ ] No compiler warnings in Release build
- [ ] ITSAppUsesNonExemptEncryption set to NO in Info.plist
- [ ] PrivacyInfo.xcprivacy file included in the project
- [ ] Version number and build number are correct
- [ ] App runs without crashes on iOS 17+
