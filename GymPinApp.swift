import SwiftUI

@main
struct GymPinApp: App {
    @ObservedObject var settingsService = SettingsService.shared
    
    var body: some Scene {
        WindowGroup {
            NewMainView()
                .preferredColorScheme(settingsService.appearanceMode.colorScheme)
        }
    }
}
