import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: DataStore
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var l10n: LocalizationManager
    @State private var selectedMode: ReminderMode = .task
    @State private var hoveredMode: ReminderMode?
    
    var body: some View {
        ZStack {
            NeonColors.bgDark
                .ignoresSafeArea()
            
            // Grid background - static, drawn once
            GridBackground()
                .ignoresSafeArea()
                .opacity(0.5)
            
            HStack(spacing: 0) {
                sidebarView
                
                Rectangle()
                    .fill(NeonColors.border)
                    .frame(width: 1)
                
                mainContentView
            }
        }
    }
    
    // MARK: - Sidebar
    private var sidebarView: some View {
        VStack(spacing: 0) {
            // App title
            VStack(spacing: 6) {
                HStack(spacing: 10) {
                    ZStack {
                        HexagonShape()
                            .fill(NeonColors.cyan.opacity(0.15))
                            .frame(width: 36, height: 36)
                        HexagonShape()
                            .stroke(NeonColors.cyan.opacity(0.5), lineWidth: 1)
                            .frame(width: 36, height: 36)
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(NeonColors.cyan)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(l10n.s(.appName))
                            .font(.system(size: 18, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                            .tracking(4)
                        Text(l10n.s(.appSubtitle))
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(NeonColors.cyan)
                            .tracking(l10n.language == .en ? 6 : 2)
                    }
                }
            }
            .padding(.top, 36)
            .padding(.bottom, 24)
            
            // Clock display - isolated component with its own timer
            // Only this small view redraws every second, not the entire tree
            ClockView()
                .padding(.bottom, 24)
            
            Divider()
                .background(NeonColors.border)
                .padding(.horizontal, 20)
            
            // Mode navigation
            VStack(spacing: 4) {
                Text(l10n.s(.modules))
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(NeonColors.textSecondary)
                    .tracking(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                
                ForEach(ReminderMode.allCases) { mode in
                    sidebarButton(mode: mode)
                }
            }
            
            Spacer()
            
            LanguageSwitcher(l10n: l10n)
            StatsSummary(store: store, l10n: l10n)
        }
        .frame(width: 220)
        .background(NeonColors.bgSurface)
    }
    
    private func sidebarButton(mode: ReminderMode) -> some View {
        let isSelected = selectedMode == mode
        let isHovered = hoveredMode == mode
        
        return Button(action: { selectedMode = mode }) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? NeonColors.cyan.opacity(0.15) : Color.clear)
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: mode.icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isSelected ? NeonColors.cyan : NeonColors.textSecondary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.localizedName(l10n))
                        .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? .white : NeonColors.textSecondary)
                    
                    Text(mode.localizedSubtitle(l10n))
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(NeonColors.textSecondary.opacity(0.6))
                        .lineLimit(1)
                }
                
                Spacer()
                
                if isSelected {
                    Circle()
                        .fill(NeonColors.cyan)
                        .frame(width: 6, height: 6)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? NeonColors.cyan.opacity(0.08) : (isHovered ? Color.white.opacity(0.03) : Color.clear))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? NeonColors.cyan.opacity(0.2) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            hoveredMode = hovering ? mode : nil
        }
        .padding(.horizontal, 8)
    }
    
    // MARK: - Main Content
    private var mainContentView: some View {
        VStack(spacing: 0) {
            topBar
            
            ScrollView {
                switch selectedMode {
                case .task:
                    TaskListView()
                        .environmentObject(store)
                        .environmentObject(alertManager)
                        .environmentObject(l10n)
                case .countdown:
                    CountdownView()
                        .environmentObject(store)
                        .environmentObject(alertManager)
                        .environmentObject(l10n)
                case .focus:
                    FocusView()
                        .environmentObject(store)
                        .environmentObject(alertManager)
                        .environmentObject(l10n)
                case .habit:
                    HabitView()
                        .environmentObject(store)
                        .environmentObject(alertManager)
                        .environmentObject(l10n)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .background(NeonColors.bgDark)
    }
    
    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(selectedMode.localizedName(l10n).uppercased())
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .tracking(2)
                
                Text(selectedMode.localizedSubtitle(l10n))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(NeonColors.textSecondary)
            }
            
            Spacer()
            
            // Focus indicator - only redraws when focus state changes
            if alertManager.isFocusActive {
                FocusIndicator()
                    .environmentObject(alertManager)
                    .environmentObject(l10n)
            }
            
            // Test alert button
            Button(action: {
                alertManager.triggerAlert(
                    title: l10n.s(.testAlertTitle),
                    message: l10n.s(.testAlertMsg),
                    priority: .critical,
                    type: .task
                )
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "bell.badge")
                        .font(.system(size: 12))
                    Text(l10n.s(.test))
                        .font(.system(size: 12, weight: .medium))
                }
            }
            .buttonStyle(NeonButtonStyle(color: NeonColors.orange, isSmall: true))
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 18)
        .background(NeonColors.bgSurface.opacity(0.5))
        .overlay(
            Rectangle()
                .fill(NeonColors.border)
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

// MARK: - Isolated Clock View (only this redraws every second)
struct ClockView: View {
    @State private var currentTime = Date()
    
    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f
    }()
    
    private static let dateFormatterEN: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy.MM.dd EEE"
        f.locale = Locale(identifier: "en_US")
        return f
    }()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 4) {
            Text(Self.timeFormatter.string(from: currentTime))
                .font(.system(size: 32, weight: .thin, design: .monospaced))
                .foregroundColor(.white)
            
            Text(Self.dateFormatterEN.string(from: currentTime).uppercased())
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(NeonColors.textSecondary)
        }
        .onReceive(timer) { t in
            currentTime = t
        }
    }
}

// MARK: - Focus Indicator (isolated, only redraws when focus time changes)
struct FocusIndicator: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var l10n: LocalizationManager
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(NeonColors.red)
                .frame(width: 8, height: 8)
            
            Text("\(l10n.s(.focusSession).uppercased()): \(TimeFormatter.formatTimeRemaining(alertManager.focusTimeRemaining))")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(NeonColors.red)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(NeonColors.red.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(NeonColors.red.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Language Switcher
struct LanguageSwitcher: View {
    @ObservedObject var l10n: LocalizationManager
    
    var body: some View {
        VStack(spacing: 8) {
            Divider()
                .background(NeonColors.border)
                .padding(.horizontal, 20)
            
            HStack(spacing: 0) {
                Text(l10n.s(.language))
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(NeonColors.textSecondary)
                    .tracking(2)
                
                Spacer()
                
                HStack(spacing: 0) {
                    Button(action: { l10n.language = .en }) {
                        Text("EN")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(l10n.language == .en ? .white : NeonColors.textSecondary)
                            .frame(width: 36, height: 26)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(l10n.language == .en ? NeonColors.cyan.opacity(0.25) : Color.clear)
                            )
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: { l10n.language = .zh }) {
                        Text("中文")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(l10n.language == .zh ? .white : NeonColors.textSecondary)
                            .frame(width: 36, height: 26)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(l10n.language == .zh ? NeonColors.cyan.opacity(0.25) : Color.clear)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(2)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(NeonColors.border, lineWidth: 1)
                        )
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Stats Summary
struct StatsSummary: View {
    @ObservedObject var store: DataStore
    @ObservedObject var l10n: LocalizationManager
    
    var body: some View {
        VStack(spacing: 8) {
            Divider()
                .background(NeonColors.border)
                .padding(.horizontal, 20)
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(store.todos.filter { !$0.isCompleted }.count)")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(NeonColors.cyan)
                    Text(l10n.s(.active))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(NeonColors.textSecondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(store.todos.filter { $0.isCompleted }.count)")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(NeonColors.green)
                    Text(l10n.s(.done))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(NeonColors.textSecondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }
}
