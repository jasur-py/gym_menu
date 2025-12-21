import Foundation
import SwiftUI
import PhotosUI

class ExerciseDetailViewModel: ObservableObject {
    @Published var exercise: Exercise
    @Published var selectedPhoto: PhotosPickerItem?
    @Published var loadedImage: UIImage?
    
    private let dataService = DataPersistenceService.shared
    private let imageService = ImageStorageService.shared
    private let onSave: (Exercise) -> Void
    
    var isNewExercise: Bool
    
    init(exercise: Exercise? = nil, onSave: @escaping (Exercise) -> Void) {
        if let exercise = exercise {
            self.exercise = exercise
            self.isNewExercise = false
            // Load existing image if available
            if let imagePath = exercise.imagePath {
                self.loadedImage = imageService.loadImage(from: imagePath)
            }
        } else {
            self.exercise = Exercise()
            self.isNewExercise = true
        }
        self.onSave = onSave
    }
    
    func handlePhotoSelection() {
        guard let selectedPhoto = selectedPhoto else { return }
        
        Task {
            if let data = try? await selectedPhoto.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    // Delete old image if exists
                    if let oldImagePath = exercise.imagePath {
                        imageService.deleteImage(at: oldImagePath)
                    }
                    
                    // Save new image
                    if let newImagePath = imageService.saveImage(image) {
                        exercise.imagePath = newImagePath
                        loadedImage = image
                    }
                }
            }
        }
    }
    
    func saveExercise() {
        onSave(exercise)
    }
    
    func removeImage() {
        if let imagePath = exercise.imagePath {
            imageService.deleteImage(at: imagePath)
            exercise.imagePath = nil
            loadedImage = nil
        }
    }
}

