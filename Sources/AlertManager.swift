import SwiftUI
import AppKit

class AlertManager: ObservableObject {
    @Published var isShowingAlert = false
    @Published var currentAlertTitle: String = ""
    @Published var currentAlertMessage: String = ""
    @Published var currentAlertPriority: Priority = .high
    @Published var currentAlertType: AlertType = .task
    @Published var focusTimeRemaining: TimeInterval = 0
    @Published var isFocusActive = false
    @Published var focusTitle: String = ""
    
    var store: DataStore?
    var l10n: LocalizationManager?
    private var timer: Timer?
    private var focusTimer: Timer?
    private var alertWindow: NSWindow?
    private var isDismissing = false
    private var currentAlertTodoId: UUID?
    
    enum AlertType {
        case task
        case countdown
        case focusBreak
        case habit
    }
    
    func startMonitoring() {
        // Invalidate any existing timer first to prevent duplicates
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            self?.checkReminders()
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func checkReminders() {
        guard let store = store else { return }
        
        let pendingTodos = store.pendingTodoReminders()
        if let first = pendingTodos.first {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let msg = first.notes.isEmpty
                    ? "\(self.l10n?.s(.scheduledFor) ?? "Scheduled for") \(TimeFormatter.formatShortTime(first.dueDate))"
                    : first.notes
                self.currentAlertTodoId = first.id
                self.triggerAlert(
                    title: first.title,
                    message: msg,
                    priority: first.priority,
                    type: .task
                )
                store.markReminded(first)
            }
            return
        }
        
        let pendingCountdowns = store.pendingCountdownReminders()
        if let first = pendingCountdowns.first {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.triggerAlert(
                    title: first.title,
                    message: self.l10n?.s(.countdownReachedZero) ?? "Countdown has reached zero!",
                    priority: .critical,
                    type: .countdown
                )
                store.markCountdownReminded(first)
            }
            return
        }
    }
    
    func triggerAlert(title: String, message: String, priority: Priority, type: AlertType) {
        guard !isDismissing else { return }
        
        if isShowingAlert {
            dismissAlertWindow()
        }
        
        currentAlertTitle = title
        currentAlertMessage = message
        currentAlertPriority = priority
        currentAlertType = type
        isShowingAlert = true
        showAlertWindow()
    }
    
    func dismissAlert() {
        guard !isDismissing else { return }
        isDismissing = true
        isShowingAlert = false
        
        // Auto-complete the task when user dismisses the alert
        if currentAlertType == .task, let todoId = currentAlertTodoId {
            if let store = store, let index = store.todos.firstIndex(where: { $0.id == todoId }) {
                if !store.todos[index].isCompleted {
                    store.todos[index].isCompleted = true
                    store.saveTodos()
                }
            }
            currentAlertTodoId = nil
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.dismissAlertWindow()
            self?.isDismissing = false
        }
    }
    
    // MARK: - Focus Mode
    func startFocusSession(title: String, minutes: Int) {
        // Stop any existing focus session first
        focusTimer?.invalidate()
        
        focusTitle = title
        focusTimeRemaining = TimeInterval(minutes * 60)
        isFocusActive = true
        
        focusTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            DispatchQueue.main.async {
                if self.focusTimeRemaining > 0 {
                    self.focusTimeRemaining -= 1
                } else {
                    timer.invalidate()
                    self.focusTimer = nil
                    self.isFocusActive = false
                    self.triggerAlert(
                        title: "\(self.l10n?.s(.focusCompleteTitle) ?? "Focus Complete"): \(self.focusTitle)",
                        message: self.l10n?.s(.focusCompleteMsg) ?? "Great work! Time to take a break.",
                        priority: .high,
                        type: .focusBreak
                    )
                }
            }
        }
    }
    
    func stopFocusSession() {
        focusTimer?.invalidate()
        focusTimer = nil
        isFocusActive = false
        focusTimeRemaining = 0
    }
    
    // MARK: - Full Screen Alert Window
    private func showAlertWindow() {
        guard let screen = NSScreen.main else { return }
        
        let window = NSWindow(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.level = .screenSaver
        window.isOpaque = false
        window.backgroundColor = .clear
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.ignoresMouseEvents = false
        window.isReleasedWhenClosed = false
        
        let alertView = FullScreenAlertView(
            title: currentAlertTitle,
            message: currentAlertMessage,
            priority: currentAlertPriority,
            alertType: currentAlertType,
            l10n: l10n ?? LocalizationManager(),
            onDismiss: { [weak self] in
                self?.dismissAlert()
            }
        )
        
        let hostingView = NSHostingView(rootView: alertView)
        window.contentView = hostingView
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
        
        NSApplication.shared.activate(ignoringOtherApps: true)
        
        self.alertWindow = window
    }
    
    private func dismissAlertWindow() {
        guard let window = alertWindow else { return }
        self.alertWindow = nil
        
        // Remove content view first to break SwiftUI view hierarchy
        window.contentView = nil
        window.orderOut(nil)
        
        DispatchQueue.main.async {
            window.close()
            // Re-activate main window
            if let mainWindow = NSApplication.shared.windows.first(where: { $0.isVisible }) {
                mainWindow.makeKeyAndOrderFront(nil)
            }
        }
    }
    
    deinit {
        timer?.invalidate()
        focusTimer?.invalidate()
        dismissAlertWindow()
    }
}
