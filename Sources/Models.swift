import Foundation

// MARK: - Reminder Mode
enum ReminderMode: String, CaseIterable, Codable, Identifiable {
    case task = "Task"
    case countdown = "Countdown"
    case focus = "Focus"
    case habit = "Habit"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .task: return "checklist"
        case .countdown: return "timer"
        case .focus: return "brain.head.profile"
        case .habit: return "repeat.circle"
        }
    }
    
    func localizedName(_ l10n: LocalizationManager) -> String {
        switch self {
        case .task: return l10n.s(.taskReminder)
        case .countdown: return l10n.s(.countdownTimer)
        case .focus: return l10n.s(.focusSession)
        case .habit: return l10n.s(.habitTracker)
        }
    }
    
    func localizedSubtitle(_ l10n: LocalizationManager) -> String {
        switch self {
        case .task: return l10n.s(.taskReminderSub)
        case .countdown: return l10n.s(.countdownTimerSub)
        case .focus: return l10n.s(.focusSessionSub)
        case .habit: return l10n.s(.habitTrackerSub)
        }
    }
}

// MARK: - Priority
enum Priority: Int, CaseIterable, Codable, Identifiable {
    case low = 0
    case medium = 1
    case high = 2
    case critical = 3
    
    var id: Int { rawValue }
    
    func localizedLabel(_ l10n: LocalizationManager) -> String {
        switch self {
        case .low: return l10n.s(.priorityLow)
        case .medium: return l10n.s(.priorityMedium)
        case .high: return l10n.s(.priorityHigh)
        case .critical: return l10n.s(.priorityCritical)
        }
    }
    
    var colorName: String {
        switch self {
        case .low: return "green"
        case .medium: return "blue"
        case .high: return "orange"
        case .critical: return "red"
        }
    }
}

// MARK: - Todo Item
struct TodoItem: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var notes: String
    var dueDate: Date
    var reminderDate: Date
    var priority: Priority
    var isCompleted: Bool
    var mode: ReminderMode
    var hasReminded: Bool
    
    init(
        id: UUID = UUID(),
        title: String = "",
        notes: String = "",
        dueDate: Date = Date(),
        reminderDate: Date = Date(),
        priority: Priority = .medium,
        isCompleted: Bool = false,
        mode: ReminderMode = .task,
        hasReminded: Bool = false
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.dueDate = dueDate
        self.reminderDate = reminderDate
        self.priority = priority
        self.isCompleted = isCompleted
        self.mode = mode
        self.hasReminded = hasReminded
    }
}

// MARK: - Focus Session
struct FocusSession: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var focusMinutes: Int
    var breakMinutes: Int
    var rounds: Int
    var currentRound: Int = 0
    var isActive: Bool = false
}

// MARK: - Habit Item
struct HabitItem: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var reminderTime: Date
    var completedDates: [Date]
    var streakCount: Int = 0
    var isActive: Bool = true
    
    var isCompletedToday: Bool {
        let calendar = Calendar.current
        return completedDates.contains { calendar.isDateInToday($0) }
    }
}

// MARK: - Countdown Item
struct CountdownItem: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var targetDate: Date
    var hasReminded: Bool = false
    
    var timeRemaining: TimeInterval {
        targetDate.timeIntervalSinceNow
    }
    
    var isExpired: Bool {
        timeRemaining <= 0
    }
}
