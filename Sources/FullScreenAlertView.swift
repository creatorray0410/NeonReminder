import SwiftUI

struct FullScreenAlertView: View {
    let title: String
    let message: String
    let priority: Priority
    let alertType: AlertManager.AlertType
    let l10n: LocalizationManager
    let onDismiss: () -> Void
    
    @State private var showContent = false
    @State private var ringRotation: Double = 0
    @State private var dismissProgress: CGFloat = 0
    @State private var isHoldingDismiss = false
    @State private var hasDismissed = false
    @State private var animationTimer: Timer?
    
    private var alertColor: Color {
        NeonColors.priorityColor(priority)
    }
    
    private var alertIcon: String {
        switch alertType {
        case .task: return "bell.badge.fill"
        case .countdown: return "timer"
        case .focusBreak: return "cup.and.saucer.fill"
        case .habit: return "checkmark.circle.fill"
        }
    }
    
    private var alertLabel: String {
        switch alertType {
        case .task: return l10n.s(.taskReminderAlert)
        case .countdown: return l10n.s(.countdownCompleteAlert)
        case .focusBreak: return l10n.s(.focusSessionEndedAlert)
        case .habit: return l10n.s(.habitCheckInAlert)
        }
    }
    
    var body: some View {
        ZStack {
            // Dark overlay
            Color.black.opacity(0.85)
                .ignoresSafeArea()
            
            // Radial glow behind center (static)
            RadialGradient(
                colors: [alertColor.opacity(0.15), alertColor.opacity(0.05), .clear],
                center: .center,
                startRadius: 50,
                endRadius: 400
            )
            .ignoresSafeArea()
            
            // Rotating ring decorations - 15fps is enough for smooth rotation
            ringDecorations
            
            // Main content
            VStack(spacing: 0) {
                Spacer()
                
                if showContent {
                    alertTypeLabel
                    iconView
                    titleView
                    messageView
                    dismissButton
                }
                
                Spacer()
            }
            
            // Corner decorations
            cornerDecorations
            
            // Timestamp
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text(TimeFormatter.formatDateTime(Date()))
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(alertColor.opacity(0.5))
                        .padding(20)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
            // 15fps is sufficient for smooth ring rotation, halves GPU work vs 30fps
            animationTimer = Timer.scheduledTimer(withTimeInterval: 1.0/15.0, repeats: true) { _ in
                DispatchQueue.main.async {
                    ringRotation += 0.5
                    if ringRotation >= 360 { ringRotation -= 360 }
                }
            }
            NSSound.beep()
        }
        .onDisappear {
            animationTimer?.invalidate()
            animationTimer = nil
        }
    }
    
    // MARK: - Ring Decorations (drawn efficiently with Canvas)
    private var ringDecorations: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let rotation = ringRotation * .pi / 180
            
            // Outer ring
            drawRotatedCircle(context: context, center: center, radius: 250, rotation: rotation, lineWidth: 2, opacity: 0.4)
            
            // Middle ring
            drawRotatedCircle(context: context, center: center, radius: 200, rotation: -rotation * 0.7, lineWidth: 1, opacity: 0.15)
            
            // Inner ring
            drawRotatedCircle(context: context, center: center, radius: 150, rotation: rotation * 1.3, lineWidth: 1.5, opacity: 0.3)
            
            // Dots on outer ring
            for i in 0..<8 {
                let angle = Double(i) * .pi / 4 + rotation
                let dotCenter = CGPoint(
                    x: center.x + 250 * cos(angle),
                    y: center.y + 250 * sin(angle)
                )
                let dotRect = CGRect(x: dotCenter.x - 3, y: dotCenter.y - 3, width: 6, height: 6)
                context.fill(Path(ellipseIn: dotRect), with: .color(alertColor.opacity(0.6)))
            }
        }
        .allowsHitTesting(false)
    }
    
    private func drawRotatedCircle(context: GraphicsContext, center: CGPoint, radius: CGFloat, rotation: Double, lineWidth: CGFloat, opacity: Double) {
        let rect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
        let path = Path(ellipseIn: rect)
        context.stroke(path, with: .color(alertColor.opacity(opacity)), lineWidth: lineWidth)
    }
    
    // MARK: - Content Subviews
    private var alertTypeLabel: some View {
        HStack(spacing: 8) {
            Rectangle().fill(alertColor).frame(width: 30, height: 1)
            Text(alertLabel)
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundColor(alertColor)
                .tracking(4)
            Rectangle().fill(alertColor).frame(width: 30, height: 1)
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
        .padding(.bottom, 24)
    }
    
    private var iconView: some View {
        ZStack {
            HexagonShape()
                .stroke(alertColor.opacity(0.4), lineWidth: 2)
                .frame(width: 100, height: 100)
            
            HexagonShape()
                .fill(alertColor.opacity(0.1))
                .frame(width: 96, height: 96)
            
            Image(systemName: alertIcon)
                .font(.system(size: 40, weight: .medium))
                .foregroundColor(alertColor)
                .neonGlowStrong(alertColor, radius: 8)
        }
        .transition(.scale.combined(with: .opacity))
        .padding(.bottom, 28)
    }
    
    private var titleView: some View {
        Text(title)
            .font(.system(size: 36, weight: .bold, design: .default))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .neonGlowStrong(alertColor, radius: 4)
            .transition(.opacity.combined(with: .move(edge: .bottom)))
            .padding(.horizontal, 60)
            .padding(.bottom, 12)
    }
    
    @ViewBuilder
    private var messageView: some View {
        if !message.isEmpty {
            Text(message)
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(Color.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .transition(.opacity)
                .padding(.horizontal, 80)
                .padding(.bottom, 32)
        }
    }
    
    // MARK: - Dismiss Button
    private var dismissButton: some View {
        VStack(spacing: 12) {
            // Progress bar
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 260, height: 8)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(alertColor)
                    .frame(width: 260 * dismissProgress, height: 8)
            }
            
            DismissButtonView(
                alertColor: alertColor,
                isHolding: $isHoldingDismiss,
                dismissProgress: $dismissProgress,
                label: l10n.s(.holdToDismiss),
                onCompleted: {
                    guard !hasDismissed else { return }
                    hasDismissed = true
                    animationTimer?.invalidate()
                    animationTimer = nil
                    onDismiss()
                }
            )
            
            Text(l10n.s(.holdInstruction))
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color.white.opacity(0.3))
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
    
    private var cornerDecorations: some View {
        VStack {
            HStack {
                CornerDecoration(color: alertColor)
                Spacer()
                CornerDecoration(color: alertColor).scaleEffect(x: -1, y: 1)
            }
            Spacer()
            HStack {
                CornerDecoration(color: alertColor).scaleEffect(x: 1, y: -1)
                Spacer()
                CornerDecoration(color: alertColor).scaleEffect(x: -1, y: -1)
            }
        }
        .padding(30)
    }
}

// MARK: - Custom Dismiss Button using NSView for reliable press tracking
struct DismissButtonView: NSViewRepresentable {
    let alertColor: Color
    @Binding var isHolding: Bool
    @Binding var dismissProgress: CGFloat
    let label: String
    let onCompleted: () -> Void
    
    func makeNSView(context: Context) -> NSButton {
        let button = HoldButton()
        button.title = label
        button.isBordered = false
        button.wantsLayer = true
        button.layer?.cornerRadius = 12
        button.layer?.borderWidth = 1.5
        
        let nsAlertColor = NSColor(alertColor)
        button.layer?.borderColor = nsAlertColor.withAlphaComponent(0.6).cgColor
        button.layer?.backgroundColor = nsAlertColor.withAlphaComponent(0.1).cgColor
        
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        button.attributedTitle = NSAttributedString(
            string: label,
            attributes: [
                .foregroundColor: nsAlertColor,
                .font: NSFont.monospacedSystemFont(ofSize: 14, weight: .bold),
                .paragraphStyle: style,
                .kern: 3.0
            ]
        )
        
        button.setContentHuggingPriority(.defaultLow, for: .horizontal)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 280),
            button.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        button.coordinator = context.coordinator
        return button
    }
    
    func updateNSView(_ nsView: NSButton, context: Context) {
        context.coordinator.onCompleted = onCompleted
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isHolding: $isHolding, dismissProgress: $dismissProgress, onCompleted: onCompleted)
    }
    
    class Coordinator {
        var isHolding: Binding<Bool>
        var dismissProgress: Binding<CGFloat>
        var onCompleted: () -> Void
        private var startTime: Date?
        private let holdDuration: TimeInterval = 2.0
        private var progressTimer: Timer?
        private var hasCompleted = false
        
        init(isHolding: Binding<Bool>, dismissProgress: Binding<CGFloat>, onCompleted: @escaping () -> Void) {
            self.isHolding = isHolding
            self.dismissProgress = dismissProgress
            self.onCompleted = onCompleted
        }
        
        func startHold() {
            guard !hasCompleted else { return }
            startTime = Date()
            isHolding.wrappedValue = true
            
            progressTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] timer in
                guard let self = self, let start = self.startTime else {
                    timer.invalidate()
                    return
                }
                let elapsed = Date().timeIntervalSince(start)
                let progress = min(1.0, elapsed / self.holdDuration)
                
                DispatchQueue.main.async {
                    self.dismissProgress.wrappedValue = CGFloat(progress)
                }
                
                if progress >= 1.0 {
                    timer.invalidate()
                    self.progressTimer = nil
                    self.hasCompleted = true
                    DispatchQueue.main.async {
                        self.onCompleted()
                    }
                }
            }
        }
        
        func endHold() {
            guard !hasCompleted else { return }
            progressTimer?.invalidate()
            progressTimer = nil
            startTime = nil
            isHolding.wrappedValue = false
            DispatchQueue.main.async {
                self.dismissProgress.wrappedValue = 0
            }
        }
        
        deinit {
            progressTimer?.invalidate()
        }
    }
}

class HoldButton: NSButton {
    var coordinator: DismissButtonView.Coordinator?
    
    override func mouseDown(with event: NSEvent) {
        coordinator?.startHold()
    }
    
    override func mouseUp(with event: NSEvent) {
        coordinator?.endHold()
    }
    
    override func mouseExited(with event: NSEvent) {
        coordinator?.endHold()
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        for area in trackingAreas { removeTrackingArea(area) }
        let area = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
        addTrackingArea(area)
    }
}

struct CornerDecoration: View {
    let color: Color
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle().fill(color.opacity(0.5)).frame(width: 40, height: 1.5)
            Rectangle().fill(color.opacity(0.5)).frame(width: 1.5, height: 40)
            Circle().fill(color).frame(width: 4, height: 4).offset(x: -1, y: -1)
        }
    }
}
