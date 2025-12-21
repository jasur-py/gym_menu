import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ExerciseListViewModel()
    
    var body: some View {
        NavigationStack {
            ExerciseListView(viewModel: viewModel)
        }
    }
}

