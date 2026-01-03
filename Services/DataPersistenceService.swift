import Foundation
import SwiftUI

class DataPersistenceService {
    static let shared = DataPersistenceService()
    
    private let fileName = "exercises.json"
    private let groupsFileName = "training_groups.json"
    
    private init() {}
    
    private var fileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent(fileName)
    }
    
    private var groupsFileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent(groupsFileName)
    }
    
    func loadExercises() -> [Exercise] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let exercises = try decoder.decode([Exercise].self, from: data)
            return exercises
        } catch {
            print("Error loading exercises: \(error.localizedDescription)")
            return []
        }
    }
    
    func saveExercises(_ exercises: [Exercise]) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(exercises)
            try data.write(to: fileURL)
        } catch {
            print("Error saving exercises: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Training Groups Persistence
    
    func loadTrainingGroups() -> [TrainingGroup] {
        guard FileManager.default.fileExists(atPath: groupsFileURL.path) else {
            return []
        }
        
        do {
            let data = try Data(contentsOf: groupsFileURL)
            let decoder = JSONDecoder()
            let groups = try decoder.decode([TrainingGroup].self, from: data)
            return groups
        } catch {
            print("Error loading training groups: \(error.localizedDescription)")
            return []
        }
    }
    
    func saveTrainingGroups(_ groups: [TrainingGroup]) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(groups)
            try data.write(to: groupsFileURL)
        } catch {
            print("Error saving training groups: \(error.localizedDescription)")
        }
    }
}

