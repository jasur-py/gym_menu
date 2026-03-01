import Foundation
import SwiftUI
import os.log

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.jasur.GymPlanner", category: "DataPersistence")

class DataPersistenceService {
    static let shared = DataPersistenceService()
    
    private let fileName = "exercises.json"
    private let groupsFileName = "training_groups.json"
    private let scheduleFileName = "day_schedule.json"
    
    private init() {}
    
    private var fileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent(fileName)
    }
    
    private var groupsFileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent(groupsFileName)
    }
    
    private var scheduleFileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent(scheduleFileName)
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
            logger.error("Failed to load exercises: \(error.localizedDescription)")
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
            logger.error("Failed to save exercises: \(error.localizedDescription)")
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
            logger.error("Failed to load training groups: \(error.localizedDescription)")
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
            logger.error("Failed to save training groups: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Day Planning Schedule Persistence
    
    func loadDaySchedule() -> [String: [UUID]] {
        guard FileManager.default.fileExists(atPath: scheduleFileURL.path) else {
            return [:]
        }
        
        do {
            let data = try Data(contentsOf: scheduleFileURL)
            let decoder = JSONDecoder()
            let schedule = try decoder.decode([String: [UUID]].self, from: data)
            return schedule
        } catch {
            logger.error("Failed to load day schedule: \(error.localizedDescription)")
            return [:]
        }
    }
    
    func saveDaySchedule(_ schedule: [String: [UUID]]) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(schedule)
            try data.write(to: scheduleFileURL)
        } catch {
            logger.error("Failed to save day schedule: \(error.localizedDescription)")
        }
    }
}
