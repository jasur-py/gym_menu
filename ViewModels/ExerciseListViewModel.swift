import Foundation
import SwiftUI

class ExerciseListViewModel: ObservableObject {
    @Published var exercises: [Exercise] = []
    
    private let dataService = DataPersistenceService.shared
    
    init() {
        loadExercises()
    }
    
    func loadExercises() {
        exercises = dataService.loadExercises()
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
            // Delete associated image if exists
            if let imagePath = exercise.imagePath {
                ImageStorageService.shared.deleteImage(at: imagePath)
            }
        }
        exercises.remove(atOffsets: offsets)
        saveExercises()
    }
    
    func deleteExercise(_ exercise: Exercise) {
        if let index = exercises.firstIndex(where: { $0.id == exercise.id }) {
            // Delete associated image if exists
            if let imagePath = exercise.imagePath {
                ImageStorageService.shared.deleteImage(at: imagePath)
            }
            exercises.remove(at: index)
            saveExercises()
        }
    }
}

