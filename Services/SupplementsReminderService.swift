import Foundation
import Combine
import UserNotifications

enum SupplementsRepeatRule: String, Codable, CaseIterable {
    case daily
    case weekly
    case monthly
    case custom
    
    var title: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .custom: return "Custom"
        }
    }
}

struct SupplementsReminder: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var time: Date
    var startDate: Date
    var repeatRule: SupplementsRepeatRule
    var repeatEveryDays: Int
    var repeatForDays: Int
    var isEnabled: Bool
    var note: String
    
    init(
        id: UUID = UUID(),
        name: String = "",
        time: Date = Date(),
        startDate: Date = Date(),
        repeatRule: SupplementsRepeatRule = .daily,
        repeatEveryDays: Int = 2,
        repeatForDays: Int = 14,
        isEnabled: Bool = true,
        note: String = ""
    ) {
        self.id = id
        self.name = name
        self.time = time
        self.startDate = startDate
        self.repeatRule = repeatRule
        self.repeatEveryDays = repeatEveryDays
        self.repeatForDays = repeatForDays
        self.isEnabled = isEnabled
        self.note = note
    }
}

final class SupplementsReminderService: ObservableObject {
    static let shared = SupplementsReminderService()
    
    @Published var reminders: [SupplementsReminder] {
        didSet {
            save()
            updateSchedule()
        }
    }
    
    @Published var isSoundEnabled: Bool {
        didSet {
            save()
            updateSchedule()
        }
    }
    
    private let remindersKey = "supplementsReminder.items"
    private let soundKey = "supplementsReminder.soundEnabled"
    private let notificationPrefix = "supplementsReminder"
    
    private init() {
        let defaults = UserDefaults.standard
        self.isSoundEnabled = defaults.object(forKey: soundKey) as? Bool ?? true
        
        if let data = defaults.data(forKey: remindersKey),
           let decoded = try? JSONDecoder().decode([SupplementsReminder].self, from: data) {
            self.reminders = decoded
        } else {
            self.reminders = []
        }
        
        updateSchedule()
    }
    
    func addReminder(_ reminder: SupplementsReminder) {
        reminders.append(reminder)
    }
    
    func updateReminder(_ reminder: SupplementsReminder) {
        guard let index = reminders.firstIndex(where: { $0.id == reminder.id }) else { return }
        reminders[index] = reminder
    }
    
    func deleteReminder(_ reminder: SupplementsReminder) {
        reminders.removeAll { $0.id == reminder.id }
    }
    
    func repeatSummary(for reminder: SupplementsReminder) -> String {
        switch reminder.repeatRule {
        case .daily:
            return "Daily"
        case .weekly:
            return "Weekly"
        case .monthly:
            return "Monthly"
        case .custom:
            return "Every \(reminder.repeatEveryDays)d for \(reminder.repeatForDays)d"
        }
    }
    
    private func save() {
        let defaults = UserDefaults.standard
        defaults.set(isSoundEnabled, forKey: soundKey)
        if let data = try? JSONEncoder().encode(reminders) {
            defaults.set(data, forKey: remindersKey)
        }
    }
    
    private func updateSchedule() {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let ids = requests.map(\.identifier).filter { $0.hasPrefix(self.notificationPrefix) }
            center.removePendingNotificationRequests(withIdentifiers: ids)
            self.scheduleAllReminders(center: center)
        }
    }
    
    private func scheduleAllReminders(center: UNUserNotificationCenter) {
        guard reminders.contains(where: { $0.isEnabled }) else { return }
        
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                self.scheduleNotifications(center: center)
            case .notDetermined:
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    DispatchQueue.main.async {
                        SettingsService.shared.isNotificationsEnabled = granted
                        if !granted {
                            self.reminders = self.reminders.map { var item = $0; item.isEnabled = false; return item }
                        }
                    }
                    if granted {
                        self.scheduleNotifications(center: center)
                    }
                }
            default:
                DispatchQueue.main.async {
                    self.reminders = self.reminders.map { var item = $0; item.isEnabled = false; return item }
                }
            }
        }
    }
    
    private func scheduleNotifications(center: UNUserNotificationCenter) {
        for reminder in reminders where reminder.isEnabled {
            schedule(reminder: reminder, center: center)
        }
    }
    
    private func schedule(reminder: SupplementsReminder, center: UNUserNotificationCenter) {
        let content = UNMutableNotificationContent()
        content.title = "Supplements Reminder"
        let note = reminder.note.trimmingCharacters(in: .whitespacesAndNewlines)
        let name = reminder.name.trimmingCharacters(in: .whitespacesAndNewlines)
        content.body = note.isEmpty ? "Time to take \(name.isEmpty ? "your supplements" : name)." : note
        if isSoundEnabled {
            content.sound = .default
        }
        
        switch reminder.repeatRule {
        case .daily:
            let components = dateComponents(for: reminder, includeWeekday: false, includeDay: false)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            addRequest(idSuffix: "daily", content: content, trigger: trigger, center: center, reminder: reminder)
        case .weekly:
            let components = dateComponents(for: reminder, includeWeekday: true, includeDay: false)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            addRequest(idSuffix: "weekly", content: content, trigger: trigger, center: center, reminder: reminder)
        case .monthly:
            let components = dateComponents(for: reminder, includeWeekday: false, includeDay: true)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            addRequest(idSuffix: "monthly", content: content, trigger: trigger, center: center, reminder: reminder)
        case .custom:
            scheduleCustom(reminder: reminder, content: content, center: center)
        }
    }
    
    private func scheduleCustom(reminder: SupplementsReminder, content: UNNotificationContent, center: UNUserNotificationCenter) {
        let maxNotifications = 60
        let interval = max(reminder.repeatEveryDays, 1)
        let totalDays = max(reminder.repeatForDays, 1)
        let maxOccurrences = min(totalDays / interval + 1, maxNotifications)
        
        for index in 0..<maxOccurrences {
            let dayOffset = index * interval
            guard let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: reminder.startDate) else { continue }
            var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
            let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: reminder.time)
            components.hour = timeComponents.hour
            components.minute = timeComponents.minute
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            addRequest(idSuffix: "custom-\(index)", content: content, trigger: trigger, center: center, reminder: reminder)
        }
    }
    
    private func dateComponents(for reminder: SupplementsReminder, includeWeekday: Bool, includeDay: Bool) -> DateComponents {
        var components = Calendar.current.dateComponents([.hour, .minute], from: reminder.time)
        if includeWeekday {
            components.weekday = Calendar.current.component(.weekday, from: reminder.startDate)
        }
        if includeDay {
            components.day = Calendar.current.component(.day, from: reminder.startDate)
        }
        return components
    }
    
    private func addRequest(idSuffix: String, content: UNNotificationContent, trigger: UNNotificationTrigger, center: UNUserNotificationCenter, reminder: SupplementsReminder) {
        let id = "\(notificationPrefix).\(reminder.id.uuidString).\(idSuffix)"
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(request)
    }
}
