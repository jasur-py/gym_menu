import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct ExerciseListView: View {
    @ObservedObject var viewModel: ExerciseListViewModel
    @StateObject private var groupViewModel = TrainingGroupViewModel()
    @ObservedObject var settingsService = SettingsService.shared
    @State private var showingGroups = false
    @State private var expandedExerciseId: UUID?
    @State private var draggedGroup: TrainingGroup?
    @Environment(\.dismiss) private var dismiss
    
    var preselectedGroupId: UUID? = nil
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background gradient (same as workout card)
            LinearGradient(
                colors: [Color(hex: "3d7b8c"), Color(hex: "2c5f6f"), Color(hex: "234752")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                
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
                .onMove(perform: viewModel.moveExercise)
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .scrollIndicators(.visible)
            
            // Fixed tab strip at the bottom - Always visible
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Add Group Button - Circular with liquid glass
                    Button(action: {
                        showingGroups = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color.primary.opacity(0.2), Color.primary.opacity(0.05)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                )
                                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                            
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    ForEach(groupViewModel.groups) { group in
                        TrainingGroupTabButton(
                            group: group,
                            isSelected: (group.name == "All Exercises" && viewModel.selectedGroupId == nil) || 
                                      (group.name != "All Exercises" && viewModel.selectedGroupId == group.id),
                            onTap: {
                                withAnimation(.spring(response: 0.3)) {
                                    if group.name == "All Exercises" {
                                        viewModel.selectedGroupId = nil
                                    } else {
                                        viewModel.selectedGroupId = group.id
                                    }
                                }
                            },
                            draggedGroup: $draggedGroup,
                            groupViewModel: groupViewModel
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .frame(height: 72)
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.primary.opacity(0.05), Color.primary.opacity(0.02)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )
                    .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: -5)
            )
            }
            
            // Vertical Floating Toolbar - Bottom Right - Liquid Glass Design
            VStack(spacing: 12) {
                // Back button
                Button(action: {
                    // Navigate back to main page with slide animation
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(width: 50, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color.primary.opacity(0.2), Color.primary.opacity(0.05)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                )
                        )
                        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
                }
                .buttonStyle(.plain)
                
                // Add exercise button - NavigationLink for slide animation
                NavigationLink(destination: ExerciseDetailView(
                    viewModel: ExerciseDetailViewModel(
                        exercise: Exercise(groupIds: viewModel.selectedGroupId != nil ? [viewModel.selectedGroupId!] : []),
                        onSave: { newExercise in
                            viewModel.addExercise(newExercise)
                        }
                    ),
                    onDelete: nil
                )) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(width: 50, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color.primary.opacity(0.2), Color.primary.opacity(0.05)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                )
                        )
                        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
                }
                .buttonStyle(.plain)
            }
            .padding(.trailing, 16)
            .padding(.bottom, 88) // Position above the fixed tab strip (72px height + 16px margin)
        }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.clear, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            // Connect groupViewModel to exerciseListViewModel for sorting
            viewModel.groupViewModel = groupViewModel
            
            // Set preselected group if provided
            if let preselectedGroupId = preselectedGroupId {
                viewModel.selectedGroupId = preselectedGroupId
            }
            
            // Initialize exercise orders for all groups if empty (migration for existing data)
            for group in groupViewModel.groups {
                if group.exerciseOrder.isEmpty {
                    groupViewModel.initializeExerciseOrder(for: group, with: viewModel.exercises)
                }
            }
            
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = .clear
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        .sheet(isPresented: $showingGroups) {
            TrainingGroupView(groupViewModel: groupViewModel, exerciseViewModel: viewModel)
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
    
    private var groupColors: [Color] {
        exercise.groupIds.compactMap { groupId in
            groupViewModel.getGroup(by: groupId)?.color
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header - clickable to expand/collapse
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        // Multiple group color indicator circles
                        if !exercise.groupIds.isEmpty {
                            HStack(spacing: 4) {
                                ForEach(Array(groupColors.enumerated()), id: \.offset) { index, color in
                                    Circle()
                                        .fill(color)
                                        .frame(width: 10, height: 10)
                                }
                            }
                        }
                        
                        Text(exercise.name.isEmpty ? "Untitled Exercise" : exercise.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        // Tick box for exercises with 0 sets
                        if exercise.sets.isEmpty {
                            Button(action: {
                                toggleExerciseCompletion()
                            }) {
                                Image(systemName: isExerciseCompletedToday() ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(isExerciseCompletedToday() ? .green : .secondary)
                            }
                            .buttonStyle(.plain)
                            .help("Tick to complete")
                            .accessibilityLabel("Complete exercise")
                            .accessibilityHint("Tick to complete")
                        }
                        
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
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text("Set \(index + 1)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        if let previous = previousEntryText(for: set) {
                                            Text(previous)
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    HStack(spacing: 10) {
                                        TextField("Reps", value: Binding(
                                            get: { set.reps },
                                            set: { newValue in
                                                updateSet(index: index, reps: newValue)
                                            }
                                        ), format: .number)
                                        .keyboardType(.numberPad)
                                        .multilineTextAlignment(.center)
                                        .frame(width: 70)
                                        .padding(.vertical, 6)
                                        .background(Color.white.opacity(0.08))
                                        .cornerRadius(8)
                                        
                                        TextField("Weight", value: Binding(
                                            get: { set.weight },
                                            set: { newValue in
                                                updateSet(index: index, weight: newValue)
                                            }
                                        ), format: .number)
                                        .keyboardType(.decimalPad)
                                        .multilineTextAlignment(.center)
                                        .frame(width: 90)
                                        .padding(.vertical, 6)
                                        .background(Color.white.opacity(0.08))
                                        .cornerRadius(8)
                                        
                                        Text(settingsService.weightUnit.rawValue.uppercased())
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                        
                                        Button(action: {
                                            toggleSetCompletion(index: index)
                                        }) {
                                            Image(systemName: isSetCompletedToday(set) ? "checkmark.circle.fill" : "circle")
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundColor(isSetCompletedToday(set) ? .green : .secondary)
                                        }
                                        .buttonStyle(.plain)
                                        .help("Tick to complete")
                                        .accessibilityLabel("Complete set")
                                        .accessibilityHint("Tick to complete")
                                        
                                        Spacer()
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
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .listRowBackground(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [Color.primary.opacity(0.15), Color.primary.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                .padding(.vertical, 4)
        )
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
        .onChange(of: isExpanded) { _, newValue in
            if newValue {
                resetCurrentInputsIfNeeded()
            }
        }
    }
    
    private func updateSet(index: Int, reps: Int? = nil, weight: Double? = nil) {
        var updatedExercise = exercise
        guard updatedExercise.sets.indices.contains(index) else { return }
        var updatedSet = updatedExercise.sets[index]
        
        if let reps {
            updatedSet.reps = reps
        }
        if let weight {
            updatedSet.weight = weight
        }
        
        updatedSet.lastLoggedReps = updatedSet.reps
        updatedSet.lastLoggedWeight = updatedSet.weight
        updatedSet.lastLoggedAt = Date()
        updatedSet.lastLoggedWeightUnitRaw = settingsService.weightUnit.rawValue
        
        updatedExercise.sets[index] = updatedSet
        onUpdateExercise(updatedExercise)
    }
    
    private func toggleSetCompletion(index: Int) {
        var updatedExercise = exercise
        guard updatedExercise.sets.indices.contains(index) else { return }
        var updatedSet = updatedExercise.sets[index]
        
        if isSetCompletedToday(updatedSet) {
            updatedSet.lastCompletedAt = nil
        } else {
            let now = Date()
            updatedSet.lastCompletedAt = now
            updatedSet.lastLoggedAt = now
            updatedSet.lastLoggedReps = updatedSet.reps
            updatedSet.lastLoggedWeight = updatedSet.weight
            updatedSet.lastLoggedWeightUnitRaw = settingsService.weightUnit.rawValue
        }
        
        updatedExercise.sets[index] = updatedSet
        onUpdateExercise(updatedExercise)
        NotificationCenter.default.post(name: .exercisesUpdated, object: nil)
    }
    
    private func resetCurrentInputsIfNeeded() {
        var updatedExercise = exercise
        var didChange = false
        
        for index in updatedExercise.sets.indices {
            var set = updatedExercise.sets[index]
            let hasValues = set.reps != 0 || set.weight != 0
            if set.lastLoggedAt == nil && hasValues {
                set.lastLoggedAt = Date()
                set.lastLoggedReps = set.reps
                set.lastLoggedWeight = set.weight
                set.lastLoggedWeightUnitRaw = settingsService.weightUnit.rawValue
                set.reps = 0
                set.weight = 0
                updatedExercise.sets[index] = set
                didChange = true
                continue
            }
            if let lastLoggedAt = set.lastLoggedAt, !Calendar.current.isDateInToday(lastLoggedAt), hasValues {
                set.reps = 0
                set.weight = 0
                updatedExercise.sets[index] = set
                didChange = true
            }
        }
        
        if didChange {
            onUpdateExercise(updatedExercise)
        }
    }
    
    private func previousEntryText(for set: ExerciseSet) -> String? {
        guard set.lastLoggedReps > 0 || set.lastLoggedWeight > 0 else { return nil }
        let unitRaw = set.lastLoggedWeightUnitRaw ?? settingsService.weightUnit.rawValue
        let storedUnit = WeightUnit(rawValue: unitRaw) ?? settingsService.weightUnit
        let convertedWeight = storedUnit.convert(from: set.lastLoggedWeight, to: settingsService.weightUnit)
        let weightText = convertedWeight > 0 ? "\(convertedWeight, specifier: "%.1f")" : "0"
        return "Prev: \(set.lastLoggedReps)/\(weightText)"
    }
    
    private func isSetCompletedToday(_ set: ExerciseSet) -> Bool {
        guard let lastCompletedAt = set.lastCompletedAt else { return false }
        return Calendar.current.isDateInToday(lastCompletedAt)
    }
    
    private func isExerciseCompletedToday() -> Bool {
        guard let lastCompletedAt = exercise.lastCompletedAt else { return false }
        return Calendar.current.isDateInToday(lastCompletedAt)
    }
    
    private func toggleExerciseCompletion() {
        var updatedExercise = exercise
        
        if isExerciseCompletedToday() {
            updatedExercise.lastCompletedAt = nil
        } else {
            updatedExercise.lastCompletedAt = Date()
        }
        
        onUpdateExercise(updatedExercise)
        NotificationCenter.default.post(name: .exercisesUpdated, object: nil)
    }
}

// MARK: - Training Group Tab Button with Drag & Drop
struct TrainingGroupTabButton: View {
    let group: TrainingGroup
    let isSelected: Bool
    let onTap: () -> Void
    @Binding var draggedGroup: TrainingGroup?
    @ObservedObject var groupViewModel: TrainingGroupViewModel
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                // Color indicator circle
                Circle()
                    .fill(group.color)
                    .frame(width: 10, height: 10)
                    .shadow(color: group.color.opacity(0.5), radius: 4, x: 0, y: 2)
                
                Text(group.name)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(
                        isSelected ?
                        LinearGradient(
                            colors: [group.color, group.color.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color.clear, Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .opacity(isSelected ? 0 : 1)
            )
            .overlay(
                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: isSelected ?
                                [Color.white.opacity(0.3), Color.white.opacity(0.1)] :
                                [Color.primary.opacity(0.15), Color.primary.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: isSelected ? group.color.opacity(0.4) : Color.black.opacity(0.05),
                radius: isSelected ? 8 : 4,
                x: 0,
                y: isSelected ? 4 : 2
            )
            .opacity(draggedGroup?.id == group.id ? 0.5 : 1.0)
        }
        .buttonStyle(.plain)
        .onDrag {
            self.draggedGroup = group
            return NSItemProvider(object: group.id.uuidString as NSString)
        }
        .onDrop(of: [.text], delegate: TrainingGroupDropDelegate(
            group: group,
            draggedGroup: $draggedGroup,
            groupViewModel: groupViewModel
        ))
    }
}

// MARK: - Drop Delegate for Training Group Tabs
struct TrainingGroupDropDelegate: DropDelegate {
    let group: TrainingGroup
    @Binding var draggedGroup: TrainingGroup?
    @ObservedObject var groupViewModel: TrainingGroupViewModel
    
    func performDrop(info: DropInfo) -> Bool {
        draggedGroup = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedGroup = draggedGroup else { return }
        guard draggedGroup.id != group.id else { return }
        
        // Find indices
        guard let fromIndex = groupViewModel.groups.firstIndex(where: { $0.id == draggedGroup.id }),
              let toIndex = groupViewModel.groups.firstIndex(where: { $0.id == group.id }) else {
            return
        }
        
        // Perform the move
        withAnimation(.default) {
            groupViewModel.groups.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
            groupViewModel.saveGroups()
        }
    }
}
