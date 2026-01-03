import Foundation
import SwiftUI
import UIKit

struct TrainingGroup: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var colorData: [Double] // [red, green, blue, alpha]
    var exerciseOrder: [UUID] // NEW: Store custom order of exercises per group
    
    var color: Color {
        get {
            if colorData.count >= 4 {
                return Color(
                    red: colorData[0],
                    green: colorData[1],
                    blue: colorData[2],
                    opacity: colorData[3]
                )
            }
            return Color.blue
        }
        set {
            let uiColor = UIColor(newValue)
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            
            if uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
                colorData = [Double(red), Double(green), Double(blue), Double(alpha)]
            } else if let components = uiColor.cgColor.components {
                if components.count >= 4 {
                    colorData = [Double(components[0]), Double(components[1]), Double(components[2]), Double(components[3])]
                } else if components.count >= 3 {
                    colorData = [Double(components[0]), Double(components[1]), Double(components[2]), 1.0]
                } else {
                    colorData = [0.0, 0.48, 1.0, 1.0] // Default blue
                }
            } else {
                colorData = [0.0, 0.48, 1.0, 1.0] // Default blue
            }
        }
    }
    
    init(id: UUID = UUID(), name: String = "", color: Color = .blue, exerciseOrder: [UUID] = []) {
        self.id = id
        self.name = name
        self.exerciseOrder = exerciseOrder
        // Initialize colorData by setting color
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        if uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            self.colorData = [Double(red), Double(green), Double(blue), Double(alpha)]
        } else if let components = uiColor.cgColor.components, components.count >= 3 {
            self.colorData = components.count >= 4 
                ? [Double(components[0]), Double(components[1]), Double(components[2]), Double(components[3])]
                : [Double(components[0]), Double(components[1]), Double(components[2]), 1.0]
        } else {
            self.colorData = [0.0, 0.48, 1.0, 1.0] // Default blue
        }
    }
}

