import Foundation

class DataPersistenceService {
    static let shared = DataPersistenceService()
    
    private let fileName = "exercises.json"
    
    private init() {}
    
    private var fileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent(fileName)
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
}

