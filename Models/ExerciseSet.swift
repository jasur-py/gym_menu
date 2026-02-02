import Foundation

struct ExerciseSet: Identifiable, Codable {
    var id: UUID
    var reps: Int
    var weight: Double
    var lastLoggedAt: Date?
    var lastLoggedReps: Int
    var lastLoggedWeight: Double
    var lastLoggedWeightUnitRaw: String?
    var lastCompletedAt: Date?
    
    init(
        id: UUID = UUID(),
        reps: Int = 0,
        weight: Double = 0.0,
        lastLoggedAt: Date? = nil,
        lastLoggedReps: Int = 0,
        lastLoggedWeight: Double = 0.0,
        lastLoggedWeightUnitRaw: String? = nil,
        lastCompletedAt: Date? = nil
    ) {
        self.id = id
        self.reps = reps
        self.weight = weight
        self.lastLoggedAt = lastLoggedAt
        self.lastLoggedReps = lastLoggedReps
        self.lastLoggedWeight = lastLoggedWeight
        self.lastLoggedWeightUnitRaw = lastLoggedWeightUnitRaw
        self.lastCompletedAt = lastCompletedAt
    }
}

