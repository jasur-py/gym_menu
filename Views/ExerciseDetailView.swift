import SwiftUI
import PhotosUI

struct ExerciseDetailView: View {
    @ObservedObject var viewModel: ExerciseDetailViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var isFocused: Bool
    
    var body: some View {
        Form {
            Section(header: Text("Exercise Details")) {
                TextField("Exercise Name", text: $viewModel.exercise.name)
                    .focused($isFocused)
                
                HStack {
                    Text("Sets")
                    Spacer()
                    Stepper(value: $viewModel.exercise.sets, in: 0...100) {
                        Text("\(viewModel.exercise.sets)")
                    }
                }
                
                HStack {
                    Text("Reps")
                    Spacer()
                    Stepper(value: $viewModel.exercise.reps, in: 0...100) {
                        Text("\(viewModel.exercise.reps)")
                    }
                }
                
                HStack {
                    Text("Weight (kg)")
                    Spacer()
                    TextField("0.0", value: $viewModel.exercise.weight, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
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
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    viewModel.saveExercise()
                    dismiss()
                }
                .disabled(viewModel.exercise.name.isEmpty)
            }
        }
    }
}

