import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsService = SettingsService.shared
    @Environment(\.dismiss) var dismiss
    
    let predefinedColors: [Color] = [
        Color(.systemBackground),
        Color(.systemGray6),
        Color.blue.opacity(0.1),
        Color.green.opacity(0.1),
        Color.purple.opacity(0.1),
        Color.orange.opacity(0.1),
        Color.red.opacity(0.1),
        Color.yellow.opacity(0.1)
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $settingsService.appearanceMode) {
                        ForEach(AppearanceMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Weight Unit")) {
                    Picker("Weight Unit", selection: $settingsService.weightUnit) {
                        ForEach(WeightUnit.allCases, id: \.self) { unit in
                            Text(unit.displayName).tag(unit)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Background Color")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 15) {
                        ForEach(Array(predefinedColors.enumerated()), id: \.offset) { index, color in
                            Button(action: {
                                withAnimation {
                                    settingsService.backgroundColor = color
                                }
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(color)
                                        .frame(width: 60, height: 60)
                                    
                                    if isColorSelected(color, currentColor: settingsService.backgroundColor) {
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.blue, lineWidth: 3)
                                            .frame(width: 60, height: 60)
                                        
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                            .font(.title3)
                                            .fontWeight(.bold)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func isColorSelected(_ color: Color, currentColor: Color) -> Bool {
        let uiColor1 = UIColor(color)
        let uiColor2 = UIColor(currentColor)
        
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        uiColor1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        uiColor2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return abs(r1 - r2) < 0.01 && abs(g1 - g2) < 0.01 && abs(b1 - b2) < 0.01 && abs(a1 - a2) < 0.01
    }
}

