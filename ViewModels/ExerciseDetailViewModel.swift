import Foundation
import SwiftUI
import Combine
import UIKit
import PhotosUI

class ExerciseDetailViewModel: ObservableObject {
    @Published var exercise: Exercise
    @Published var selectedPhotos: [PhotosPickerItem] = []
    @Published var loadedImages: [UIImage] = []
    @Published var trainingGroupViewModel = TrainingGroupViewModel()
    
    private let dataService = DataPersistenceService.shared
    private let imageService = ImageStorageService.shared
    private let onSave: (Exercise) -> Void
    
    var isNewExercise: Bool
    
    init(exercise: Exercise? = nil, onSave: @escaping (Exercise) -> Void) {
        self.onSave = onSave
        
        if let exercise = exercise {
            self.exercise = exercise
            self.isNewExercise = false
        } else {
            self.exercise = Exercise()
            self.isNewExercise = true
        }
        
        // Load existing images after all properties are initialized
        if !self.exercise.imagePaths.isEmpty {
            self.loadedImages = self.exercise.imagePaths.compactMap { path in
                imageService.loadImage(from: path)
            }
        }
    }
    
    func handlePhotoSelection() {
        guard !selectedPhotos.isEmpty else { return }
        
        Task {
            var newImagePaths: [String] = []
            var newImages: [UIImage] = []
            
            for photo in selectedPhotos {
                if let data = try? await photo.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    if let imagePath = imageService.saveImage(image) {
                        newImagePaths.append(imagePath)
                        newImages.append(image)
                    }
                }
            }
            
            await MainActor.run {
                exercise.imagePaths.append(contentsOf: newImagePaths)
                loadedImages.append(contentsOf: newImages)
                selectedPhotos = []
            }
        }
    }
    
    func saveExercise() {
        onSave(exercise)
    }
    
    func removeImage(at index: Int) {
        guard index < exercise.imagePaths.count else { return }
        let imagePath = exercise.imagePaths[index]
        imageService.deleteImage(at: imagePath)
        exercise.imagePaths.remove(at: index)
        if index < loadedImages.count {
            loadedImages.remove(at: index)
        }
    }
    
    func removeAllImages() {
        for imagePath in exercise.imagePaths {
            imageService.deleteImage(at: imagePath)
        }
        exercise.imagePaths = []
        loadedImages = []
    }
    
    func addSet() {
        exercise.sets.append(ExerciseSet())
    }
    
    func removeSet(at index: Int) {
        guard index < exercise.sets.count else { return }
        exercise.sets.remove(at: index)
    }
}
