import SwiftUI
import UniformTypeIdentifiers

struct DayPlanningView: View {
    @StateObject private var groupViewModel = TrainingGroupViewModel()
    @State private var selectedMonth = Date()
    @State private var assignmentsByDateKey: [String: [UUID]] = [:]
    @State private var isErasing = false
    @State private var isDragTargeted = false
    
    private let calendar = Calendar.current
    private let dataService = DataPersistenceService.shared
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
    
    var body: some View {
        ZStack {
            Color(hex: "636e72")
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    monthHeader
                    
                    calendarGrid
                        .padding(.horizontal, 16)
                    
                    groupLegend
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                }
                .padding(.top, 20)
            }
        }
        .navigationTitle("Day Planning")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            groupViewModel.loadGroups()
            assignmentsByDateKey = dataService.loadDaySchedule()
        }
    }
    
    private var monthHeader: some View {
        HStack(spacing: 12) {
            Button(action: { changeMonth(by: -1) }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text(currentMonthYear)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: { changeMonth(by: 1) }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
    }
    
    private var calendarGrid: some View {
        VStack(spacing: 12) {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                        .frame(maxWidth: .infinity)
                }
            }
            
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(datesForCurrentMonth.indices, id: \.self) { index in
                    if let date = datesForCurrentMonth[index] {
                        DayCell(
                            date: date,
                            assignments: assignmentsForDate(date),
                            isToday: calendar.isDateInToday(date),
                            onDrop: { groupId in
                                addGroup(groupId, to: date)
                            },
                            onTap: {
                                if isErasing {
                                    clearAssignments(for: date)
                                }
                            }
                        )
                    } else {
                        Color.clear
                            .frame(height: 48)
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(hex: "636e72"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
                    .opacity(0.25)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        LinearGradient(
                            colors: [Color.primary.opacity(0.2), Color.primary.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
        }
    }
    
    private var groupLegend: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Groups")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isErasing.toggle()
                    }
                }) {
                    Image(systemName: "eraser")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isErasing ? .white : .white.opacity(0.8))
                        .frame(width: 30, height: 30)
                        .background(isErasing ? Color.red.opacity(0.8) : Color.white.opacity(0.12))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            
            let visibleGroups = groupViewModel.groups.filter { $0.name != "All Exercises" }
            
            if visibleGroups.isEmpty {
                Text("Create a group to start planning.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.75))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color.white.opacity(0.12))
                    .cornerRadius(14)
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(visibleGroups) { group in
                        HStack {
                            Text(group.name)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "hand.draw.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(group.color.opacity(0.9))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: group.color.opacity(0.25), radius: 6, x: 0, y: 4)
                        .onDrag {
                            return NSItemProvider(object: group.id.uuidString as NSString)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(hex: "636e72"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
                .opacity(0.25)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    LinearGradient(
                        colors: [Color.primary.opacity(0.2), Color.primary.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
    }
    
    private var currentMonthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedMonth)
    }
    
    private var weekdaySymbols: [String] {
        let symbols = calendar.shortWeekdaySymbols
        let firstWeekdayIndex = calendar.firstWeekday - 1
        return Array(symbols[firstWeekdayIndex...] + symbols[..<firstWeekdayIndex])
    }
    
    private var datesForCurrentMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedMonth),
              let range = calendar.range(of: .day, in: .month, for: selectedMonth) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: monthInterval.start)
        let leadingEmptyDays = (firstWeekday - calendar.firstWeekday + 7) % 7
        
        var dates: [Date?] = Array(repeating: nil, count: leadingEmptyDays)
        dates += range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: monthInterval.start)
        }
        
        let trailingEmptyDays = (7 - (dates.count % 7)) % 7
        if trailingEmptyDays > 0 {
            dates += Array(repeating: nil, count: trailingEmptyDays)
        }
        
        return dates
    }
    
    private func changeMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: selectedMonth) {
            selectedMonth = newDate
        }
    }
    
    private func assignmentsForDate(_ date: Date) -> [TrainingGroup] {
        let key = dateKey(for: date)
        guard let groupIds = assignmentsByDateKey[key] else { return [] }
        return groupViewModel.groups.filter { groupIds.contains($0.id) }
    }
    
    private func addGroup(_ groupId: UUID, to date: Date) {
        let key = dateKey(for: date)
        var groups = assignmentsByDateKey[key] ?? []
        if !groups.contains(groupId) {
            groups.append(groupId)
            assignmentsByDateKey[key] = groups
            dataService.saveDaySchedule(assignmentsByDateKey)
        }
    }
    
    private func clearAssignments(for date: Date) {
        let key = dateKey(for: date)
        if assignmentsByDateKey[key] != nil {
            assignmentsByDateKey[key] = nil
            dataService.saveDaySchedule(assignmentsByDateKey)
        }
    }
    
    private func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

private struct DayCell: View {
    let date: Date
    let assignments: [TrainingGroup]
    let isToday: Bool
    let onDrop: (UUID) -> Void
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 6) {
            Text(dayNumber)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if !assignments.isEmpty {
                HStack(spacing: 4) {
                    ForEach(displayedAssignments) { group in
                        Circle()
                            .fill(group.color)
                            .frame(width: 8, height: 8)
                    }
                    
                    if overflowCount > 0 {
                        Text("+\(overflowCount)")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Spacer(minLength: 8)
            }
        }
        .padding(8)
        .frame(height: 52)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isToday ? Color(hex: "dfe6e9") : Color.white.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isToday ? Color.white.opacity(0.5) : Color.white.opacity(0.2), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .onDrop(of: [UTType.text], isTargeted: nil) { providers in
            guard let provider = providers.first else { return false }
            provider.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { item, _ in
                if let data = item as? Data,
                   let string = String(data: data, encoding: .utf8),
                   let uuid = UUID(uuidString: string) {
                    DispatchQueue.main.async {
                        onDrop(uuid)
                    }
                } else if let string = item as? String,
                          let uuid = UUID(uuidString: string) {
                    DispatchQueue.main.async {
                        onDrop(uuid)
                    }
                }
            }
            return true
        }
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var displayedAssignments: [TrainingGroup] {
        Array(assignments.prefix(3))
    }
    
    private var overflowCount: Int {
        max(assignments.count - 3, 0)
    }
}
