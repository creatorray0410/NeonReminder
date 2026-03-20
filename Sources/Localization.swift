import SwiftUI

// MARK: - Language Enum
enum AppLanguage: String, CaseIterable, Codable {
    case en = "en"
    case zh = "zh"
    
    var displayName: String {
        switch self {
        case .en: return "EN"
        case .zh: return "中"
        }
    }
    
    var fullName: String {
        switch self {
        case .en: return "English"
        case .zh: return "中文"
        }
    }
}

// MARK: - Localization Manager
class LocalizationManager: ObservableObject {
    @Published var language: AppLanguage {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: "app_language")
        }
    }
    
    init() {
        let saved = UserDefaults.standard.string(forKey: "app_language") ?? "en"
        self.language = AppLanguage(rawValue: saved) ?? .en
    }
    
    func toggle() {
        language = (language == .en) ? .zh : .en
    }
    
    // MARK: - Localized Strings
    func s(_ key: L10nKey) -> String {
        switch language {
        case .en: return key.en
        case .zh: return key.zh
        }
    }
}

// MARK: - All Localization Keys
enum L10nKey {
    // App
    case appName
    case appSubtitle
    
    // Sidebar
    case modules
    case active
    case done
    
    // Modes
    case taskReminder
    case taskReminderSub
    case countdownTimer
    case countdownTimerSub
    case focusSession
    case focusSessionSub
    case habitTracker
    case habitTrackerSub
    
    // Task View
    case pending
    case overdue
    case today
    case completed
    case addNewTask
    case scheduleReminder
    case activeTasks
    case completedTasks
    case noTasksYet
    case noTasksDesc
    case newTask
    case editTask
    case taskTitle
    case taskTitlePlaceholder
    case notesOptional
    case notesPlaceholder
    case dueTime
    case remindBefore
    case reminderAt
    case priorityLevel
    case cancel
    case createTask
    case saveChanges
    case reminded
    
    // Priority
    case priorityLow
    case priorityMedium
    case priorityHigh
    case priorityCritical
    
    // Countdown
    case newCountdown
    case countdownTitlePlaceholder
    case target
    case start
    case activeCountdowns
    case expired
    case noCountdowns
    case noCountdownsDesc
    case countdownDone
    case countdownComplete
    case countdownReachedZero
    
    // Focus
    case focusActive
    case remaining
    case endSession
    case stayFocused
    case whatFocusing
    case focusTitlePlaceholder
    case duration
    case sessionPreview
    case untitledSession
    case focusTime
    case forcedAlertWhenDone
    case cannotBeIgnored
    case startFocusSession
    case focusCompleteTitle
    case focusCompleteMsg
    
    // Habit
    case newHabit
    case habitNamePlaceholder
    case dailyReminder
    case add
    case todayProgress
    case habitsCompleted
    case habits
    case noHabits
    case noHabitsDesc
    case dayStreak
    case habitCheckIn
    
    // Alert
    case taskReminderAlert
    case countdownCompleteAlert
    case focusSessionEndedAlert
    case habitCheckInAlert
    case holdToDismiss
    case holdInstruction
    case scheduledFor
    
    // Test
    case test
    case testAlertTitle
    case testAlertMsg
    
    // Language
    case language
    
    // Time
    case minShort
    case hourShort
    
    var en: String {
        switch self {
        // App
        case .appName: return "NEON"
        case .appSubtitle: return "REMINDER"
        
        // Sidebar
        case .modules: return "MODULES"
        case .active: return "Active"
        case .done: return "Done"
        
        // Modes
        case .taskReminder: return "Task Reminder"
        case .taskReminderSub: return "Schedule tasks and get forced reminders"
        case .countdownTimer: return "Countdown Timer"
        case .countdownTimerSub: return "Set a countdown with alert"
        case .focusSession: return "Focus Session"
        case .focusSessionSub: return "Deep work with break alerts"
        case .habitTracker: return "Habit Tracker"
        case .habitTrackerSub: return "Track daily habits"
        
        // Task View
        case .pending: return "Pending"
        case .overdue: return "Overdue"
        case .today: return "Today"
        case .completed: return "Completed"
        case .addNewTask: return "Add New Task"
        case .scheduleReminder: return "Schedule a reminder"
        case .activeTasks: return "ACTIVE TASKS"
        case .completedTasks: return "COMPLETED"
        case .noTasksYet: return "No tasks yet"
        case .noTasksDesc: return "Add your first task to get started with forced reminders"
        case .newTask: return "NEW TASK"
        case .editTask: return "EDIT TASK"
        case .taskTitle: return "TASK TITLE"
        case .taskTitlePlaceholder: return "What needs to be done?"
        case .notesOptional: return "NOTES (OPTIONAL)"
        case .notesPlaceholder: return "Additional details..."
        case .dueTime: return "DUE TIME"
        case .remindBefore: return "REMIND BEFORE"
        case .reminderAt: return "Reminder at:"
        case .priorityLevel: return "PRIORITY LEVEL"
        case .cancel: return "Cancel"
        case .createTask: return "Create Task"
        case .saveChanges: return "Save Changes"
        case .reminded: return "REMINDED"
        
        // Priority
        case .priorityLow: return "Low"
        case .priorityMedium: return "Medium"
        case .priorityHigh: return "High"
        case .priorityCritical: return "Critical"
        
        // Countdown
        case .newCountdown: return "New Countdown"
        case .countdownTitlePlaceholder: return "Countdown title..."
        case .target: return "Target:"
        case .start: return "Start"
        case .activeCountdowns: return "ACTIVE COUNTDOWNS"
        case .expired: return "EXPIRED"
        case .noCountdowns: return "No countdowns"
        case .noCountdownsDesc: return "Set a countdown and get a forced alert when time is up"
        case .countdownDone: return "DONE"
        case .countdownComplete: return "Countdown Complete"
        case .countdownReachedZero: return "Countdown has reached zero!"
        
        // Focus
        case .focusActive: return "FOCUS SESSION ACTIVE"
        case .remaining: return "remaining"
        case .endSession: return "End Session"
        case .stayFocused: return "Stay focused. Distractions can wait."
        case .whatFocusing: return "WHAT ARE YOU FOCUSING ON?"
        case .focusTitlePlaceholder: return "e.g., Write project proposal..."
        case .duration: return "DURATION"
        case .sessionPreview: return "SESSION PREVIEW"
        case .untitledSession: return "Untitled Session"
        case .focusTime: return "Focus time"
        case .forcedAlertWhenDone: return "Forced alert when done"
        case .cannotBeIgnored: return "Cannot be ignored"
        case .startFocusSession: return "START FOCUS SESSION"
        case .focusCompleteTitle: return "Focus Complete"
        case .focusCompleteMsg: return "Great work! Time to take a break."
        
        // Habit
        case .newHabit: return "New Habit"
        case .habitNamePlaceholder: return "Habit name (e.g., Drink water, Exercise)..."
        case .dailyReminder: return "Daily reminder:"
        case .add: return "Add"
        case .todayProgress: return "TODAY'S PROGRESS"
        case .habitsCompleted: return "habits completed"
        case .habits: return "HABITS"
        case .noHabits: return "No habits tracked"
        case .noHabitsDesc: return "Build daily habits with forced reminders to keep you on track"
        case .dayStreak: return "day streak"
        case .habitCheckIn: return "Habit Check-In"
        
        // Alert
        case .taskReminderAlert: return "TASK REMINDER"
        case .countdownCompleteAlert: return "COUNTDOWN COMPLETE"
        case .focusSessionEndedAlert: return "FOCUS SESSION ENDED"
        case .habitCheckInAlert: return "HABIT CHECK-IN"
        case .holdToDismiss: return "HOLD TO DISMISS"
        case .holdInstruction: return "Hold the button for 2 seconds to acknowledge"
        case .scheduledFor: return "Scheduled for"
        
        // Test
        case .test: return "Test"
        case .testAlertTitle: return "Test Alert"
        case .testAlertMsg: return "This is a test of the forced reminder system."
        
        // Language
        case .language: return "LANGUAGE"
        
        // Time
        case .minShort: return "min"
        case .hourShort: return "h"
        }
    }
    
    var zh: String {
        switch self {
        // App
        case .appName: return "NEON"
        case .appSubtitle: return "提醒助手"
        
        // Sidebar
        case .modules: return "功能模块"
        case .active: return "进行中"
        case .done: return "已完成"
        
        // Modes
        case .taskReminder: return "任务提醒"
        case .taskReminderSub: return "安排任务并获取强制提醒"
        case .countdownTimer: return "倒计时"
        case .countdownTimerSub: return "设置倒计时并在到期时提醒"
        case .focusSession: return "专注模式"
        case .focusSessionSub: return "深度工作，到时提醒休息"
        case .habitTracker: return "习惯打卡"
        case .habitTrackerSub: return "追踪每日习惯"
        
        // Task View
        case .pending: return "待处理"
        case .overdue: return "已逾期"
        case .today: return "今日"
        case .completed: return "已完成"
        case .addNewTask: return "添加新任务"
        case .scheduleReminder: return "设置一个提醒"
        case .activeTasks: return "进行中的任务"
        case .completedTasks: return "已完成"
        case .noTasksYet: return "暂无任务"
        case .noTasksDesc: return "添加你的第一个任务，开始使用强制提醒"
        case .newTask: return "新建任务"
        case .editTask: return "编辑任务"
        case .taskTitle: return "任务标题"
        case .taskTitlePlaceholder: return "需要做什么？"
        case .notesOptional: return "备注（可选）"
        case .notesPlaceholder: return "补充说明..."
        case .dueTime: return "截止时间"
        case .remindBefore: return "提前提醒"
        case .reminderAt: return "提醒时间："
        case .priorityLevel: return "优先级"
        case .cancel: return "取消"
        case .createTask: return "创建任务"
        case .saveChanges: return "保存修改"
        case .reminded: return "已提醒"
        
        // Priority
        case .priorityLow: return "低"
        case .priorityMedium: return "中"
        case .priorityHigh: return "高"
        case .priorityCritical: return "紧急"
        
        // Countdown
        case .newCountdown: return "新建倒计时"
        case .countdownTitlePlaceholder: return "倒计时标题..."
        case .target: return "目标时间："
        case .start: return "开始"
        case .activeCountdowns: return "进行中的倒计时"
        case .expired: return "已到期"
        case .noCountdowns: return "暂无倒计时"
        case .noCountdownsDesc: return "设置一个倒计时，到期时会强制提醒你"
        case .countdownDone: return "完成"
        case .countdownComplete: return "倒计时结束"
        case .countdownReachedZero: return "倒计时已归零！"
        
        // Focus
        case .focusActive: return "专注中"
        case .remaining: return "剩余时间"
        case .endSession: return "结束专注"
        case .stayFocused: return "保持专注，其他事情可以等一等。"
        case .whatFocusing: return "你要专注做什么？"
        case .focusTitlePlaceholder: return "例如：撰写项目方案..."
        case .duration: return "时长"
        case .sessionPreview: return "专注预览"
        case .untitledSession: return "未命名专注"
        case .focusTime: return "专注时长"
        case .forcedAlertWhenDone: return "结束时强制提醒"
        case .cannotBeIgnored: return "无法忽略"
        case .startFocusSession: return "开始专注"
        case .focusCompleteTitle: return "专注完成"
        case .focusCompleteMsg: return "干得漂亮！该休息一下了。"
        
        // Habit
        case .newHabit: return "新建习惯"
        case .habitNamePlaceholder: return "习惯名称（如：喝水、运动）..."
        case .dailyReminder: return "每日提醒："
        case .add: return "添加"
        case .todayProgress: return "今日进度"
        case .habitsCompleted: return "个习惯已完成"
        case .habits: return "习惯列表"
        case .noHabits: return "暂无习惯"
        case .noHabitsDesc: return "建立每日习惯，用强制提醒帮你坚持"
        case .dayStreak: return "天连续"
        case .habitCheckIn: return "习惯打卡"
        
        // Alert
        case .taskReminderAlert: return "任务提醒"
        case .countdownCompleteAlert: return "倒计时结束"
        case .focusSessionEndedAlert: return "专注已结束"
        case .habitCheckInAlert: return "习惯打卡"
        case .holdToDismiss: return "长按关闭"
        case .holdInstruction: return "长按按钮 2 秒以确认知悉"
        case .scheduledFor: return "计划时间"
        
        // Test
        case .test: return "测试"
        case .testAlertTitle: return "测试提醒"
        case .testAlertMsg: return "这是一条强制提醒系统的测试消息。"
        
        // Language
        case .language: return "语言"
        
        // Time
        case .minShort: return "分钟"
        case .hourShort: return "小时"
        }
    }
}
