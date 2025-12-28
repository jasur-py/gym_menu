import SwiftUI

struct ExerciseListView: View {
    @ObservedObject var viewModel: ExerciseListViewModel
    @StateObject private var groupViewModel = TrainingGroupViewModel()
    @ObservedObject var settingsService = SettingsService.shared
    @State private var showingAddExercise = false
    @State private var showingSettings = false
    @State private var showingGroups = false
    @State private var expandedExerciseId: UUID?
    @State private var selectedDate = Date()
    @State private var showingCalendar = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Group tabs at the top
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(groupViewModel.groups) { group in
                        Button(action: {
                            withAnimation {
                                if group.name == "All Exercises" {
                                    viewModel.selectedGroupId = nil
                                } else {
                                    viewModel.selectedGroupId = group.id
                                }
                            }
                        }) {
                            let isSelected = (group.name == "All Exercises" && viewModel.selectedGroupId == nil) || 
                                           (group.name != "All Exercises" && viewModel.selectedGroupId == group.id)
                            
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(group.color)
                                    .frame(width: 12, height: 12)
                                
                                Text(group.name)
                                    .font(.subheadline)
                                    .fontWeight(isSelected ? .semibold : .regular)
                            }
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(isSelected ? group.color.opacity(0.2) : Color(.systemGray6))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(isSelected ? group.color : Color.clear, lineWidth: 2)
                            )
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            .background(Color(.systemBackground))
            
            ZStack(alignment: .bottomLeading) {
                // Main list view - scrollable
                List {
                    ForEach(viewModel.filteredExercises) { exercise in
                        ExerciseRowView(
                            exercise: exercise,
                            isExpanded: expandedExerciseId == exercise.id,
                            groupViewModel: groupViewModel,
                            onToggleExpand: {
                                withAnimation {
                                    if expandedExerciseId == exercise.id {
                                        expandedExerciseId = nil
                                    } else {
                                        expandedExerciseId = exercise.id
                                    }
                                }
                            },
                            onUpdateExercise: { updatedExercise in
                                viewModel.updateExercise(updatedExercise)
                            },
                            settingsService: settingsService,
                            onDelete: { exerciseToDelete in
                                viewModel.deleteExercise(exerciseToDelete)
                                if expandedExerciseId == exerciseToDelete.id {
                                    expandedExerciseId = nil
                                }
                            }
                        )
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
                .scrollContentBackground(.hidden)
                .background(settingsService.backgroundColor.ignoresSafeArea())
                .scrollIndicators(.visible)
                .ignoresSafeArea(edges: .bottom)
            
            // Calendar button - floating at bottom left
            if !showingCalendar {
                VStack {
                    Spacer()
                    HStack {
                        Button(action: {
                            withAnimation {
                                showingCalendar.toggle()
                            }
                        }) {
                            Image(systemName: "calendar")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                        }
                        .padding(.leading, 20)
                        .padding(.bottom, 20)
                        
                        Spacer()
                    }
                }
            }
            
            // Calendar overlay
            if showingCalendar {
                // Semi-transparent background
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showingCalendar = false
                        }
                    }
                
                // Calendar card - properly aligned
                VStack {
                    Spacer()
                    VStack(spacing: 0) {
                        // Header with close button
                        HStack {
                            Text("Calendar")
                                .font(.headline)
                                .padding(.leading, 20)
                            Spacer()
                            Button(action: {
                                withAnimation {
                                    showingCalendar = false
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.trailing, 20)
                        }
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        
                        CalendarView(selectedDate: $selectedDate)
                            .frame(height: 300)
                            .background(Color(.systemBackground))
                    }
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: -5)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            }
        }
        .navigationTitle("Gym Planner")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack(spacing: 16) {
                    Button(action: {
                        showingGroups = true
                    }) {
                        Image(systemName: "folder")
                    }
                    
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape")
                    }
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
        .sheet(isPresented: $showingGroups) {
            TrainingGroupView(groupViewModel: groupViewModel, exerciseViewModel: viewModel)
        }
        .sheet(isPresented: $showingAddExercise) {
            NavigationView {
                ExerciseDetailView(
                    viewModel: ExerciseDetailViewModel(
                        exercise: Exercise(groupId: viewModel.selectedGroupId),
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
    @ObservedObject var groupViewModel: TrainingGroupViewModel
    let onToggleExpand: () -> Void
    let onUpdateExercise: (Exercise) -> Void
    @ObservedObject var settingsService: SettingsService
    var onDelete: ((Exercise) -> Void)?
    @State private var showingDeleteConfirmation = false
    @State private var showingEditView = false
    
    private var groupColor: Color {
        if let groupId = exercise.groupId,
           let group = groupViewModel.getGroup(by: groupId) {
            return group.color
        }
        return Color.gray.opacity(0.3)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Colored left border indicator
            Rectangle()
                .fill(groupColor)
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 8) {
            // Header - clickable to expand/collapse
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        // Group color indicator circle
                        if exercise.groupId != nil {
                            Circle()
                                .fill(groupColor)
                                .frame(width: 10, height: 10)
                        }
                        
                        Text(exercise.name.isEmpty ? "Untitled Exercise" : exercise.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        // Edit button
                        Button(action: {
                            showingEditView = true
                        }) {
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    if !exercise.sets.isEmpty {
                        let totalReps = exercise.sets.map({ $0.reps }).reduce(0, +)
                        HStack(spacing: 12) {
                            Label("\(exercise.sets.count) sets", systemImage: "number")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if totalReps > 0 {
                                Label("\(totalReps) reps", systemImage: "arrow.repeat")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Images indicator in minimized view
                    if !exercise.imagePaths.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "photo")
                                .font(.caption2)
                            Text("\(exercise.imagePaths.count)")
                                .font(.caption2)
                        }
                        .foregroundColor(.blue)
                        .padding(.top, 2)
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onToggleExpand()
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
                    
                    // Images - horizontal scrollable view
                    if !exercise.imagePaths.isEmpty {
                        HorizontalImageView(imagePaths: exercise.imagePaths)
                    }
                    
                    // Delete button in expanded view
                    if onDelete != nil {
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
            .padding(.horizontal, 8)
        }
        .padding(.vertical, 8)
        .sheet(isPresented: $showingEditView) {
            NavigationView {
                ExerciseDetailView(
                    viewModel: ExerciseDetailViewModel(
                        exercise: exercise,
                        onSave: { updatedExercise in
                            onUpdateExercise(updatedExercise)
                            showingEditView = false
                        }
                    ),
                    onDelete: { exerciseToDelete in
                        onDelete?(exerciseToDelete)
                        showingEditView = false
                    }
                )
            }
        }
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
        VStack(spacing: 0) {
            DatePicker(
                "Select Date",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
    }
}
