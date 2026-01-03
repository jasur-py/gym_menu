import Foundation
import SwiftUI
import Combine

@MainActor
class TrainingGroupViewModel: ObservableObject {
    @Published var groups: [TrainingGroup] = []
    
    private let dataService = DataPersistenceService.shared
    
    init() {
        loadGroups()
    }
    
    func loadGroups() {
        groups = dataService.loadTrainingGroups()
        // Ensure "All Exercises" group exists
        if !groups.contains(where: { $0.name == "All Exercises" }) {
            // Add "All Exercises" at the beginning if it doesn't exist
            groups.insert(TrainingGroup(name: "All Exercises", color: .blue), at: 0)
            saveGroups()
        }
    }
    
    func saveGroups() {
        dataService.saveTrainingGroups(groups)
    }
    
    func addGroup(_ group: TrainingGroup) {
        groups.append(group)
        saveGroups()
    }
    
    func updateGroup(_ group: TrainingGroup) {
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            groups[index] = group
            saveGroups()
        }
    }
    
    func deleteGroup(_ group: TrainingGroup, exerciseViewModel: ExerciseListViewModel? = nil) {
        // Don't allow deleting "All Exercises" group
        if group.name == "All Exercises" {
            return
        }
        
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            // Remove this group from exercises that contain it
            if let exerciseViewModel = exerciseViewModel {
                for i in 0..<exerciseViewModel.exercises.count {
                    exerciseViewModel.exercises[i].groupIds.removeAll { $0 == group.id }
                }
                exerciseViewModel.saveExercises()
            }
            
            groups.remove(at: index)
            saveGroups()
        }
    }
    
    func getGroup(by id: UUID?) -> TrainingGroup? {
        guard let id = id else { return nil }
        return groups.first(where: { $0.id == id })
    }
    
    // Initialize exercise order for a group with all exercises that belong to it
    func initializeExerciseOrder(for group: TrainingGroup, with exercises: [Exercise]) {
        var updatedGroup = group
        
        if group.name == "All Exercises" {
            // Add all exercises to "All Exercises" order
            let allExerciseIds = exercises.map { $0.id }
            for exerciseId in allExerciseIds {
                if !updatedGroup.exerciseOrder.contains(exerciseId) {
                    updatedGroup.exerciseOrder.append(exerciseId)
                }
            }
        } else {
            // Add only exercises that contain this group
            let groupExercises = exercises.filter { $0.groupIds.contains(group.id) }
            for exercise in groupExercises {
                if !updatedGroup.exerciseOrder.contains(exercise.id) {
                    updatedGroup.exerciseOrder.append(exercise.id)
                }
            }
        }
        
        updateGroup(updatedGroup)
    }
    
    // Move training group to reorder them
    func moveGroup(from source: IndexSet, to destination: Int) {
        groups.move(fromOffsets: source, toOffset: destination)
        saveGroups()
    }
}

