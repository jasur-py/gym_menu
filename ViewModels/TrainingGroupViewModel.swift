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
        // Ensure "All Exercises" group exists and is first
        if let allExercisesIndex = groups.firstIndex(where: { $0.name == "All Exercises" }) {
            // Move to front if not already first
            if allExercisesIndex != 0 {
                let allExercises = groups.remove(at: allExercisesIndex)
                groups.insert(allExercises, at: 0)
                saveGroups()
            }
        } else {
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
}

