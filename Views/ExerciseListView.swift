import SwiftUI

struct ExerciseListView: View {
    @ObservedObject var viewModel: ExerciseListViewModel
    @State private var showingAddExercise = false
    
    var body: some View {
        List {
            ForEach(viewModel.exercises) { exercise in
                NavigationLink(destination: ExerciseDetailView(
                    viewModel: ExerciseDetailViewModel(
                        exercise: exercise,
                        onSave: { updatedExercise in
                            viewModel.updateExercise(updatedExercise)
                        }
                    )
                )) {
                    ExerciseRowView(exercise: exercise)
                }
            }
            .onDelete(perform: viewModel.deleteExercise)
        }
        .navigationTitle("Gym Planner")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddExercise = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddExercise) {
            NavigationView {
                ExerciseDetailView(
                    viewModel: ExerciseDetailViewModel(
                        onSave: { newExercise in
                            viewModel.addExercise(newExercise)
                            showingAddExercise = false
                        }
                    )
                )
            }
        }
    }
}

struct ExerciseRowView: View {
    let exercise: Exercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(exercise.name.isEmpty ? "Untitled Exercise" : exercise.name)
                .font(.headline)
            
            HStack(spacing: 12) {
                if exercise.sets > 0 {
                    Label("\(exercise.sets)", systemImage: "number")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                if exercise.reps > 0 {
                    Label("\(exercise.reps)", systemImage: "arrow.repeat")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                if exercise.weight > 0 {
                    Label("\(exercise.weight, specifier: "%.1f") kg", systemImage: "scalemass")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if exercise.imagePath != nil {
                Image(systemName: "photo")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
    }
}

