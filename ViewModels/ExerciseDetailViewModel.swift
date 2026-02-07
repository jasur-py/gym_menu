import Foundation
import SwiftUI
import Combine
import UIKit
import PhotosUI
import ImageIO

class ExerciseDetailViewModel: ObservableObject {
    @Published var exercise: Exercise
    @Published var selectedPhotos: [PhotosPickerItem] = []
    @Published var loadedImages: [UIImage] = []
    @Published var loadedImageData: [Data] = [] // Store original data for GIFs
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
        
        // Load existing images and data after all properties are initialized
        if !self.exercise.imagePaths.isEmpty {
            for path in self.exercise.imagePaths {
                if let imageData = imageService.loadImageData(from: path),
                   let image = UIImage(data: imageData) {
                    self.loadedImages.append(image)
                    self.loadedImageData.append(imageData)
                }
            }
        }
    }
    
    func handlePhotoSelection() {
        guard !selectedPhotos.isEmpty else { return }
        
        Task {
            var newImagePaths: [String] = []
            var newImages: [UIImage] = []
            var newImageData: [Data] = []
            
            for photo in selectedPhotos {
                if let data = try? await photo.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    // Detect file type
                    let fileExtension = data.isAnimatedGIF ? "gif" : "jpg"
                    
                    // Save original data to preserve GIF animation
                    if let imagePath = imageService.saveImageData(data, fileExtension: fileExtension) {
                        newImagePaths.append(imagePath)
                        newImages.append(image)
                        newImageData.append(data)
                    }
                }
            }
            
            await MainActor.run {
                exercise.imagePaths.append(contentsOf: newImagePaths)
                loadedImages.append(contentsOf: newImages)
                loadedImageData.append(contentsOf: newImageData)
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
        if index < loadedImageData.count {
            loadedImageData.remove(at: index)
        }
    }
    
    func removeAllImages() {
        for imagePath in exercise.imagePaths {
            imageService.deleteImage(at: imagePath)
        }
        exercise.imagePaths = []
        loadedImages = []
        loadedImageData = []
    }
    
    func addSet() {
        exercise.sets.append(ExerciseSet())
    }
    
    func removeSet(at index: Int) {
        guard index < exercise.sets.count else { return }
        exercise.sets.remove(at: index)
    }
}
