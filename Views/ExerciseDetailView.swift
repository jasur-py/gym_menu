import SwiftUI
import PhotosUI

struct ExerciseDetailView: View {
    @ObservedObject var viewModel: ExerciseDetailViewModel
    @ObservedObject var settingsService = SettingsService.shared
    @Environment(\.dismiss) var dismiss
    @FocusState private var isFocused: Bool
    @State private var showingDeleteConfirmation = false
    var onDelete: ((Exercise) -> Void)?
    
    var body: some View {
        Form {
            Section(header: Text("Exercise Details")) {
                TextField("Exercise Name", text: $viewModel.exercise.name)
                    .focused($isFocused)
            }
            
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
                                    get: { exerciseSet.reps },
                                    set: { newValue in
                                        viewModel.exercise.sets[index].reps = newValue
                                    }
                                ), in: 0...100) {
                                    Text("\(exerciseSet.reps)")
                                }
                            }
                            
                            HStack {
                                Text("Weight (\(settingsService.weightUnit.rawValue))")
                                Spacer()
                                TextField("0.0", value: Binding(
                                    get: { exerciseSet.weight },
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
                }
            }
            
            Section(header: Text("Notes")) {
                TextEditor(text: $viewModel.exercise.notes)
                    .frame(minHeight: 100)
            }
            
            Section(header: Text("Image")) {
                PhotosPicker(selection: $viewModel.selectedPhoto, matching: .images) {
                    HStack {
                        Image(systemName: "photo")
                        Text("Select Photo")
                    }
                }
                .onChange(of: viewModel.selectedPhoto) { _ in
                    viewModel.handlePhotoSelection()
                }
                
                if viewModel.loadedImage != nil || viewModel.exercise.imagePath != nil {
                    CollapsibleImageView(
                        image: viewModel.loadedImage,
                        imagePath: viewModel.exercise.imagePath
                    )
                    
                    Button(role: .destructive, action: {
                        viewModel.removeImage()
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Remove Image")
                        }
                    }
                }
            }
        }
        .navigationTitle(viewModel.isNewExercise ? "New Exercise" : "Edit Exercise")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
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
}
