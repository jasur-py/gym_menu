import Foundation
import SwiftUI
import Combine

@MainActor
class ExerciseListViewModel: ObservableObject {
    @Published var exercises: [Exercise] = []
    @Published var selectedGroupId: UUID? = nil
    
    private let dataService = DataPersistenceService.shared
    
    init() {
        loadExercises()
    }
    
    func loadExercises() {
        exercises = dataService.loadExercises()
    }
    
    var filteredExercises: [Exercise] {
        if let selectedGroupId = selectedGroupId {
            return exercises.filter { $0.groupId == selectedGroupId }
        }
        // Show ALL exercises when "All Exercises" is selected
        return exercises
    }
    
    func saveExercises() {
        dataService.saveExercises(exercises)
    }
    
    func addExercise(_ exercise: Exercise) {
        exercises.append(exercise)
        saveExercises()
    }
    
    func updateExercise(_ exercise: Exercise) {
        if let index = exercises.firstIndex(where: { $0.id == exercise.id }) {
            exercises[index] = exercise
            saveExercises()
        }
    }
    
    func deleteExercise(at offsets: IndexSet) {
        for index in offsets {
            let exercise = exercises[index]
            // Delete all associated images
            for imagePath in exercise.imagePaths {
                ImageStorageService.shared.deleteImage(at: imagePath)
            }
        }
        exercises.remove(atOffsets: offsets)
        saveExercises()
    }
    
    func deleteExercise(_ exercise: Exercise) {
        if let index = exercises.firstIndex(where: { $0.id == exercise.id }) {
            // Delete all associated images
            for imagePath in exercise.imagePaths {
                ImageStorageService.shared.deleteImage(at: imagePath)
            }
            exercises.remove(at: index)
            saveExercises()
        }
    }
}

