import SwiftUI

struct TaskListView: View {
    @EnvironmentObject var store: DataStore
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var l10n: LocalizationManager
    @State private var showingAddTask = false
    @State private var editingTask: TodoItem?
    @State private var hoveredTaskId: UUID?
    
    private var activeTasks: [TodoItem] {
        store.todos.filter { !$0.isCompleted }.sorted { $0.dueDate < $1.dueDate }
    }
    
    private var completedTasks: [TodoItem] {
        store.todos.filter { $0.isCompleted }.sorted { $0.dueDate > $1.dueDate }
    }
    
    // Pending = not completed AND not yet overdue (dueDate is still in the future)
    private var pendingCount: Int {
        store.todos.filter { !$0.isCompleted && $0.dueDate >= Date() }.count
    }
    
    // Overdue = not completed AND past due date
    private var overdueCount: Int {
        store.todos.filter { !$0.isCompleted && $0.dueDate < Date() }.count
    }
    
    // Today = all tasks (completed or not) whose dueDate is today
    private var todayCount: Int {
        store.todos.filter { Calendar.current.isDateInToday($0.dueDate) }.count
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Quick stats
            HStack(spacing: 16) {
                StatCard(title: l10n.s(.pending), value: "\(pendingCount)", icon: "clock", color: NeonColors.cyan)
                StatCard(title: l10n.s(.overdue), value: "\(overdueCount)", icon: "exclamationmark.triangle", color: NeonColors.red)
                StatCard(title: l10n.s(.today), value: "\(todayCount)", icon: "sun.max", color: NeonColors.orange)
                StatCard(title: l10n.s(.completed), value: "\(completedTasks.count)", icon: "checkmark.circle", color: NeonColors.green)
            }
            .padding(.horizontal, 28)
            
            // Add task button
            Button(action: { showingAddTask = true }) {
                HStack(spacing: 10) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18))
                    Text(l10n.s(.addNewTask))
                        .font(.system(size: 14, weight: .semibold))
                    Spacer()
                    Text(l10n.s(.scheduleReminder))
                        .font(.system(size: 11))
                        .foregroundColor(NeonColors.textSecondary)
                }
                .foregroundColor(NeonColors.cyan)
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(NeonColors.cyan.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(
                                    style: StrokeStyle(lineWidth: 1, dash: [6, 4])
                                )
                                .foregroundColor(NeonColors.cyan.opacity(0.3))
                        )
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 28)
            
            // Overdue tasks section
            if activeTasks.contains(where: { $0.dueDate < Date() }) {
                let overdueTasks = activeTasks.filter { $0.dueDate < Date() }
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: l10n.s(.overdue), count: overdueTasks.count, color: NeonColors.red)
                    
                    ForEach(overdueTasks) { task in
                        TaskRow(
                            task: task,
                            isHovered: hoveredTaskId == task.id,
                            l10n: l10n,
                            onToggle: { store.toggleTodo(task) },
                            onEdit: { editingTask = task },
                            onDelete: { store.deleteTodo(task) }
                        )
                        .onHover { hovering in
                            hoveredTaskId = hovering ? task.id : nil
                        }
                    }
                }
                .padding(.horizontal, 28)
            }
            
            // Pending tasks section
            if activeTasks.contains(where: { $0.dueDate >= Date() }) {
                let pendingTasks = activeTasks.filter { $0.dueDate >= Date() }
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: l10n.s(.activeTasks), count: pendingTasks.count, color: NeonColors.cyan)
                    
                    ForEach(pendingTasks) { task in
                        TaskRow(
                            task: task,
                            isHovered: hoveredTaskId == task.id,
                            l10n: l10n,
                            onToggle: { store.toggleTodo(task) },
                            onEdit: { editingTask = task },
                            onDelete: { store.deleteTodo(task) }
                        )
                        .onHover { hovering in
                            hoveredTaskId = hovering ? task.id : nil
                        }
                    }
                }
                .padding(.horizontal, 28)
            }
            
            // Completed tasks
            if !completedTasks.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: l10n.s(.completedTasks), count: completedTasks.count, color: NeonColors.green)
                    
                    ForEach(completedTasks.prefix(5)) { task in
                        TaskRow(
                            task: task,
                            isHovered: hoveredTaskId == task.id,
                            l10n: l10n,
                            onToggle: { store.toggleTodo(task) },
                            onEdit: { editingTask = task },
                            onDelete: { store.deleteTodo(task) }
                        )
                        .opacity(0.6)
                        .onHover { hovering in
                            hoveredTaskId = hovering ? task.id : nil
                        }
                    }
                }
                .padding(.horizontal, 28)
            }
            
            // Empty state
            if store.todos.isEmpty {
                VStack(spacing: 16) {
                    Spacer().frame(height: 40)
                    
                    ZStack {
                        Circle()
                            .stroke(NeonColors.cyan.opacity(0.2), lineWidth: 1)
                            .frame(width: 80, height: 80)
                        Image(systemName: "checklist")
                            .font(.system(size: 30, weight: .light))
                            .foregroundColor(NeonColors.cyan.opacity(0.5))
                    }
                    
                    Text(l10n.s(.noTasksYet))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(NeonColors.textSecondary)
                    
                    Text(l10n.s(.noTasksDesc))
                        .font(.system(size: 12))
                        .foregroundColor(NeonColors.textSecondary.opacity(0.6))
                }
            }
            
            Spacer().frame(height: 20)
        }
        .padding(.top, 20)
        .sheet(isPresented: $showingAddTask) {
            TaskEditSheet(task: nil, l10n: l10n, onSave: { task in
                store.addTodo(task)
                showingAddTask = false
            }, onCancel: {
                showingAddTask = false
            })
        }
        .sheet(item: $editingTask) { task in
            TaskEditSheet(task: task, l10n: l10n, onSave: { updated in
                store.updateTodo(updated)
                editingTask = nil
            }, onCancel: {
                editingTask = nil
            })
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.1))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(NeonColors.textSecondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .neonCard(borderColor: color)
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(color)
                .frame(width: 3, height: 14)
                .cornerRadius(2)
            
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(color)
                .tracking(2)
            
            Text("(\(count))")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(NeonColors.textSecondary)
            
            Rectangle()
                .fill(NeonColors.border)
                .frame(height: 1)
        }
    }
}

// MARK: - Task Row
struct TaskRow: View {
    let task: TodoItem
    let isHovered: Bool
    let l10n: LocalizationManager
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    @State private var isCheckboxHovered = false
    
    private var isOverdue: Bool {
        !task.isCompleted && task.dueDate < Date()
    }
    
    private var priorityColor: Color {
        NeonColors.priorityColor(task.priority)
    }
    
    var body: some View {
        HStack(spacing: 14) {
            // Checkbox - enlarged hit area with contentShape
            Button(action: {
                onToggle()
            }) {
                ZStack {
                    // Invisible fill to ensure full hit area
                    RoundedRectangle(cornerRadius: 6)
                        .fill(task.isCompleted ? NeonColors.green.opacity(0.2) : (isCheckboxHovered ? priorityColor.opacity(0.1) : Color.clear))
                        .frame(width: 26, height: 26)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(
                            task.isCompleted ? NeonColors.green : (isCheckboxHovered ? priorityColor : priorityColor.opacity(0.5)),
                            lineWidth: isCheckboxHovered ? 2 : 1.5
                        )
                        .frame(width: 26, height: 26)
                    
                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(NeonColors.green)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                isCheckboxHovered = hovering
            }
            
            // Priority indicator
            Rectangle()
                .fill(priorityColor)
                .frame(width: 3, height: 36)
                .cornerRadius(2)
                .neonGlow(priorityColor, radius: 3)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(task.isCompleted ? NeonColors.textSecondary : .white)
                    .strikethrough(task.isCompleted, color: NeonColors.textSecondary)
                
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 9))
                        Text(TimeFormatter.formatShortTime(task.dueDate))
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                    }
                    .foregroundColor(isOverdue ? NeonColors.red : NeonColors.textSecondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "bell")
                            .font(.system(size: 9))
                        Text(TimeFormatter.formatShortTime(task.reminderDate))
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                    }
                    .foregroundColor(NeonColors.textSecondary.opacity(0.6))
                    
                    Text(task.priority.localizedLabel(l10n).uppercased())
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(priorityColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(priorityColor.opacity(0.15))
                        )
                    
                    if task.hasReminded {
                        Text(l10n.s(.reminded))
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                            .foregroundColor(NeonColors.green)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(NeonColors.green.opacity(0.15))
                            )
                    }
                }
            }
            
            Spacer()
            
            // Time remaining
            if !task.isCompleted {
                Text(TimeFormatter.formatRelative(task.dueDate))
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(isOverdue ? NeonColors.red : NeonColors.cyan)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill((isOverdue ? NeonColors.red : NeonColors.cyan).opacity(0.1))
                    )
            }
            
            // Actions
            if isHovered {
                HStack(spacing: 4) {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.system(size: 11))
                            .foregroundColor(NeonColors.textSecondary)
                            .frame(width: 28, height: 28)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 11))
                            .foregroundColor(NeonColors.red.opacity(0.7))
                            .frame(width: 28, height: 28)
                            .background(NeonColors.red.opacity(0.05))
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isHovered ? NeonColors.bgCardHover : NeonColors.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isOverdue ? NeonColors.red.opacity(0.3) : NeonColors.border,
                            lineWidth: 1
                        )
                )
        )
        .animation(.easeInOut(duration: 0.15), value: isHovered)
    }
}

// MARK: - Task Edit Sheet
struct TaskEditSheet: View {
    let task: TodoItem?
    let l10n: LocalizationManager
    let onSave: (TodoItem) -> Void
    let onCancel: () -> Void
    
    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var dueDate: Date = Date()
    @State private var reminderDate: Date = Date()
    @State private var priority: Priority = .medium
    @State private var reminderMinutesBefore: Int = 5
    
    private let reminderOptions = [1, 3, 5, 10, 15, 30, 60]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(task == nil ? l10n.s(.newTask) : l10n.s(.editTask))
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .tracking(2)
                Spacer()
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(NeonColors.textSecondary)
                        .frame(width: 30, height: 30)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
            .padding(24)
            .background(NeonColors.bgSurface)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Title field
                    VStack(alignment: .leading, spacing: 8) {
                        FieldLabel(text: l10n.s(.taskTitle))
                        TextField(l10n.s(.taskTitlePlaceholder), text: $title)
                            .textFieldStyle(.plain)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(NeonColors.bgSurface)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(NeonColors.cyan.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    
                    // Notes field
                    VStack(alignment: .leading, spacing: 8) {
                        FieldLabel(text: l10n.s(.notesOptional))
                        TextField(l10n.s(.notesPlaceholder), text: $notes)
                            .textFieldStyle(.plain)
                            .font(.system(size: 13))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(NeonColors.bgSurface)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(NeonColors.border, lineWidth: 1)
                                    )
                            )
                    }
                    
                    // Due date
                    VStack(alignment: .leading, spacing: 8) {
                        FieldLabel(text: l10n.s(.dueTime))
                        DatePicker("", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .colorScheme(.dark)
                            .onChange(of: dueDate) { _, newValue in
                                reminderDate = newValue.addingTimeInterval(-Double(reminderMinutesBefore * 60))
                            }
                    }
                    
                    // Remind before
                    VStack(alignment: .leading, spacing: 8) {
                        FieldLabel(text: l10n.s(.remindBefore))
                        HStack(spacing: 8) {
                            ForEach(reminderOptions, id: \.self) { minutes in
                                Button(action: {
                                    reminderMinutesBefore = minutes
                                    reminderDate = dueDate.addingTimeInterval(-Double(minutes * 60))
                                }) {
                                    Text(minutes < 60 ? "\(minutes)\(l10n.s(.minShort))" : "\(minutes/60)\(l10n.s(.hourShort))")
                                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                                        .foregroundColor(reminderMinutesBefore == minutes ? .white : NeonColors.textSecondary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(reminderMinutesBefore == minutes ? NeonColors.cyan.opacity(0.2) : NeonColors.bgSurface)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(
                                                            reminderMinutesBefore == minutes ? NeonColors.cyan.opacity(0.5) : NeonColors.border,
                                                            lineWidth: 1
                                                        )
                                                )
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        Text("\(l10n.s(.reminderAt)) \(TimeFormatter.formatDateTime(reminderDate))")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(NeonColors.cyan.opacity(0.7))
                    }
                    
                    // Priority
                    VStack(alignment: .leading, spacing: 8) {
                        FieldLabel(text: l10n.s(.priorityLevel))
                        HStack(spacing: 8) {
                            ForEach(Priority.allCases) { p in
                                Button(action: { priority = p }) {
                                    HStack(spacing: 6) {
                                        Circle()
                                            .fill(NeonColors.priorityColor(p))
                                            .frame(width: 8, height: 8)
                                        Text(p.localizedLabel(l10n))
                                            .font(.system(size: 12, weight: .medium))
                                    }
                                    .foregroundColor(priority == p ? .white : NeonColors.textSecondary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(priority == p ? NeonColors.priorityColor(p).opacity(0.2) : NeonColors.bgSurface)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(
                                                        priority == p ? NeonColors.priorityColor(p).opacity(0.5) : NeonColors.border,
                                                        lineWidth: 1
                                                    )
                                            )
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(24)
            }
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: onCancel) {
                    Text(l10n.s(.cancel))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(NeonColors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(NeonColors.border, lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    var item = task ?? TodoItem()
                    item.title = title
                    item.notes = notes
                    item.dueDate = dueDate
                    item.reminderDate = reminderDate
                    item.priority = priority
                    onSave(item)
                }) {
                    Text(task == nil ? l10n.s(.createTask) : l10n.s(.saveChanges))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(NeonColors.cyan.opacity(title.isEmpty ? 0.1 : 0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(NeonColors.cyan.opacity(title.isEmpty ? 0.2 : 0.6), lineWidth: 1)
                                )
                        )
                        .neonGlow(NeonColors.cyan, radius: title.isEmpty ? 0 : 6)
                }
                .buttonStyle(.plain)
                .disabled(title.isEmpty)
            }
            .padding(24)
            .background(NeonColors.bgSurface)
        }
        .frame(width: 520, height: 560)
        .background(NeonColors.bgDark)
        .onAppear {
            if let task = task {
                title = task.title
                notes = task.notes
                dueDate = task.dueDate
                reminderDate = task.reminderDate
                priority = task.priority
            } else {
                dueDate = Date().addingTimeInterval(3600)
                reminderDate = dueDate.addingTimeInterval(-300)
            }
        }
    }
}

