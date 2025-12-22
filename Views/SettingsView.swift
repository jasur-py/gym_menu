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
                                settingsService.backgroundColor = color
                            }) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(color)
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(settingsService.backgroundColor == color ? Color.blue : Color.clear, lineWidth: 3)
                                    )
                            }
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
}

