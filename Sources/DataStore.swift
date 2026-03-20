import Foundation
import SwiftUI
import Combine

class DataStore: ObservableObject {
    @Published var todos: [TodoItem] = []
    @Published var countdowns: [CountdownItem] = []
    @Published var focusSessions: [FocusSession] = []
    @Published var habits: [HabitItem] = []
    
    private let todosKey = "neon_todos"
    private let countdownsKey = "neon_countdowns"
    private let focusKey = "neon_focus"
    private let habitsKey = "neon_habits"
    
    init() {
        loadAll()
    }
    
    // MARK: - Persistence
    private func loadAll() {
        todos = load(key: todosKey) ?? []
        countdowns = load(key: countdownsKey) ?? []
        focusSessions = load(key: focusKey) ?? []
        habits = load(key: habitsKey) ?? []
    }
    
    private func load<T: Codable>(key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    private func save<T: Codable>(_ value: T, key: String) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    func saveTodos() { save(todos, key: todosKey) }
    func saveCountdowns() { save(countdowns, key: countdownsKey) }
    func saveFocusSessions() { save(focusSessions, key: focusKey) }
    func saveHabits() { save(habits, key: habitsKey) }
    
    // MARK: - Todo CRUD
    func addTodo(_ item: TodoItem) {
        todos.append(item)
        saveTodos()
    }
    
    func updateTodo(_ item: TodoItem) {
        if let index = todos.firstIndex(where: { $0.id == item.id }) {
            todos[index] = item
            saveTodos()
        }
    }
    
    func deleteTodo(_ item: TodoItem) {
        todos.removeAll { $0.id == item.id }
        saveTodos()
    }
    
    func toggleTodo(_ item: TodoItem) {
        if let index = todos.firstIndex(where: { $0.id == item.id }) {
            todos[index].isCompleted.toggle()
            saveTodos()
        }
    }
    
    func markReminded(_ item: TodoItem) {
        if let index = todos.firstIndex(where: { $0.id == item.id }) {
            todos[index].hasReminded = true
            saveTodos()
        }
    }
    
    // MARK: - Countdown CRUD
    func addCountdown(_ item: CountdownItem) {
        countdowns.append(item)
        saveCountdowns()
    }
    
    func deleteCountdown(_ item: CountdownItem) {
        countdowns.removeAll { $0.id == item.id }
        saveCountdowns()
    }
    
    func markCountdownReminded(_ item: CountdownItem) {
        if let index = countdowns.firstIndex(where: { $0.id == item.id }) {
            countdowns[index].hasReminded = true
            saveCountdowns()
        }
    }
    
    // MARK: - Habit CRUD
    func addHabit(_ item: HabitItem) {
        habits.append(item)
        saveHabits()
    }
    
    func deleteHabit(_ item: HabitItem) {
        habits.removeAll { $0.id == item.id }
        saveHabits()
    }
    
    func completeHabitToday(_ item: HabitItem) {
        if let index = habits.firstIndex(where: { $0.id == item.id }) {
            habits[index].completedDates.append(Date())
            habits[index].streakCount += 1
            saveHabits()
        }
    }
    
    func toggleHabitToday(_ item: HabitItem) {
        if let index = habits.firstIndex(where: { $0.id == item.id }) {
            if item.isCompletedToday {
                // Remove today's completion
                let calendar = Calendar.current
                habits[index].completedDates.removeAll { calendar.isDateInToday($0) }
                habits[index].streakCount = max(0, habits[index].streakCount - 1)
            } else {
                habits[index].completedDates.append(Date())
                habits[index].streakCount += 1
            }
            saveHabits()
        }
    }
    
    // MARK: - Pending Reminders
    func pendingTodoReminders() -> [TodoItem] {
        let now = Date()
        return todos.filter { !$0.isCompleted && !$0.hasReminded && $0.reminderDate <= now }
    }
    
    func pendingCountdownReminders() -> [CountdownItem] {
        return countdowns.filter { !$0.hasReminded && $0.isExpired }
    }
}
