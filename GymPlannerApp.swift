import SwiftUI

@main
struct GymPlannerApp: App {
    @ObservedObject var settingsService = SettingsService.shared
    
    var body: some Scene {
        WindowGroup {
            // TESTING: NewMainView (switch back to ContentView later)
            NewMainView()
                .preferredColorScheme(settingsService.appearanceMode.colorScheme)
        }
    }
}

