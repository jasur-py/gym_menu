import Foundation

struct Exercise: Identifiable, Codable {
    var id: UUID
    var name: String
    var sets: [ExerciseSet]
    var notes: String
    var imagePaths: [String] // Changed to array for multiple images
    var groupId: UUID? // Changed from groupName to groupId for proper linking
    
    // Legacy support for old single imagePath
    var imagePath: String? {
        get { imagePaths.first }
        set {
            if let newValue = newValue {
                imagePaths = [newValue]
            } else {
                imagePaths = []
            }
        }
    }
    
    init(
        id: UUID = UUID(),
        name: String = "",
        sets: [ExerciseSet] = [],
        notes: String = "",
        imagePaths: [String] = [],
        groupId: UUID? = nil
    ) {
        self.id = id
        self.name = name
        self.sets = sets
        self.notes = notes
        self.imagePaths = imagePaths
        self.groupId = groupId
    }
}

