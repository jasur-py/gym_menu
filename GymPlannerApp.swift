import SwiftUI

@main
struct GymPlannerApp: App {
    @ObservedObject var settingsService = SettingsService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(settingsService.appearanceMode.colorScheme)
        }
    }
}

