import Foundation

struct Exercise: Identifiable, Codable {
    var id: UUID
    var name: String
    var sets: [ExerciseSet]
    var notes: String
    var imagePath: String?
    
    init(id: UUID = UUID(), name: String = "", sets: [ExerciseSet] = [], notes: String = "", imagePath: String? = nil) {
        self.id = id
        self.name = name
        self.sets = sets
        self.notes = notes
        self.imagePath = imagePath
    }
}

