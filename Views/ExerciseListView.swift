import SwiftUI
import UIKit
import UniformTypeIdentifiers

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
    @State private var draggedGroup: TrainingGroup?
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background image extending to toolbar area
            GeometryReader { geometry in
                ZStack {
                    // Background image with fallback to gradient
                    if let headerImage = UIImage(named: "HeaderBackground") {
                        Image(uiImage: headerImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: 200)
                            .clipped()
                    } else {
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geometry.size.width, height: 200)
                    }
                }
            }
            .frame(height: 200)
            .ignoresSafeArea(edges: .top)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            
        VStack(spacing: 0) {
            // Spacer for visual balance
            Spacer()
                .frame(height: 80)
            
            // Group tabs at the top
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(groupViewModel.groups) { group in
                        TrainingGroupTabButton(
                            group: group,
                            isSelected: (group.name == "All Exercises" && viewModel.selectedGroupId == nil) || 
                                      (group.name != "All Exercises" && viewModel.selectedGroupId == group.id),
                            onTap: {
                                withAnimation {
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
                .padding(.horizontal, 12)
                .frame(maxHeight: .infinity)
            }
            .frame(height: 50)
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
                    .onMove(perform: viewModel.moveExercise)
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(settingsService.backgroundColor.ignoresSafeArea())
                .scrollIndicators(.visible)
                .ignoresSafeArea(edges: .bottom)
                .safeAreaInset(edge: .top, spacing: 0) {
                    Color.clear.frame(height: 20)
                }
            
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
                ZStack {
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
                                    .foregroundColor(.primary)
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
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color(.systemGray6))
                            
                            CalendarView(selectedDate: $selectedDate)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .background(Color(.systemBackground))
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: -5)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            }
        }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.clear, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            // Connect groupViewModel to exerciseListViewModel for sorting
            viewModel.groupViewModel = groupViewModel
            
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
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack(spacing: 12) {
                    Button(action: {
                        showingGroups = true
                    }) {
                        Image(systemName: "folder")
                            .font(.title3)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                    }
                    
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape")
                            .font(.title3)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddExercise = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
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
                        exercise: Exercise(groupIds: viewModel.selectedGroupId != nil ? [viewModel.selectedGroupId!] : []),
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
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
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
        DatePicker(
            "Select Date",
            selection: $selectedDate,
            displayedComponents: [.date]
        )
        .datePickerStyle(.graphical)
        .labelsHidden()
        .frame(maxWidth: .infinity)
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
            .opacity(draggedGroup?.id == group.id ? 0.5 : 1.0)
        }
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
