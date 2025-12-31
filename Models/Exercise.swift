import Foundation

struct Exercise: Identifiable, Codable {
    var id: UUID
    var name: String
    var sets: [ExerciseSet]
    var notes: String
    var imagePaths: [String] // Changed to array for multiple images
    var groupIds: [UUID] // Multiple groups support (max 7)
    
    static let maxGroupsCount = 7
    
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
    
    // Legacy support for old single groupId
    var groupId: UUID? {
        get { groupIds.first }
        set {
            if let newValue = newValue {
                groupIds = [newValue]
            } else {
                groupIds = []
            }
        }
    }
    
    init(
        id: UUID = UUID(),
        name: String = "",
        sets: [ExerciseSet] = [],
        notes: String = "",
        imagePaths: [String] = [],
        groupIds: [UUID] = []
    ) {
        self.id = id
        self.name = name
        self.sets = sets
        self.notes = notes
        self.imagePaths = imagePaths
        self.groupIds = Array(groupIds.prefix(Exercise.maxGroupsCount)) // Enforce max 7
    }
}

