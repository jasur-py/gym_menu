import SwiftUI

struct ExerciseListView: View {
    @ObservedObject var viewModel: ExerciseListViewModel
    @ObservedObject var settingsService = SettingsService.shared
    @State private var showingAddExercise = false
    @State private var showingSettings = false
    @State private var expandedExerciseId: UUID?
    @State private var selectedDate = Date()
    
    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach(viewModel.exercises) { exercise in
                    NavigationLink(destination: ExerciseDetailView(
                        viewModel: ExerciseDetailViewModel(
                            exercise: exercise,
                            onSave: { updatedExercise in
                                viewModel.updateExercise(updatedExercise)
                            }
                        ),
                        onDelete: { exerciseToDelete in
                            viewModel.deleteExercise(exerciseToDelete)
                        }
                    )) {
                        ExerciseRowView(
                            exercise: exercise,
                            isExpanded: expandedExerciseId == exercise.id,
                            onToggleExpand: {
                                withAnimation {
                                    if expandedExerciseId == exercise.id {
                                        expandedExerciseId = nil
                                    } else {
                                        expandedExerciseId = exercise.id
                                    }
                                }
                            },
                            settingsService: settingsService,
                            onDelete: { exerciseToDelete in
                                viewModel.deleteExercise(exerciseToDelete)
                                if expandedExerciseId == exerciseToDelete.id {
                                    expandedExerciseId = nil
                                }
                            }
                        )
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            viewModel.deleteExercise(exercise)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .onDelete(perform: viewModel.deleteExercise)
            }
            .listStyle(.insetGrouped)
            
            // Calendar at the bottom
            VStack(spacing: 0) {
                Divider()
                CalendarView(selectedDate: $selectedDate)
                    .frame(height: 300)
            }
        }
        .background(settingsService.backgroundColor)
        .navigationTitle("Gym Planner")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    showingSettings = true
                }) {
                    Image(systemName: "gearshape")
                }
            }
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
                    ),
                    onDelete: nil
                )
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

struct ExerciseRowView: View {
    let exercise: Exercise
    let isExpanded: Bool
    let onToggleExpand: () -> Void
    @ObservedObject var settingsService: SettingsService
    var onDelete: ((Exercise) -> Void)?
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name.isEmpty ? "Untitled Exercise" : exercise.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if !exercise.sets.isEmpty {
                        HStack(spacing: 12) {
                            Label("\(exercise.sets.count) sets", systemImage: "number")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if let totalReps = exercise.sets.map({ $0.reps }).reduce(0, +), totalReps > 0 {
                                Label("\(totalReps) reps", systemImage: "arrow.repeat")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Spacer()
                
                Button(action: onToggleExpand) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .buttonStyle(.plain)
            }
            
            // Expanded content
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    // Sets details
                    if !exercise.sets.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Sets")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { index, set in
                                HStack {
                                    Text("Set \(index + 1):")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    if set.reps > 0 {
                                        Text("\(set.reps) reps")
                                            .font(.caption)
                                    }
                                    if set.weight > 0 {
                                        Text("\(set.weight, specifier: "%.1f") \(settingsService.weightUnit.rawValue)")
                                            .font(.caption)
                                    }
                                }
                                .padding(.leading, 8)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    // Notes
                    if !exercise.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Notes")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(exercise.notes)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    // Image
                    if exercise.imagePath != nil {
                        if let image = ImageStorageService.shared.loadImage(from: exercise.imagePath!) {
                            CollapsibleImageView(
                                image: image,
                                imagePath: exercise.imagePath
                            )
                        }
                    }
                    
                    // Delete button in expanded view
                    if let onDelete = onDelete {
                        Button(role: .destructive) {
                            showingDeleteConfirmation = true
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Exercise")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.top, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, 8)
        .alert("Delete Exercise", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete?(exercise)
            }
        } message: {
            Text("Are you sure you want to delete \"\(exercise.name)\"? This action cannot be undone.")
        }
    }
}

struct CalendarView: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Calendar")
                .font(.headline)
                .padding(.top)
            
            DatePicker(
                "Select Date",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .padding(.horizontal)
        }
        .background(Color(.systemBackground))
    }
}
