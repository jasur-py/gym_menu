import Foundation
import SwiftUI

enum WeightUnit: String, Codable, CaseIterable {
    case kg = "kg"
    case lb = "lb"
    
    var displayName: String {
        return rawValue.uppercased()
    }
    
    func convert(from value: Double, to targetUnit: WeightUnit) -> Double {
        if self == targetUnit {
            return value
        }
        
        // Convert to kg first, then to target unit
        let valueInKg = self == .lb ? value / 2.20462 : value
        return targetUnit == .lb ? valueInKg * 2.20462 : valueInKg
    }
}

class SettingsService: ObservableObject {
    static let shared = SettingsService()
    
    @Published var weightUnit: WeightUnit {
        didSet {
            saveSettings()
        }
    }
    
    @Published var backgroundColor: Color {
        didSet {
            saveBackgroundColor()
        }
    }
    
    private let settingsFileName = "settings.json"
    private let backgroundColorKey = "backgroundColor"
    
    private init() {
        // Load weight unit
        if let savedUnit = loadWeightUnit() {
            self.weightUnit = savedUnit
        } else {
            self.weightUnit = .kg
        }
        
        // Load background color
        self.backgroundColor = loadBackgroundColor()
    }
    
    private var settingsFileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent(settingsFileName)
    }
    
    private func loadWeightUnit() -> WeightUnit? {
        guard FileManager.default.fileExists(atPath: settingsFileURL.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: settingsFileURL)
            let decoder = JSONDecoder()
            let settings = try decoder.decode(SettingsData.self, from: data)
            return WeightUnit(rawValue: settings.weightUnit)
        } catch {
            print("Error loading settings: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func saveSettings() {
        let settings = SettingsData(weightUnit: weightUnit.rawValue)
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(settings)
            try data.write(to: settingsFileURL)
        } catch {
            print("Error saving settings: \(error.localizedDescription)")
        }
    }
    
    private func loadBackgroundColor() -> Color {
        if let colorData = UserDefaults.standard.data(forKey: backgroundColorKey),
           let components = try? JSONDecoder().decode([Double].self, from: colorData),
           components.count >= 4 {
            return Color(
                red: components[0],
                green: components[1],
                blue: components[2],
                opacity: components[3]
            )
        }
        return Color(.systemBackground)
    }
    
    private func saveBackgroundColor() {
        let uiColor = UIColor(backgroundColor)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let components = [Double(red), Double(green), Double(blue), Double(alpha)]
        if let data = try? JSONEncoder().encode(components) {
            UserDefaults.standard.set(data, forKey: backgroundColorKey)
        }
    }
}

private struct SettingsData: Codable {
    var weightUnit: String
}

