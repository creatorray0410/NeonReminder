import SwiftUI

struct CountdownView: View {
    @EnvironmentObject var store: DataStore
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var l10n: LocalizationManager
    @State private var showingAdd = false
    @State private var newTitle = ""
    @State private var newTargetDate = Date().addingTimeInterval(3600)
    @State private var currentTime = Date()
    @State private var hoveredId: UUID?
    @State private var countdownTimer: Timer?
    
    var body: some View {
        VStack(spacing: 20) {
            addCountdownSection
            
            let activeItems = store.countdowns.filter { !$0.isExpired }
            if !activeItems.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: l10n.s(.activeCountdowns), count: activeItems.count, color: NeonColors.magenta)
                    
                    ForEach(activeItems) { item in
                        CountdownCard(item: item, currentTime: currentTime, isHovered: hoveredId == item.id, l10n: l10n) {
                            store.deleteCountdown(item)
                        }
                        .onHover { h in hoveredId = h ? item.id : nil }
                    }
                }
                .padding(.horizontal, 28)
            }
            
            let expiredItems = store.countdowns.filter { $0.isExpired }
            if !expiredItems.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: l10n.s(.expired), count: expiredItems.count, color: NeonColors.red)
                    
                    ForEach(expiredItems) { item in
                        CountdownCard(item: item, currentTime: currentTime, isHovered: hoveredId == item.id, l10n: l10n) {
                            store.deleteCountdown(item)
                        }
                        .opacity(0.6)
                        .onHover { h in hoveredId = h ? item.id : nil }
                    }
                }
                .padding(.horizontal, 28)
            }
            
            if store.countdowns.isEmpty {
                VStack(spacing: 16) {
                    Spacer().frame(height: 40)
                    ZStack {
                        Circle()
                            .stroke(NeonColors.magenta.opacity(0.2), lineWidth: 1)
                            .frame(width: 80, height: 80)
                        Image(systemName: "timer")
                            .font(.system(size: 30, weight: .light))
                            .foregroundColor(NeonColors.magenta.opacity(0.5))
                    }
                    Text(l10n.s(.noCountdowns))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(NeonColors.textSecondary)
                    Text(l10n.s(.noCountdownsDesc))
                        .font(.system(size: 12))
                        .foregroundColor(NeonColors.textSecondary.opacity(0.6))
                }
            }
            
            Spacer().frame(height: 20)
        }
        .padding(.top, 20)
        .onAppear {
            // Start timer only when this view is visible
            currentTime = Date()
            countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                DispatchQueue.main.async { currentTime = Date() }
            }
        }
        .onDisappear {
            // Stop timer when navigating away
            countdownTimer?.invalidate()
            countdownTimer = nil
        }
    }
    
    private var addCountdownSection: some View {
        VStack(spacing: 16) {
            Button(action: { showingAdd.toggle() }) {
                HStack(spacing: 10) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18))
                    Text(l10n.s(.newCountdown))
                        .font(.system(size: 14, weight: .semibold))
                    Spacer()
                    Image(systemName: showingAdd ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                }
                .foregroundColor(NeonColors.magenta)
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(NeonColors.magenta.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(
                                    style: StrokeStyle(lineWidth: 1, dash: [6, 4])
                                )
                                .foregroundColor(NeonColors.magenta.opacity(0.3))
                        )
                )
            }
            .buttonStyle(.plain)
            
            if showingAdd {
                VStack(spacing: 14) {
                    TextField(l10n.s(.countdownTitlePlaceholder), text: $newTitle)
                        .textFieldStyle(.plain)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(NeonColors.bgSurface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(NeonColors.magenta.opacity(0.3), lineWidth: 1)
                                )
                        )
                    
                    HStack {
                        DatePicker(l10n.s(.target), selection: $newTargetDate, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.compact)
                            .colorScheme(.dark)
                            .font(.system(size: 12))
                            .foregroundColor(NeonColors.textSecondary)
                        
                        Spacer()
                        
                        Button(action: {
                            guard !newTitle.isEmpty else { return }
                            let item = CountdownItem(title: newTitle, targetDate: newTargetDate)
                            store.addCountdown(item)
                            newTitle = ""
                            newTargetDate = Date().addingTimeInterval(3600)
                            showingAdd = false
                        }) {
                            Text(l10n.s(.start))
                                .font(.system(size: 13, weight: .bold))
                        }
                        .buttonStyle(NeonButtonStyle(color: NeonColors.magenta))
                        .disabled(newTitle.isEmpty)
                    }
                }
                .padding(16)
                .neonCard(borderColor: NeonColors.magenta)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal, 28)
        .animation(.easeInOut(duration: 0.2), value: showingAdd)
    }
}

// MARK: - Countdown Card
struct CountdownCard: View {
    let item: CountdownItem
    let currentTime: Date
    let isHovered: Bool
    let l10n: LocalizationManager
    let onDelete: () -> Void
    
    private var remaining: TimeInterval {
        item.targetDate.timeIntervalSince(currentTime)
    }
    
    private var progress: Double {
        let total: TimeInterval = 86400
        return max(0, min(1, 1 - remaining / total))
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Circular progress
            ZStack {
                Circle()
                    .stroke(NeonColors.magenta.opacity(0.15), lineWidth: 3)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(
                        NeonColors.magenta,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                
                Image(systemName: item.isExpired ? "checkmark" : "timer")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(NeonColors.magenta)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                Text("\(l10n.s(.target)) \(TimeFormatter.formatDateTime(item.targetDate))")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(NeonColors.textSecondary)
            }
            
            Spacer()
            
            Text(item.isExpired ? l10n.s(.countdownDone) : TimeFormatter.formatTimeRemaining(remaining))
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(item.isExpired ? NeonColors.green : NeonColors.magenta)
            
            if isHovered {
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
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .neonCard(borderColor: NeonColors.magenta)
    }
}
