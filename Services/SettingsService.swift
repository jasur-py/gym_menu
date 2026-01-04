import Foundation
import SwiftUI
import UIKit
import Combine

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

enum AppearanceMode: String, Codable, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil // Uses system default
        case .light:
            return .light
        case .dark:
            return .dark
        }
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
    
    @Published var appearanceMode: AppearanceMode {
        didSet {
            saveSettings()
        }
    }
    
    private let settingsFileName = "settings.json"
    private let backgroundColorKey = "backgroundColor"
    
    private var settingsFileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent(settingsFileName)
    }
    
    private init() {
        // Initialize with default values first
        self.weightUnit = .kg
        self.backgroundColor = Color(.systemBackground)
        self.appearanceMode = .system
        
        // Then load saved values
        let loadedSettings = Self.loadSettings(settingsFileURL: settingsFileURL)
        if let savedUnit = loadedSettings.weightUnit {
            self.weightUnit = savedUnit
        }
        if let savedAppearance = loadedSettings.appearanceMode {
            self.appearanceMode = savedAppearance
        }
        
        self.backgroundColor = Self.loadBackgroundColor(backgroundColorKey: backgroundColorKey)
    }
    
    private static func loadSettings(settingsFileURL: URL) -> (weightUnit: WeightUnit?, appearanceMode: AppearanceMode?) {
        guard FileManager.default.fileExists(atPath: settingsFileURL.path) else {
            return (nil, nil)
        }
        
        do {
            let data = try Data(contentsOf: settingsFileURL)
            let decoder = JSONDecoder()
            let settings = try decoder.decode(SettingsData.self, from: data)
            let weightUnit = WeightUnit(rawValue: settings.weightUnit)
            let appearanceMode = settings.appearanceMode.flatMap { AppearanceMode(rawValue: $0) }
            return (weightUnit, appearanceMode)
        } catch {
            print("Error loading settings: \(error.localizedDescription)")
            return (nil, nil)
        }
    }
    
    private func saveSettings() {
        let settings = SettingsData(weightUnit: weightUnit.rawValue, appearanceMode: appearanceMode.rawValue)
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(settings)
            try data.write(to: settingsFileURL)
        } catch {
            print("Error saving settings: \(error.localizedDescription)")
        }
    }
    
    private static func loadBackgroundColor(backgroundColorKey: String) -> Color {
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
        
        // Some colors (like system colors) might not support getRed, so we need to handle that
        if uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            let components = [Double(red), Double(green), Double(blue), Double(alpha)]
            if let data = try? JSONEncoder().encode(components) {
                UserDefaults.standard.set(data, forKey: backgroundColorKey)
            }
        } else {
            // Fallback: try to get RGB from CGColor
            if let cgColor = uiColor.cgColor.components, cgColor.count >= 4 {
                let components = [Double(cgColor[0]), Double(cgColor[1]), Double(cgColor[2]), Double(cgColor[3])]
                if let data = try? JSONEncoder().encode(components) {
                    UserDefaults.standard.set(data, forKey: backgroundColorKey)
                }
            }
        }
    }
}

private struct SettingsData: Codable {
    var weightUnit: String
    var appearanceMode: String?
}

