import Foundation

struct Exercise: Identifiable, Codable {
    var id: UUID
    var name: String
    var sets: Int
    var reps: Int
    var weight: Double
    var notes: String
    var imagePath: String?
    
    init(id: UUID = UUID(), name: String = "", sets: Int = 0, reps: Int = 0, weight: Double = 0.0, notes: String = "", imagePath: String? = nil) {
        self.id = id
        self.name = name
        self.sets = sets
        self.reps = reps
        self.weight = weight
        self.notes = notes
        self.imagePath = imagePath
    }
}

