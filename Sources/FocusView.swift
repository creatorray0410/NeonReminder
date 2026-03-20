import SwiftUI

struct FocusView: View {
    @EnvironmentObject var store: DataStore
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var l10n: LocalizationManager
    @State private var focusTitle = ""
    @State private var focusMinutes: Double = 25
    
    private var presetDurations: [(String, Double)] {
        [
            ("15 \(l10n.s(.minShort))", 15),
            ("25 \(l10n.s(.minShort))", 25),
            ("45 \(l10n.s(.minShort))", 45),
            ("60 \(l10n.s(.minShort))", 60),
            ("90 \(l10n.s(.minShort))", 90),
            ("120 \(l10n.s(.minShort))", 120)
        ]
    }
    
    var body: some View {
        VStack(spacing: 24) {
            if alertManager.isFocusActive {
                activeFocusView
            } else {
                setupFocusView
            }
            
            Spacer().frame(height: 20)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Active Focus View
    private var activeFocusView: some View {
        VStack(spacing: 32) {
            Spacer().frame(height: 20)
            
            HStack(spacing: 8) {
                Circle()
                    .fill(NeonColors.purple)
                    .frame(width: 10, height: 10)
                    .pulseEffect(color: NeonColors.purple)
                
                Text(l10n.s(.focusActive))
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(NeonColors.purple)
                    .tracking(3)
            }
            
            Text(alertManager.focusTitle)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            // Large timer display
            ZStack {
                Circle()
                    .stroke(NeonColors.purple.opacity(0.1), lineWidth: 6)
                    .frame(width: 240, height: 240)
                
                Circle()
                    .trim(from: 0, to: CGFloat(focusProgress))
                    .stroke(
                        AngularGradient(
                            colors: [NeonColors.purple, NeonColors.cyan, NeonColors.purple],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 240, height: 240)
                    .rotationEffect(.degrees(-90))
                    .neonGlow(NeonColors.purple, radius: 8)
                
                Circle()
                    .stroke(NeonColors.purple.opacity(0.15), lineWidth: 1)
                    .frame(width: 200, height: 200)
                
                VStack(spacing: 8) {
                    Text(TimeFormatter.formatTimeRemaining(alertManager.focusTimeRemaining))
                        .font(.system(size: 42, weight: .thin, design: .monospaced))
                        .foregroundColor(.white)
                        .neonGlow(NeonColors.purple, radius: 6)
                    
                    Text(l10n.s(.remaining))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(NeonColors.textSecondary)
                }
            }
            
            Button(action: {
                alertManager.stopFocusSession()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 14))
                    Text(l10n.s(.endSession))
                        .font(.system(size: 14, weight: .bold))
                }
            }
            .buttonStyle(NeonButtonStyle(color: NeonColors.red))
            
            Text(l10n.s(.stayFocused))
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(NeonColors.textSecondary.opacity(0.5))
                .italic()
        }
    }
    
    private var focusProgress: Double {
        guard focusMinutes > 0 else { return 0 }
        let total = focusMinutes * 60
        let remaining = alertManager.focusTimeRemaining
        return max(0, min(1, 1 - remaining / total))
    }
    
    // MARK: - Setup Focus View
    private var setupFocusView: some View {
        VStack(spacing: 24) {
            // Title input
            VStack(alignment: .leading, spacing: 8) {
                FieldLabel(text: l10n.s(.whatFocusing))
                TextField(l10n.s(.focusTitlePlaceholder), text: $focusTitle)
                    .textFieldStyle(.plain)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(NeonColors.bgSurface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(NeonColors.purple.opacity(0.3), lineWidth: 1)
                            )
                    )
            }
            .padding(.horizontal, 28)
            
            // Duration presets
            VStack(alignment: .leading, spacing: 8) {
                FieldLabel(text: l10n.s(.duration))
                
                HStack(spacing: 8) {
                    ForEach(presetDurations, id: \.1) { preset in
                        Button(action: { focusMinutes = preset.1 }) {
                            Text(preset.0)
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundColor(focusMinutes == preset.1 ? .white : NeonColors.textSecondary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(focusMinutes == preset.1 ? NeonColors.purple.opacity(0.2) : NeonColors.bgSurface)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(
                                                    focusMinutes == preset.1 ? NeonColors.purple.opacity(0.5) : NeonColors.border,
                                                    lineWidth: 1
                                                )
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                HStack(spacing: 12) {
                    Text("\(Int(focusMinutes)) \(l10n.s(.minShort))")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(NeonColors.purple)
                        .frame(width: 80)
                    
                    Slider(value: $focusMinutes, in: 5...180, step: 5)
                        .tint(NeonColors.purple)
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 28)
            
            // Preview card
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(l10n.s(.sessionPreview))
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(NeonColors.textSecondary)
                            .tracking(2)
                        
                        Text(focusTitle.isEmpty ? l10n.s(.untitledSession) : focusTitle)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(Int(focusMinutes)) \(l10n.s(.minShort).uppercased())")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(NeonColors.purple)
                            .neonGlow(NeonColors.purple, radius: 4)
                        
                        Text(l10n.s(.focusTime))
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(NeonColors.textSecondary)
                    }
                }
                
                HStack(spacing: 16) {
                    HStack(spacing: 6) {
                        Image(systemName: "bell.badge")
                            .font(.system(size: 10))
                        Text(l10n.s(.forcedAlertWhenDone))
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(NeonColors.textSecondary.opacity(0.6))
                    
                    HStack(spacing: 6) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10))
                        Text(l10n.s(.cannotBeIgnored))
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(NeonColors.textSecondary.opacity(0.6))
                    
                    Spacer()
                }
            }
            .padding(20)
            .neonCard(borderColor: NeonColors.purple)
            .padding(.horizontal, 28)
            
            // Start button
            Button(action: {
                let title = focusTitle.isEmpty ? l10n.s(.focusSession) : focusTitle
                alertManager.startFocusSession(title: title, minutes: Int(focusMinutes))
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 16))
                    Text(l10n.s(.startFocusSession))
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .tracking(2)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(NeonColors.purple.opacity(0.25))
                        .overlay(
                            AnimatedNeonBorder(color: NeonColors.purple, cornerRadius: 14)
                        )
                )
                .neonGlow(NeonColors.purple, radius: 8)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 28)
        }
    }
}
