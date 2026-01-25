import SwiftUI

struct NewMainView: View {
    // Get user's name from device (if available)
    @State private var userName: String = {
        // Get the user's device name
        let deviceName = UIDevice.current.name
        // If it's not empty, use it, otherwise use "User"
        return deviceName.isEmpty ? "User" : deviceName
    }()
    
    @State private var isSettingsOpen = false
    @State private var isSupplementsReminderOpen = false
    @ObservedObject var quoteService = QuoteService.shared
    @ObservedObject var settingsService = SettingsService.shared
    @State private var refreshTrigger = UUID()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background color
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Custom Header
                        customHeader
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        
                        // Workout Programs Section (flexible and responsive)
                        WorkoutProgramsSection(refreshTrigger: $refreshTrigger)
                            .padding(.top, 20)
                        
                        // Calendar Section
                        CalendarSection()
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        
                        supplementsReminderCard
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        
                        statsOverviewSection
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        
                        // Bottom spacing
                        Spacer()
                            .frame(height: 100)
                    }
                }
                
                // Quote Alert Overlay (slides down from top)
                if quoteService.shouldShowQuote {
                    VStack {
                        QuoteAlertView(
                            quote: quoteService.currentQuote,
                            onThumbsUp: {
                                withAnimation {
                                    quoteService.dismissWithThumbsUp()
                                }
                            },
                            onThumbsDown: {
                                withAnimation {
                                    quoteService.dismissWithThumbsDown()
                                }
                            }
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.horizontal, 20)
                        .padding(.top, 60)
                        
                        Spacer()
                    }
                    .zIndex(100)
                }
                
                // Settings Side Sheet Overlay
                if isSettingsOpen {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                isSettingsOpen = false
                            }
                        }
                    
                    SettingsSideSheet(isOpen: $isSettingsOpen)
                        .transition(.move(edge: .trailing))
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                // Refresh workout programs when view appears
                refreshTrigger = UUID()
            }
            .sheet(isPresented: $isSupplementsReminderOpen) {
                SupplementsReminderPlaceholderView()
            }
        }
    }
    
    // MARK: - Custom Header
    private var customHeader: some View {
        HStack(spacing: 12) {
            // Left side: Profile picture and greeting
            HStack(spacing: 12) {
                // Profile Picture (from Apple ID / System)
                profilePicture
                
                // Greeting and Name
                VStack(alignment: .leading, spacing: 2) {
                    Text("Welcome back!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text(userName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
            }
            
            Spacer()
            
            // Right side: Settings and Notifications buttons
            HStack(spacing: 12) {
                // Settings Button
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isSettingsOpen = true
                    }
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.black)
                        .clipShape(Circle())
                }
                
                // Notifications Button
                Button(action: {
                    settingsService.isNotificationsEnabled.toggle()
                    if settingsService.isNotificationsEnabled {
                        settingsService.requestNotificationAuthorization()
                    }
                }) {
                    Image(systemName: settingsService.isNotificationsEnabled ? "bell.fill" : "bell.slash.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.black)
                        .clipShape(Circle())
                }
            }
        }
        .frame(height: 60)
    }
    
    private var supplementsReminderCard: some View {
        Button(action: {
            isSupplementsReminderOpen = true
        }) {
            HStack(spacing: 12) {
                Image(systemName: "pills.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.teal)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(Color.teal.opacity(0.2))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Supplements Reminder")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("Open placeholder view")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "00b894"), Color(hex: "00b894").opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
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
        }
        .buttonStyle(.plain)
    }
    
    private var statsOverviewSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Stats Overview")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                LiquidGlassStatCard(title: "Today", value: "1,250 kg")
                LiquidGlassStatCard(title: "Week", value: "8,430 kg")
            }
            
            HStack(spacing: 12) {
                LiquidGlassStatCard(title: "Month", value: "31,780 kg")
                LiquidGlassStatCard(title: "Overall", value: "214,600 kg")
            }
            
            LiquidGlassChartCard(title: "Weekly Activity") {
                WeeklyActivityChartView(
                    values: [2, 3, 0, 4, 5, 1, 2],
                    labels: ["M", "T", "W", "Th", "F", "S", "S"]
                )
            }
            
            HStack(spacing: 12) {
                LiquidGlassChartCard(title: "Supplement Split") {
                    StackedColumnChartView(
                        columns: [
                            [0.3, 0.4, 0.3],
                            [0.2, 0.5, 0.3],
                            [0.1, 0.3, 0.6],
                            [0.4, 0.4, 0.2],
                            [0.25, 0.35, 0.4]
                        ],
                        colors: [Color.teal, Color.blue, Color.purple],
                        labels: ["AM", "Mid", "PM", "AM", "PM"]
                    )
                }
                
                LiquidGlassChartCard(title: "Daily Goal") {
                    MultiSegmentGaugeView(
                        segments: [
                            (0.35, Color.green),
                            (0.25, Color.yellow),
                            (0.2, Color.orange),
                            (0.2, Color.red)
                        ],
                        value: 0.72
                    )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
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
    }
    
    // MARK: - Profile Picture
    private var profilePicture: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 50, height: 50)
            
            // Try to get initials from user name
            Text(getUserInitials())
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.blue)
        }
    }
    
    // Helper function to get user initials
    private func getUserInitials() -> String {
        let components = userName.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.prefix(2)
        return String(initials).uppercased()
    }
}

// MARK: - Calendar Section
struct CalendarSection: View {
    @State private var isExpanded = false
    @State private var selectedDate = Date()
    @State private var scheduleByDateKey: [String: [UUID]] = [:]
    @StateObject private var groupViewModel = TrainingGroupViewModel()
    
    private let dataService = DataPersistenceService.shared
    
    var body: some View {
        VStack(spacing: 0) {
            if isExpanded {
                expandedView
            } else {
                collapsedView
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "636e72"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .opacity(0.25)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
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
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isExpanded)
        .onAppear {
            groupViewModel.loadGroups()
            scheduleByDateKey = dataService.loadDaySchedule()
            let today = Calendar.current.startOfDay(for: Date())
            if !Calendar.current.isDate(selectedDate, inSameDayAs: today) {
                selectedDate = today
            }
        }
    }
    
    private var collapsedView: some View {
        VStack(spacing: 6) {
            Button(action: {
                isExpanded.toggle()
            }) {
                HStack {
                    Text("Calendar")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(todayDateString)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                        .rotationEffect(.degrees(0))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .buttonStyle(PlainButtonStyle())
            
            let todayGroups = groupsForDate(Date())
            if !todayGroups.isEmpty {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 8)], alignment: .leading, spacing: 8) {
                    ForEach(todayGroups) { group in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(group.color)
                                .frame(width: 8, height: 8)
                            
                            Text(group.name)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
    }
    
    private var expandedView: some View {
        VStack(spacing: 20) {
            // Header with "Calendar" and close button
            HStack {
                Text("Calendar")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    isExpanded.toggle()
                }) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // Month Selector
            HStack {
                Button(action: {
                    changeMonth(by: -1)
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text(currentMonthYear)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    changeMonth(by: 1)
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
            
            // Horizontal Date Picker
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(datesForCurrentMonth, id: \.self) { date in
                            let indicatorColors = colorsForDate(date)
                            DateButton(
                                date: date,
                                isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                                indicatorColors: indicatorColors,
                                action: {
                                    selectedDate = date
                                }
                            )
                            .id(date)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .onAppear {
                    DispatchQueue.main.async {
                        proxy.scrollTo(normalizedSelectedDate, anchor: .center)
                    }
                }
                .onChange(of: selectedDate) { _, newDate in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        proxy.scrollTo(Calendar.current.startOfDay(for: newDate), anchor: .center)
                    }
                }
            }
            
            selectedDayGroupsSection
            
            NavigationLink(destination: DayPlanningView()) {
                HStack(spacing: 10) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("Add or Edit your Schedule")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(hex: "74b9ff"))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: Color(hex: "74b9ff").opacity(0.4), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    // Helper computed properties
    private var todayDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: Date())
    }
    
    private var currentMonthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
    
    private var datesForCurrentMonth: [Date] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: selectedDate)
        guard let startOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: startOfMonth) else {
            return []
        }
        
        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
    
    private func changeMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func colorsForDate(_ date: Date) -> [Color] {
        let key = dateKey(for: date)
        let ids = scheduleByDateKey[key] ?? []
        let groups = groupViewModel.groups.filter { ids.contains($0.id) }
        return groups.map(\.color)
    }
    
    private var normalizedSelectedDate: Date {
        Calendar.current.startOfDay(for: selectedDate)
    }
    
    private var selectedDayGroupsSection: some View {
        let groups = groupsForDate(selectedDate)
        
        return VStack(alignment: .leading, spacing: 8) {
            Text("Planned Groups")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white.opacity(0.85))
            
            if groups.isEmpty {
                Text("No groups planned")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.65))
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 8)], alignment: .leading, spacing: 8) {
                    ForEach(groups) { group in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(group.color)
                                .frame(width: 8, height: 8)
                            
                            Text(group.name)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.12))
                        .cornerRadius(10)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func groupsForDate(_ date: Date) -> [TrainingGroup] {
        let key = dateKey(for: date)
        let ids = scheduleByDateKey[key] ?? []
        return groupViewModel.groups.filter { ids.contains($0.id) }
    }
}

// MARK: - Date Button
struct DateButton: View {
    let date: Date
    let isSelected: Bool
    let indicatorColors: [Color]
    let action: () -> Void
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(dayName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .black : .white.opacity(0.6))
                
                Text(dayNumber)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isSelected ? .black : .white)
                
                if !indicatorColors.isEmpty {
                    HStack(spacing: 3) {
                        ForEach(indicatorColors.prefix(3).indices, id: \.self) { index in
                            Circle()
                                .fill(indicatorColors[index])
                                .frame(width: 6, height: 6)
                        }
                        
                        if indicatorColors.count > 3 {
                            Text("+\(indicatorColors.count - 3)")
                                .font(.system(size: 8, weight: .semibold))
                                .foregroundColor(.white.opacity(0.85))
                        }
                    }
                }
            }
            .frame(width: 60, height: 70)
            .background(isSelected ? Color(hex: "dfe6e9") : Color.white.opacity(0.15))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Quote Alert View
struct QuoteAlertView: View {
    let quote: String
    let onThumbsUp: () -> Void
    let onThumbsDown: () -> Void
    
    // Parse quote to extract text and author
    private var quoteComponents: (text: String, author: String) {
        let lines = quote.components(separatedBy: "\n")
        if lines.count >= 2 {
            let text = lines.dropLast().joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
            let author = lines.last?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return (text, author)
        }
        return (quote, "")
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Quote content
            VStack(spacing: 12) {
                // Header: "Quote of the Day"
                Text("Quote of the Day")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.top, 16)
                
                // Quote icon
                Image(systemName: "quote.bubble.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.blue)
                    .padding(.top, 4)
                
                // Quote text
                Text(quoteComponents.text)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                
                // Author (if available)
                if !quoteComponents.author.isEmpty {
                    Text(quoteComponents.author)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                        .italic()
                        .padding(.top, 8)
                }
                
                // Action buttons
                HStack(spacing: 30) {
                    // Thumbs Down
                    Button(action: onThumbsDown) {
                        HStack(spacing: 8) {
                            Image(systemName: "hand.thumbsdown.fill")
                                .font(.system(size: 16))
                            Text("Not Today")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(20)
                    }
                    
                    // Thumbs Up
                    Button(action: onThumbsUp) {
                        HStack(spacing: 8) {
                            Image(systemName: "hand.thumbsup.fill")
                                .font(.system(size: 16))
                            Text("Love It!")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.green.opacity(0.8))
                        .cornerRadius(20)
                    }
                }
                .padding(.top, 12)
                .padding(.bottom, 20)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Settings Side Sheet
struct SettingsSideSheet: View {
    @Binding var isOpen: Bool
    @ObservedObject var settingsService = SettingsService.shared
    @ObservedObject var supplementsService = SupplementsReminderService.shared
    
    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Settings")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            isOpen = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 20)
                
                // Content Area
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Appearance Setting
                        LiquidGlassSettingCard(
                            icon: "sun.max.fill",
                            title: "Appearance",
                            iconColor: .orange
                        ) {
                            VStack(spacing: 8) {
                                ForEach(AppearanceMode.allCases, id: \.self) { mode in
                                    LiquidGlassOptionButton(
                                        title: mode.rawValue,
                                        isSelected: settingsService.appearanceMode == mode
                                    ) {
                                        withAnimation(.spring(response: 0.3)) {
                                            settingsService.appearanceMode = mode
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Weight Unit Setting
                        LiquidGlassSettingCard(
                            icon: "scalemass.fill",
                            title: "Weight Unit",
                            iconColor: .blue
                        ) {
                            HStack(spacing: 12) {
                                ForEach(WeightUnit.allCases, id: \.self) { unit in
                                    LiquidGlassOptionButton(
                                        title: unit.displayName,
                                        isSelected: settingsService.weightUnit == unit
                                    ) {
                                        withAnimation(.spring(response: 0.3)) {
                                            settingsService.weightUnit = unit
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Quote of the Day Toggle
                        LiquidGlassToggleCard(
                            icon: "quote.bubble.fill",
                            title: "Quote of the Day",
                            subtitle: "Daily motivational quotes",
                            iconColor: .purple,
                            isOn: $settingsService.isQuoteEnabled
                        )
                        
                        // Workout Reminder Setting
                        LiquidGlassSettingCard(
                            icon: "alarm.fill",
                            title: "Workout Reminder",
                            iconColor: .red
                        ) {
                            VStack(spacing: 10) {
                                HStack {
                                    Text("Reminder")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $settingsService.isWorkoutReminderEnabled)
                                        .labelsHidden()
                                        .tint(.red)
                                }
                                
                                if settingsService.isWorkoutReminderEnabled {
                                    DatePicker(
                                        "Time",
                                        selection: $settingsService.workoutReminderTime,
                                        displayedComponents: .hourAndMinute
                                    )
                                    .datePickerStyle(.compact)
                                    
                                    TextField("Message", text: $settingsService.workoutReminderMessage)
                                        .textInputAutocapitalization(.sentences)
                                        .disableAutocorrection(true)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 8)
                                        .background(Color.white.opacity(0.12))
                                        .cornerRadius(10)
                                }
                            }
                        }
                        
                        // Supplement Reminder Sound
                        LiquidGlassToggleCard(
                            icon: "pills.fill",
                            title: "Supplement Reminder",
                            subtitle: "Sound for supplement alerts",
                            iconColor: .teal,
                            isOn: $supplementsService.isSoundEnabled
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
                
                Spacer()
            }
            .frame(width: 340)
            .background(Color(.systemBackground))
            .shadow(color: .black.opacity(0.2), radius: 10, x: -5, y: 0)
        }
        .ignoresSafeArea()
    }
}

struct SupplementsReminderPlaceholderView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var reminderService = SupplementsReminderService.shared
    @State private var isEditorPresented = false
    @State private var editingReminder: SupplementsReminder?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        headerSection
                        
                        if reminderService.reminders.isEmpty {
                            emptyStateCard
                        } else {
                            VStack(spacing: 12) {
                                ForEach(reminderService.reminders) { reminder in
                                    SupplementsReminderRow(
                                        reminder: reminder,
                                        repeatText: reminderService.repeatSummary(for: reminder),
                                        onToggle: { updated in
                                            reminderService.updateReminder(updated)
                                        },
                                        onEdit: {
                                            editingReminder = reminder
                                            isEditorPresented = true
                                        },
                                        onDelete: {
                                            reminderService.deleteReminder(reminder)
                                        }
                                    )
                                }
                            }
                        }
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Supplements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Add") {
                        editingReminder = nil
                        isEditorPresented = true
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $isEditorPresented) {
                SupplementsReminderEditorView(reminder: editingReminder) { updated in
                    if editingReminder != nil {
                        reminderService.updateReminder(updated)
                    } else {
                        reminderService.addReminder(updated)
                    }
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "pills.fill")
                .font(.system(size: 40, weight: .semibold))
                .foregroundColor(.teal)
            
            Text("Supplements Reminder")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            Text("Create reminders with repeat rules and times.")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var emptyStateCard: some View {
        VStack(spacing: 10) {
            Text("No reminders yet")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("Tap Add to create your first supplements reminder.")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
}

struct SupplementsReminderRow: View {
    let reminder: SupplementsReminder
    let repeatText: String
    let onToggle: (SupplementsReminder) -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "pills.fill")
                    .foregroundColor(.teal)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(Color.teal.opacity(0.15)))
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(reminder.name.isEmpty ? "Supplement" : reminder.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(timeString(reminder.time) + " · " + repeatText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    if !reminder.note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(reminder.note)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { reminder.isEnabled },
                    set: { newValue in
                        var updated = reminder
                        updated.isEnabled = newValue
                        onToggle(updated)
                    })
                )
                .labelsHidden()
                .tint(.teal)
            }
            
            HStack(spacing: 10) {
                Button("Edit") { onEdit() }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.12))
                    .cornerRadius(10)
                
                Button("Delete") { onDelete() }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.red.opacity(0.12))
                    .cornerRadius(10)
                
                Spacer()
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
    
    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct SupplementsReminderEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var note: String
    @State private var time: Date
    @State private var startDate: Date
    @State private var repeatRule: SupplementsRepeatRule
    @State private var repeatEveryDays: Int
    @State private var repeatForDays: Int
    @State private var isEnabled: Bool
    
    private let reminderId: UUID
    private let onSave: (SupplementsReminder) -> Void
    
    init(reminder: SupplementsReminder?, onSave: @escaping (SupplementsReminder) -> Void) {
        let item = reminder ?? SupplementsReminder()
        _name = State(initialValue: item.name)
        _note = State(initialValue: item.note)
        _time = State(initialValue: item.time)
        _startDate = State(initialValue: item.startDate)
        _repeatRule = State(initialValue: item.repeatRule)
        _repeatEveryDays = State(initialValue: item.repeatEveryDays)
        _repeatForDays = State(initialValue: item.repeatForDays)
        _isEnabled = State(initialValue: item.isEnabled)
        reminderId = item.id
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    LiquidGlassSettingCard(icon: "pills.fill", title: "Supplement", iconColor: .teal) {
                        VStack(spacing: 12) {
                            TextField("Name", text: $name)
                                .textInputAutocapitalization(.words)
                                .disableAutocorrection(true)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.12))
                                .cornerRadius(10)
                            
                            TextField("Note (optional)", text: $note)
                                .textInputAutocapitalization(.sentences)
                                .disableAutocorrection(true)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.12))
                                .cornerRadius(10)
                        }
                    }
                    
                    LiquidGlassSettingCard(icon: "clock.fill", title: "Time", iconColor: .blue) {
                        DatePicker("Reminder Time", selection: $time, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.compact)
                    }
                    
                    LiquidGlassSettingCard(icon: "calendar", title: "Repeat", iconColor: .purple) {
                        VStack(spacing: 12) {
                            HStack(spacing: 8) {
                                ForEach(SupplementsRepeatRule.allCases, id: \.self) { rule in
                                    LiquidGlassOptionButton(
                                        title: rule.title,
                                        isSelected: repeatRule == rule
                                    ) {
                                        repeatRule = rule
                                    }
                                }
                            }
                            
                            DatePicker("Start Day", selection: $startDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                            
                            if repeatRule == .custom {
                                VStack(spacing: 10) {
                                    Stepper(value: $repeatEveryDays, in: 1...14) {
                                        Text("Repeat every \(repeatEveryDays) day(s)")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Stepper(value: $repeatForDays, in: 1...90) {
                                        Text("For \(repeatForDays) day(s)")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                    
                    LiquidGlassSettingCard(icon: "bell.fill", title: "Status", iconColor: .teal) {
                        Toggle("Enabled", isOn: $isEnabled)
                            .tint(.teal)
                    }
                }
                .padding(20)
            }
            .navigationTitle("Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let reminder = SupplementsReminder(
                            id: reminderId,
                            name: name,
                            time: time,
                            startDate: startDate,
                            repeatRule: repeatRule,
                            repeatEveryDays: repeatEveryDays,
                            repeatForDays: repeatForDays,
                            isEnabled: isEnabled,
                            note: note
                        )
                        onSave(reminder)
                        dismiss()
                    }
                }
            }
        }
    }
}

struct LiquidGlassStatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
}

struct LiquidGlassChartCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)
            
            content
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
}

struct WeeklyActivityChartView: View {
    let values: [Int]
    let labels: [String]
    
    private var maxValue: Int {
        max(values.max() ?? 1, 1)
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            ForEach(values.indices, id: \.self) { index in
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.blue.opacity(0.8))
                        .frame(height: barHeight(for: values[index]))
                    
                    Text(labels[index])
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 120)
    }
    
    private func barHeight(for value: Int) -> CGFloat {
        CGFloat(value) / CGFloat(maxValue) * 80 + 12
    }
}

struct StackedColumnChartView: View {
    let columns: [[Double]]
    let colors: [Color]
    let labels: [String]
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            ForEach(columns.indices, id: \.self) { columnIndex in
                VStack(spacing: 6) {
                    VStack(spacing: 2) {
                        ForEach(columns[columnIndex].indices, id: \.self) { segmentIndex in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(colors[segmentIndex % colors.count])
                                .frame(height: segmentHeight(for: columns[columnIndex][segmentIndex]))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    Text(labels[columnIndex])
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 120)
    }
    
    private func segmentHeight(for value: Double) -> CGFloat {
        max(CGFloat(value) * 70, 8)
    }
}

struct MultiSegmentGaugeView: View {
    let segments: [(Double, Color)]
    let value: Double
    
    var body: some View {
        ZStack {
            ForEach(segments.indices, id: \.self) { index in
                let start = segments.prefix(index).map { $0.0 }.reduce(0, +)
                let end = start + segments[index].0
                Circle()
                    .trim(from: start, to: end)
                    .stroke(segments[index].1, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
            
            Circle()
                .trim(from: 0, to: min(value, 1))
                .stroke(Color.primary.opacity(0.8), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
            
            Text("\(Int(value * 100))%")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
        }
        .frame(height: 120)
    }
}

// MARK: - Liquid Glass Setting Card
struct LiquidGlassSettingCard<Content: View>: View {
    let icon: String
    let title: String
    let iconColor: Color
    let content: Content
    
    init(icon: String, title: String, iconColor: Color, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.title = title
        self.iconColor = iconColor
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(iconColor)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(iconColor.opacity(0.15))
                    )
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            // Content
            content
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
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
    }
}

// MARK: - Liquid Glass Toggle Card
struct LiquidGlassToggleCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(iconColor)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(iconColor.opacity(0.15))
                )
            
            // Title and Subtitle
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Toggle Switch
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(iconColor)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
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
    }
}

// MARK: - Liquid Glass Option Button
struct LiquidGlassOptionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            isSelected ?
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color.clear, Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isSelected ? Color.clear : Color.primary.opacity(0.1),
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Workout Programs Section
struct WorkoutProgramsSection: View {
    @StateObject private var viewModel = ExerciseListViewModel()
    @StateObject private var groupViewModel = TrainingGroupViewModel()
    @Binding var refreshTrigger: UUID
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main Workout Programs Card
            NavigationLink(destination: ExerciseListView(viewModel: viewModel, preselectedGroupId: nil)) {
                ZStack {
                    // Background with gradient
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "507b8a"),
                                    Color(hex: "3d6a78"),
                                    Color(hex: "2d5461")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .opacity(0.2)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.primary.opacity(0.2), Color.primary.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 8)
                    
                    // Main Content Layout
                    HStack(alignment: .top, spacing: 0) {
                        // Left side: Title and Labels
                        VStack(alignment: .leading, spacing: 0) {
                            // Section Title (static at top-left with equal margins)
                            Text("Workout\nPrograms")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .lineLimit(2)
                                .padding(.top, 16)
                                .padding(.leading, 16)
                                .zIndex(10) // Keep title above everything
                            
                            // Training Group Pills Area (below title)
                            let filteredGroups = groupViewModel.groups.filter { $0.name != "All Exercises" }
                            let pillRows = splitGroupsIntoRows(filteredGroups, maxRows: 3)
                            ScrollView(.horizontal, showsIndicators: false) {
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(pillRows.indices, id: \.self) { rowIndex in
                                        HStack(spacing: 8) {
                                            ForEach(pillRows[rowIndex]) { group in
                                                NavigationLink(destination: WorkoutGroupView(group: group)) {
                                                    WorkoutProgramPillButton(
                                                        title: group.name,
                                                        color: group.color
                                                    )
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                    }
                                }
                                .padding(.top, 16)
                                .padding(.bottom, 16)
                                .padding(.trailing, 8)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: 130, alignment: .topLeading)
                            .clipped()
                            .padding(.leading, 16)
                        }
                        
                        // Right side: Vertical FAB Button (equal margins all sides)
                        VStack(spacing: 0) {
                            // Vertical FAB with "View All" text
                            ZStack {
                                Capsule()
                                    .fill(Color.white)
                                    .frame(width: 45, height: 168)
                                    .shadow(color: .black.opacity(0.2), radius: 10, x: -3, y: 0)
                                
                                Text("View All")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Color(hex: "2d5461"))
                                    .rotationEffect(.degrees(-90))
                                    .fixedSize()
                            }
                            .padding(.top, 16)
                            .padding(.bottom, 16)
                        }
                        .padding(.trailing, 16)
                    }
                }
                .frame(height: 200)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
        }
        .onAppear {
            // Ensure groups are loaded
            groupViewModel.loadGroups()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            // Reload groups when app becomes active
            if newPhase == .active {
                groupViewModel.loadGroups()
            }
        }
        .onChange(of: refreshTrigger) { oldValue, newValue in
            // Reload groups when triggered
            groupViewModel.loadGroups()
        }
    }
    
    // Helper function to position labels in a scattered layout (filling space below title)
    private func getLabelPosition(for index: Int, total: Int) -> LabelPosition {
        // Define positions for up to 8 groups - positioned to fill the available space
        let positions: [LabelPosition] = [
            LabelPosition(x: 0.2, y: 0.25),   // Upper-left
            LabelPosition(x: 0.65, y: 0.2),   // Upper-right
            LabelPosition(x: 0.35, y: 0.5),   // Mid-left
            LabelPosition(x: 0.75, y: 0.55),  // Mid-right
            LabelPosition(x: 0.15, y: 0.8),   // Lower-left
            LabelPosition(x: 0.55, y: 0.85),  // Lower-center
            LabelPosition(x: 0.45, y: 0.35),  // Center
            LabelPosition(x: 0.85, y: 0.7)    // Lower-right
        ]
        
        if index < positions.count {
            return positions[index]
        } else {
            // Fallback for more than 8 groups
            return LabelPosition(x: 0.5, y: 0.5)
        }
    }
}

// MARK: - Label Position Helper
struct LabelPosition {
    let x: CGFloat // 0-1 (percentage of width)
    let y: CGFloat // 0-1 (percentage of height)
}

// MARK: - Workout Program Label
struct WorkoutProgramLabel: View {
    let title: String
    let position: LabelPosition
    
    var body: some View {
        GeometryReader { geometry in
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.25))
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                        )
                        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                )
                .position(
                    x: geometry.size.width * position.x,
                    y: geometry.size.height * position.y
                )
        }
    }
}

// MARK: - Workout Program Pill Button
struct WorkoutProgramPillButton: View {
    let title: String
    let color: Color
    
    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(color.opacity(0.9))
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )
                    .shadow(color: color.opacity(0.35), radius: 6, x: 0, y: 3)
            )
    }
}

private func splitGroupsIntoRows(_ groups: [TrainingGroup], maxRows: Int) -> [[TrainingGroup]] {
    guard maxRows > 0 else { return [] }
    let rows = min(maxRows, max(groups.count, 1))
    let chunkSize = Int(ceil(Double(groups.count) / Double(rows)))
    var result: [[TrainingGroup]] = []
    var index = 0
    
    for _ in 0..<rows {
        guard index < groups.count else { break }
        let end = min(index + chunkSize, groups.count)
        result.append(Array(groups[index..<end]))
        index = end
    }
    
    return result
}

// MARK: - Workout Program Card Content
struct WorkoutProgramCardContent: View {
    let title: String
    let subtitle: String
    let color: Color
    let isViewAll: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // Circular Card
            ZStack {
                // Background Circle with Liquid Glass
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .overlay(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .opacity(0.6)
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.4), Color.white.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: color.opacity(0.3), radius: 15, x: 0, y: 8)
                
                // Icon
                VStack(spacing: 8) {
                    Image(systemName: isViewAll ? "square.grid.2x2.fill" : "dumbbell.fill")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(color)
                    
                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            // Title
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 120)
        }
    }
}

// MARK: - Color Extension for Hex Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    NewMainView()
}

