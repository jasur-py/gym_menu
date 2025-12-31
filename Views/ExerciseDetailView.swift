import SwiftUI
import PhotosUI
import UIKit

struct ExerciseDetailView: View {
    @ObservedObject var viewModel: ExerciseDetailViewModel
    @ObservedObject var settingsService = SettingsService.shared
    @Environment(\.dismiss) var dismiss
    @FocusState private var isFocused: Bool
    @State private var showingDeleteConfirmation = false
    var onDelete: ((Exercise) -> Void)?
    
    var body: some View {
        Form {
            detailsSection
            groupsSection
            setsSection
            notesSection
            imageSection
        }
        .navigationTitle(viewModel.isNewExercise ? "New Exercise" : "Edit Exercise")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarLeadingContent
            toolbarTrailingContent
        }
        .alert("Delete Exercise", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete?(viewModel.exercise)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete \"\(viewModel.exercise.name)\"? This action cannot be undone.")
        }
    }
    
    private var detailsSection: some View {
        Section(header: Text("Exercise Details")) {
            TextField("Exercise Name", text: $viewModel.exercise.name)
                .focused($isFocused)
        }
    }
    
    private var groupsSection: some View {
        Section(header: HStack {
            Text("Training Groups")
            Spacer()
            Text("\(viewModel.exercise.groupIds.count)/\(Exercise.maxGroupsCount)")
                .font(.caption)
                .foregroundColor(.secondary)
        }) {
            ForEach(viewModel.trainingGroupViewModel.groups.filter { $0.name != "All Exercises" }) { group in
                HStack {
                    Button(action: {
                        toggleGroupSelection(group.id)
                    }) {
                        HStack {
                            Image(systemName: viewModel.exercise.groupIds.contains(group.id) ? "checkmark.square.fill" : "square")
                                .foregroundColor(viewModel.exercise.groupIds.contains(group.id) ? group.color : .gray)
                                .font(.title3)
                            
                            Circle()
                                .fill(group.color)
                                .frame(width: 12, height: 12)
                            
                            Text(group.name)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            
            if viewModel.exercise.groupIds.count >= Exercise.maxGroupsCount {
                Text("Maximum \(Exercise.maxGroupsCount) groups reached")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 4)
            }
        }
    }
    
    private func toggleGroupSelection(_ groupId: UUID) {
        if viewModel.exercise.groupIds.contains(groupId) {
            viewModel.exercise.groupIds.removeAll { $0 == groupId }
        } else {
            if viewModel.exercise.groupIds.count < Exercise.maxGroupsCount {
                viewModel.exercise.groupIds.append(groupId)
            }
        }
    }
    
    private var setsSection: some View {
        Section(header: HStack {
            Text("Sets")
            Spacer()
            Button(action: {
                viewModel.addSet()
            }) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.blue)
            }
        }) {
            if viewModel.exercise.sets.isEmpty {
                Text("No sets added. Tap + to add a set.")
                    .foregroundColor(.secondary)
                    .font(.caption)
            } else {
                ForEach(Array(viewModel.exercise.sets.enumerated()), id: \.element.id) { index, exerciseSet in
                    setRow(index: index, set: exerciseSet)
                }
            }
        }
    }
    
    private func setRow(index: Int, set: ExerciseSet) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("Set \(index + 1)")
                    .font(.headline)
                Spacer()
                Button(role: .destructive, action: {
                    viewModel.removeSet(at: index)
                }) {
                    Image(systemName: "trash")
                        .font(.caption)
                }
            }
            
            HStack {
                Text("Reps")
                Spacer()
                Stepper(value: Binding(
                    get: { set.reps },
                    set: { newValue in
                        viewModel.exercise.sets[index].reps = newValue
                    }
                ), in: 0...100) {
                    Text("\(set.reps)")
                }
            }
            
            HStack {
                Text("Weight (\(settingsService.weightUnit.rawValue))")
                Spacer()
                TextField("0.0", value: Binding(
                    get: { set.weight },
                    set: { newValue in
                        viewModel.exercise.sets[index].weight = newValue
                    }
                ), format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 100)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var notesSection: some View {
        Section(header: Text("Notes")) {
            TextEditor(text: $viewModel.exercise.notes)
                .frame(minHeight: 100)
        }
    }
    
    private var imageSection: some View {
        Section(header: Text("Images")) {
            PhotosPicker(selection: $viewModel.selectedPhotos, maxSelectionCount: 10, matching: .images) {
                HStack {
                    Image(systemName: "photo.on.rectangle.angled")
                    Text("Select Photos")
                }
            }
            .onChange(of: viewModel.selectedPhotos) {
                viewModel.handlePhotoSelection()
            }
            
            if !viewModel.loadedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(spacing: 10) {
                        ForEach(Array(viewModel.loadedImages.enumerated()), id: \.offset) { index, image in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipped()
                                    .cornerRadius(8)
                                
                                Button(action: {
                                    viewModel.removeImage(at: index)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.red)
                                        .background(Color.white.opacity(0.7))
                                        .clipShape(Circle())
                                }
                                .padding(4)
                            }
                        }
                    }
                }
                .frame(height: 110)
                
                Button(role: .destructive, action: {
                    viewModel.removeAllImages()
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Remove All Images")
                    }
                }
            }
        }
    }
    
    private var toolbarLeadingContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel") {
                dismiss()
            }
        }
    }
    
    private var toolbarTrailingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            if !viewModel.isNewExercise, onDelete != nil {
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                }
            }
            Button("Save") {
                viewModel.saveExercise()
                dismiss()
            }
            .disabled(viewModel.exercise.name.isEmpty)
        }
    }
}
