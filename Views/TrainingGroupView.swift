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
                            HStack(spacing: 20) {
                                // Edit button - MUST be visible (blue pencil icon)
                                Button(action: {
                                    editingGroup = group
                                }) {
                                    Image(systemName: "pencil")
                                        .font(.title3)
                                        .foregroundColor(.blue)
                                        .frame(width: 44, height: 44)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                
                                // Delete button (red trash icon)
                                Button(action: {
                                    groupToDelete = group
                                    showingDeleteAlert = true
                                }) {
                                    Image(systemName: "trash")
                                        .font(.title3)
                                        .foregroundColor(.red)
                                        .frame(width: 44, height: 44)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.trailing, 8)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onMove(perform: groupViewModel.moveGroup)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Training Groups")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddGroup = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
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
            Form {
                Section(header: Text("Group Name")) {
                    TextField("Group Name", text: $groupName)
                }
                
                Section(header: Text("Color")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 15) {
                        ForEach(Array(predefinedColors.enumerated()), id: \.offset) { index, color in
                            Button(action: {
                                selectedColor = color
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(color)
                                        .frame(width: 60, height: 60)
                                    
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
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("New Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newGroup = TrainingGroup(name: groupName, color: selectedColor)
                        groupViewModel.addGroup(newGroup)
                        dismiss()
                    }
                    .disabled(groupName.isEmpty)
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
            Form {
                Section(header: Text("Group Name")) {
                    TextField("Group Name", text: $groupName)
                }
                
                Section(header: Text("Color")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 15) {
                        ForEach(Array(predefinedColors.enumerated()), id: \.offset) { index, color in
                            Button(action: {
                                selectedColor = color
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(color)
                                        .frame(width: 60, height: 60)
                                    
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
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Edit Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        group.name = groupName
                        group.color = selectedColor
                        groupViewModel.updateGroup(group)
                        onSave?()
                        dismiss()
                    }
                    .disabled(groupName.isEmpty)
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

