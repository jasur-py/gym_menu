import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ExerciseListViewModel()
    @ObservedObject var settingsService = SettingsService.shared
    
    var body: some View {
        NavigationStack {
            ExerciseListView(viewModel: viewModel)
        }
        .background(settingsService.backgroundColor)
    }
}

