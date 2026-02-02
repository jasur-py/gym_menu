import Foundation
import SwiftUI
import Combine

@MainActor
class ExerciseListViewModel: ObservableObject {
    @Published var exercises: [Exercise] = []
    @Published var selectedGroupId: UUID? = nil
    @Published var groupViewModel: TrainingGroupViewModel?
    
    private let dataService = DataPersistenceService.shared
    
    init() {
        loadExercises()
    }
    
    func loadExercises() {
        exercises = dataService.loadExercises()
    }
    
    var filteredExercises: [Exercise] {
        let filtered: [Exercise]
        
        if let selectedGroupId = selectedGroupId {
            // Show exercises that contain the selected group
            filtered = exercises.filter { $0.groupIds.contains(selectedGroupId) }
        } else {
            // Show ALL exercises when "All Exercises" is selected
            filtered = exercises
        }
        
        // Sort by the current group's exerciseOrder
        return sortExercises(filtered, forGroupId: selectedGroupId)
    }
    
    private func sortExercises(_ exercises: [Exercise], forGroupId groupId: UUID?) -> [Exercise] {
        guard let groupViewModel = groupViewModel else {
            return exercises
        }
        
        // Get the order array for the current group
        let group: TrainingGroup?
        if let groupId = groupId {
            group = groupViewModel.getGroup(by: groupId)
        } else {
            // "All Exercises" tab - use the first group (which is "All Exercises")
            group = groupViewModel.groups.first
        }
        
        guard let exerciseOrder = group?.exerciseOrder, !exerciseOrder.isEmpty else {
            return exercises
        }
        
        // Sort exercises based on the order array
        return exercises.sorted { ex1, ex2 in
            let index1 = exerciseOrder.firstIndex(of: ex1.id) ?? Int.max
            let index2 = exerciseOrder.firstIndex(of: ex2.id) ?? Int.max
            return index1 < index2
        }
    }
    
    func saveExercises() {
        dataService.saveExercises(exercises)
        NotificationCenter.default.post(name: .exercisesUpdated, object: nil)
    }
    
    func addExercise(_ exercise: Exercise) {
        exercises.append(exercise)
        saveExercises()
        
        // Add new exercise to the bottom of the current group's order
        if let groupViewModel = groupViewModel {
            // Add to "All Exercises" group order
            if var allExercisesGroup = groupViewModel.groups.first {
                if !allExercisesGroup.exerciseOrder.contains(exercise.id) {
                    allExercisesGroup.exerciseOrder.append(exercise.id)
                    groupViewModel.updateGroup(allExercisesGroup)
                }
            }
            
            // Add to each assigned group's order
            for groupId in exercise.groupIds {
                if var group = groupViewModel.getGroup(by: groupId) {
                    if !group.exerciseOrder.contains(exercise.id) {
                        group.exerciseOrder.append(exercise.id)
                        groupViewModel.updateGroup(group)
                    }
                }
            }
        }
    }
    
    func updateExercise(_ exercise: Exercise) {
        if let index = exercises.firstIndex(where: { $0.id == exercise.id }) {
            let oldExercise = exercises[index]
            exercises[index] = exercise
            saveExercises()
            
            // Update group orders if group assignments changed
            if let groupViewModel = groupViewModel {
                let oldGroupIds = Set(oldExercise.groupIds)
                let newGroupIds = Set(exercise.groupIds)
                
                // Add to newly assigned groups
                let addedGroupIds = newGroupIds.subtracting(oldGroupIds)
                for groupId in addedGroupIds {
                    if var group = groupViewModel.getGroup(by: groupId) {
                        if !group.exerciseOrder.contains(exercise.id) {
                            group.exerciseOrder.append(exercise.id)
                            groupViewModel.updateGroup(group)
                        }
                    }
                }
                
                // Remove from unassigned groups
                let removedGroupIds = oldGroupIds.subtracting(newGroupIds)
                for groupId in removedGroupIds {
                    if var group = groupViewModel.getGroup(by: groupId) {
                        group.exerciseOrder.removeAll { $0 == exercise.id }
                        groupViewModel.updateGroup(group)
                    }
                }
            }
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
            
            // Remove from all group orders
            if let groupViewModel = groupViewModel {
                for i in 0..<groupViewModel.groups.count {
                    groupViewModel.groups[i].exerciseOrder.removeAll { $0 == exercise.id }
                }
                groupViewModel.saveGroups()
            }
        }
    }
    
    // Move exercise within the current group's order
    func moveExercise(from source: IndexSet, to destination: Int) {
        guard let groupViewModel = groupViewModel else { return }
        
        // Determine which group we're currently viewing
        let group: TrainingGroup?
        if let selectedGroupId = selectedGroupId {
            group = groupViewModel.getGroup(by: selectedGroupId)
        } else {
            // "All Exercises" tab
            group = groupViewModel.groups.first
        }
        
        guard var currentGroup = group else { return }
        
        // Get the filtered exercises in current display order
        var orderedExercises = filteredExercises
        
        // Perform the move in the array
        orderedExercises.move(fromOffsets: source, toOffset: destination)
        
        // Update the group's exerciseOrder to reflect the new order
        currentGroup.exerciseOrder = orderedExercises.map { $0.id }
        
        // Save the updated group
        groupViewModel.updateGroup(currentGroup)
    }
}

extension Notification.Name {
    static let exercisesUpdated = Notification.Name("exercisesUpdated")
}
