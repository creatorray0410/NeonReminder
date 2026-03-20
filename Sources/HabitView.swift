import SwiftUI

struct HabitView: View {
    @EnvironmentObject var store: DataStore
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var l10n: LocalizationManager
    @State private var showingAdd = false
    @State private var newTitle = ""
    @State private var newReminderTime = Date()
    @State private var hoveredId: UUID?
    
    var body: some View {
        VStack(spacing: 20) {
            // Add habit section
            VStack(spacing: 16) {
                Button(action: { showingAdd.toggle() }) {
                    HStack(spacing: 10) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 18))
                        Text(l10n.s(.newHabit))
                            .font(.system(size: 14, weight: .semibold))
                        Spacer()
                        Image(systemName: showingAdd ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(NeonColors.green)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(NeonColors.green.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(
                                        style: StrokeStyle(lineWidth: 1, dash: [6, 4])
                                    )
                                    .foregroundColor(NeonColors.green.opacity(0.3))
                            )
                    )
                }
                .buttonStyle(.plain)
                
                if showingAdd {
                    VStack(spacing: 14) {
                        TextField(l10n.s(.habitNamePlaceholder), text: $newTitle)
                            .textFieldStyle(.plain)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(NeonColors.bgSurface)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(NeonColors.green.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        
                        HStack {
                            Text(l10n.s(.dailyReminder))
                                .font(.system(size: 12))
                                .foregroundColor(NeonColors.textSecondary)
                            
                            DatePicker("", selection: $newReminderTime, displayedComponents: [.hourAndMinute])
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .colorScheme(.dark)
                            
                            Spacer()
                            
                            Button(action: {
                                guard !newTitle.isEmpty else { return }
                                let item = HabitItem(title: newTitle, reminderTime: newReminderTime, completedDates: [])
                                store.addHabit(item)
                                newTitle = ""
                                showingAdd = false
                            }) {
                                Text(l10n.s(.add))
                                    .font(.system(size: 13, weight: .bold))
                            }
                            .buttonStyle(NeonButtonStyle(color: NeonColors.green))
                            .disabled(newTitle.isEmpty)
                        }
                    }
                    .padding(16)
                    .neonCard(borderColor: NeonColors.green)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.horizontal, 28)
            .animation(.easeInOut(duration: 0.2), value: showingAdd)
            
            // Today's overview
            if !store.habits.isEmpty {
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(l10n.s(.todayProgress))
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(NeonColors.textSecondary)
                                .tracking(2)
                            
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("\(completedToday)")
                                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                                    .foregroundColor(NeonColors.green)
                                Text("/ \(store.habits.count)")
                                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                                    .foregroundColor(NeonColors.textSecondary)
                                Text(l10n.s(.habitsCompleted))
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(NeonColors.textSecondary)
                            }
                        }
                        
                        Spacer()
                        
                        // Progress ring
                        ZStack {
                            Circle()
                                .stroke(NeonColors.green.opacity(0.15), lineWidth: 4)
                                .frame(width: 50, height: 50)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(todayProgress))
                                .stroke(NeonColors.green, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .frame(width: 50, height: 50)
                                .rotationEffect(.degrees(-90))
                                .neonGlow(NeonColors.green, radius: 4)
                            
                            Text("\(Int(todayProgress * 100))%")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(NeonColors.green)
                        }
                    }
                    .padding(16)
                    .neonCard(borderColor: NeonColors.green)
                }
                .padding(.horizontal, 28)
            }
            
            // Habit list
            if !store.habits.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: l10n.s(.habits), count: store.habits.count, color: NeonColors.green)
                    
                    ForEach(store.habits) { habit in
                        HabitRow(
                            habit: habit,
                            isHovered: hoveredId == habit.id,
                            l10n: l10n,
                            onComplete: { store.toggleHabitToday(habit) },
                            onDelete: { store.deleteHabit(habit) },
                            onForceRemind: {
                                alertManager.triggerAlert(
                                    title: habit.title,
                                    message: l10n.s(.habitCheckIn),
                                    priority: .high,
                                    type: .habit
                                )
                            }
                        )
                        .onHover { h in hoveredId = h ? habit.id : nil }
                    }
                }
                .padding(.horizontal, 28)
            }
            
            // Empty state
            if store.habits.isEmpty {
                VStack(spacing: 16) {
                    Spacer().frame(height: 40)
                    ZStack {
                        Circle()
                            .stroke(NeonColors.green.opacity(0.2), lineWidth: 1)
                            .frame(width: 80, height: 80)
                        Image(systemName: "repeat.circle")
                            .font(.system(size: 30, weight: .light))
                            .foregroundColor(NeonColors.green.opacity(0.5))
                    }
                    Text(l10n.s(.noHabits))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(NeonColors.textSecondary)
                    Text(l10n.s(.noHabitsDesc))
                        .font(.system(size: 12))
                        .foregroundColor(NeonColors.textSecondary.opacity(0.6))
                }
            }
            
            Spacer().frame(height: 20)
        }
        .padding(.top, 20)
    }
    
    private var completedToday: Int {
        store.habits.filter { $0.isCompletedToday }.count
    }
    
    private var todayProgress: Double {
        guard !store.habits.isEmpty else { return 0 }
        return Double(completedToday) / Double(store.habits.count)
    }
}

// MARK: - Habit Row
struct HabitRow: View {
    let habit: HabitItem
    let isHovered: Bool
    let l10n: LocalizationManager
    let onComplete: () -> Void
    let onDelete: () -> Void
    let onForceRemind: () -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            // Completion button
            Button(action: onComplete) {
                ZStack {
                    Circle()
                        .stroke(habit.isCompletedToday ? NeonColors.green : NeonColors.green.opacity(0.3), lineWidth: 2)
                        .frame(width: 32, height: 32)
                    
                    if habit.isCompletedToday {
                        Circle()
                            .fill(NeonColors.green.opacity(0.2))
                            .frame(width: 32, height: 32)
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(NeonColors.green)
                    }
                }
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(habit.isCompletedToday ? NeonColors.green : .white)
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 9))
                            .foregroundColor(NeonColors.orange)
                        Text("\(habit.streakCount) \(l10n.s(.dayStreak))")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(NeonColors.textSecondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "bell")
                            .font(.system(size: 9))
                        Text(TimeFormatter.formatShortTime(habit.reminderTime))
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                    }
                    .foregroundColor(NeonColors.textSecondary.opacity(0.6))
                }
            }
            
            Spacer()
            
            // Streak visualization (last 7 days)
            HStack(spacing: 3) {
                ForEach(0..<7, id: \.self) { dayOffset in
                    let date = Calendar.current.date(byAdding: .day, value: -(6 - dayOffset), to: Date())!
                    let isCompleted = habit.completedDates.contains { Calendar.current.isDate($0, inSameDayAs: date) }
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(isCompleted ? NeonColors.green : NeonColors.green.opacity(0.1))
                        .frame(width: 8, height: 24)
                        .neonGlow(isCompleted ? NeonColors.green : .clear, radius: 2)
                }
            }
            
            if isHovered {
                HStack(spacing: 4) {
                    Button(action: onForceRemind) {
                        Image(systemName: "bell.badge")
                            .font(.system(size: 11))
                            .foregroundColor(NeonColors.orange.opacity(0.7))
                            .frame(width: 28, height: 28)
                            .background(NeonColors.orange.opacity(0.05))
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
        .neonCard(borderColor: habit.isCompletedToday ? NeonColors.green : NeonColors.border)
    }
}
