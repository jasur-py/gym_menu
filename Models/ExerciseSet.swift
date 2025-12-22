import Foundation

struct ExerciseSet: Identifiable, Codable {
    var id: UUID
    var reps: Int
    var weight: Double
    
    init(id: UUID = UUID(), reps: Int = 0, weight: Double = 0.0) {
        self.id = id
        self.reps = reps
        self.weight = weight
    }
}

