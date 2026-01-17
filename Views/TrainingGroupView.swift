import SwiftUI

struct TrainingGroupView: View {
    @ObservedObject var groupViewModel: TrainingGroupViewModel
    @ObservedObject var exerciseViewModel: ExerciseListViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showingAddGroup = false
    @State private var editingGroup: TrainingGroup?
    @State private var groupToDelete: TrainingGroup?
    @State private var showingDeleteAlert = false
    
    let predefinedColors: [Color] = [
        Color.blue,
        Color.red,
        Color.green,
        Color.orange,
        Color.purple,
        Color.pink,
        Color.yellow,
        Color.cyan,
        Color.indigo,
        Color.mint
    ]
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                LinearGradient(
                    colors: [Color(hex: "3d7b8c"), Color(hex: "2c5f6f"), Color(hex: "234752")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                List {
                    ForEach(groupViewModel.groups) { group in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(group.color)
                                .frame(width: 20, height: 20)
                            
                            Text(group.name)
                                .font(.headline)
                            
                            Spacer()
                            
                            if group.name != "All Exercises" {
                                HStack(spacing: 12) {
                                    // Edit button - MUST be visible (blue pencil icon)
                                    Button(action: {
                                        editingGroup = group
                                    }) {
                                        Image(systemName: "pencil")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.blue)
                                            .frame(width: 32, height: 32)
                                            .background(
                                                Circle()
                                                    .fill(.ultraThinMaterial)
                                            )
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                                            )
                                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                                            .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)
                                    
                                    // Delete button (red trash icon)
                                    Button(action: {
                                        groupToDelete = group
                                        showingDeleteAlert = true
                                    }) {
                                        Image(systemName: "trash")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.red)
                                            .frame(width: 32, height: 32)
                                            .background(
                                                Circle()
                                                    .fill(.ultraThinMaterial)
                                            )
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                                            )
                                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                                            .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.trailing, 4)
                            }
                        }
                        .padding(.vertical, 6)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                                .padding(.vertical, 4)
                        )
                    }
                    .onMove(perform: groupViewModel.moveGroup)
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                
                VStack(spacing: 12) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                            .frame(width: 50, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color.primary.opacity(0.2), Color.primary.opacity(0.05)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1.5
                                            )
                                    )
                            )
                            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        showingAddGroup = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                            .frame(width: 50, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color.primary.opacity(0.2), Color.primary.opacity(0.05)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1.5
                                            )
                                    )
                            )
                            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.trailing, 16)
                .padding(.bottom, 24)
            }
            .navigationTitle("Training Groups")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddGroup) {
                AddGroupView(groupViewModel: groupViewModel)
            }
            .sheet(item: $editingGroup) { group in
                EditGroupView(
                    groupViewModel: groupViewModel,
                    group: group,
                    onSave: {
                        // Reload groups to ensure UI updates
                        groupViewModel.loadGroups()
                    }
                )
            }
            .alert("Delete Training Group", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {
                    groupToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let group = groupToDelete {
                        groupViewModel.deleteGroup(group, exerciseViewModel: exerciseViewModel)
                    }
                    groupToDelete = nil
                }
            } message: {
                if let group = groupToDelete {
                    Text("Are you sure you want to delete \"\(group.name)\"? All exercises in this group will be moved to \"All Exercises\".")
                }
            }
        }
    }
}

struct AddGroupView: View {
    @ObservedObject var groupViewModel: TrainingGroupViewModel
    @Environment(\.dismiss) var dismiss
    @State private var groupName = ""
    @State private var selectedColor = Color.blue
    
    let predefinedColors: [Color] = [
        Color.blue,
        Color.red,
        Color.green,
        Color.orange,
        Color.purple,
        Color.pink,
        Color.yellow,
        Color.cyan,
        Color.indigo,
        Color.mint
    ]
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                LinearGradient(
                    colors: [Color(hex: "3d7b8c"), Color(hex: "2c5f6f"), Color(hex: "234752")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        LiquidGlassSettingCard(
                            icon: "textformat",
                            title: "Group Name",
                            iconColor: .blue
                        ) {
                            TextField("Group Name", text: $groupName)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.ultraThinMaterial)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                                )
                        }
                        
                        LiquidGlassSettingCard(
                            icon: "paintpalette.fill",
                            title: "Color",
                            iconColor: .purple
                        ) {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 15) {
                                ForEach(Array(predefinedColors.enumerated()), id: \.offset) { index, color in
                                    Button(action: {
                                        selectedColor = color
                                    }) {
                                        ZStack {
                                            Circle()
                                                .fill(color)
                                                .frame(width: 60, height: 60)
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                                )
                                                .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
                                            
                                            if isColorSelected(color, currentColor: selectedColor) {
                                                Circle()
                                                    .stroke(Color.primary, lineWidth: 3)
                                                    .frame(width: 60, height: 60)
                                                
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.primary)
                                                    .font(.title3)
                                                    .fontWeight(.bold)
                                            }
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                }
                
                VStack(spacing: 12) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                            .frame(width: 50, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color.primary.opacity(0.2), Color.primary.opacity(0.05)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1.5
                                            )
                                    )
                            )
                            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        let newGroup = TrainingGroup(name: groupName, color: selectedColor)
                        groupViewModel.addGroup(newGroup)
                        dismiss()
                    }) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                            .frame(width: 50, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color.primary.opacity(0.2), Color.primary.opacity(0.05)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1.5
                                            )
                                    )
                            )
                            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                    .disabled(groupName.isEmpty)
                    .opacity(groupName.isEmpty ? 0.4 : 1)
                }
                .padding(.trailing, 16)
                .padding(.bottom, 24)
            }
            .navigationTitle("New Group")
            .navigationBarTitleDisplayMode(.inline)
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

struct EditGroupView: View {
    @ObservedObject var groupViewModel: TrainingGroupViewModel
    @State var group: TrainingGroup
    @Environment(\.dismiss) var dismiss
    @State private var groupName: String
    @State private var selectedColor: Color
    var onSave: (() -> Void)?
    
    let predefinedColors: [Color] = [
        Color.blue,
        Color.red,
        Color.green,
        Color.orange,
        Color.purple,
        Color.pink,
        Color.yellow,
        Color.cyan,
        Color.indigo,
        Color.mint
    ]
    
    init(groupViewModel: TrainingGroupViewModel, group: TrainingGroup, onSave: (() -> Void)? = nil) {
        self.groupViewModel = groupViewModel
        self._group = State(initialValue: group)
        self._groupName = State(initialValue: group.name)
        self._selectedColor = State(initialValue: group.color)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                LinearGradient(
                    colors: [Color(hex: "3d7b8c"), Color(hex: "2c5f6f"), Color(hex: "234752")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        LiquidGlassSettingCard(
                            icon: "textformat",
                            title: "Group Name",
                            iconColor: .blue
                        ) {
                            TextField("Group Name", text: $groupName)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.ultraThinMaterial)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                                )
                        }
                        
                        LiquidGlassSettingCard(
                            icon: "paintpalette.fill",
                            title: "Color",
                            iconColor: .purple
                        ) {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 15) {
                                ForEach(Array(predefinedColors.enumerated()), id: \.offset) { index, color in
                                    Button(action: {
                                        selectedColor = color
                                    }) {
                                        ZStack {
                                            Circle()
                                                .fill(color)
                                                .frame(width: 60, height: 60)
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                                )
                                                .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
                                            
                                            if isColorSelected(color, currentColor: selectedColor) {
                                                Circle()
                                                    .stroke(Color.primary, lineWidth: 3)
                                                    .frame(width: 60, height: 60)
                                                
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.primary)
                                                    .font(.title3)
                                                    .fontWeight(.bold)
                                            }
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                }
                
                VStack(spacing: 12) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                            .frame(width: 50, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color.primary.opacity(0.2), Color.primary.opacity(0.05)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1.5
                                            )
                                    )
                            )
                            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        group.name = groupName
                        group.color = selectedColor
                        groupViewModel.updateGroup(group)
                        onSave?()
                        dismiss()
                    }) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                            .frame(width: 50, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color.primary.opacity(0.2), Color.primary.opacity(0.05)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1.5
                                            )
                                    )
                            )
                            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                    .disabled(groupName.isEmpty)
                    .opacity(groupName.isEmpty ? 0.4 : 1)
                }
                .padding(.trailing, 16)
                .padding(.bottom, 24)
            }
            .navigationTitle("Edit Group")
            .navigationBarTitleDisplayMode(.inline)
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

