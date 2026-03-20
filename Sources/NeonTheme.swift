import SwiftUI

// MARK: - Neon Color Theme
struct NeonColors {
    static let cyan = Color(red: 0.0, green: 0.95, blue: 1.0)
    static let magenta = Color(red: 1.0, green: 0.0, blue: 0.8)
    static let purple = Color(red: 0.6, green: 0.2, blue: 1.0)
    static let green = Color(red: 0.0, green: 1.0, blue: 0.6)
    static let orange = Color(red: 1.0, green: 0.5, blue: 0.0)
    static let red = Color(red: 1.0, green: 0.15, blue: 0.3)
    static let blue = Color(red: 0.2, green: 0.5, blue: 1.0)
    static let yellow = Color(red: 1.0, green: 0.9, blue: 0.0)
    
    static let bgDark = Color(red: 0.04, green: 0.04, blue: 0.08)
    static let bgCard = Color(red: 0.08, green: 0.08, blue: 0.14)
    static let bgCardHover = Color(red: 0.10, green: 0.10, blue: 0.18)
    static let bgSurface = Color(red: 0.06, green: 0.06, blue: 0.11)
    static let textPrimary = Color.white
    static let textSecondary = Color(white: 0.55)
    static let border = Color(white: 0.15)
    
    static let gradientCyan = LinearGradient(
        colors: [cyan, cyan.opacity(0.6)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let gradientMagenta = LinearGradient(
        colors: [magenta, purple],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let gradientGreen = LinearGradient(
        colors: [green, cyan],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    
    static func priorityColor(_ priority: Priority) -> Color {
        switch priority {
        case .low: return green
        case .medium: return blue
        case .high: return orange
        case .critical: return red
        }
    }
}

// MARK: - Neon Glow Modifier
// PERFORMANCE: Only apply shadow on key elements (titles, icons in alert).
// For normal UI elements, neonGlow is now a no-op by default.
// Use neonGlowStrong for the few places that truly need a glow effect.
struct NeonGlow: ViewModifier {
    let color: Color
    let radius: CGFloat
    
    func body(content: Content) -> some View {
        // Lightweight: just return content with no shadow for normal UI
        content
    }
}

struct NeonGlowStrong: ViewModifier {
    let color: Color
    let radius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.5), radius: radius, x: 0, y: 0)
    }
}

extension View {
    /// Lightweight neon glow - no GPU cost, used for most UI elements
    func neonGlow(_ color: Color, radius: CGFloat = 8) -> some View {
        modifier(NeonGlow(color: color, radius: radius))
    }
    
    /// Strong neon glow with actual shadow - use sparingly, only for key elements
    func neonGlowStrong(_ color: Color, radius: CGFloat = 8) -> some View {
        modifier(NeonGlowStrong(color: color, radius: radius))
    }
}

// MARK: - Neon Card Style
struct NeonCard: ViewModifier {
    var borderColor: Color = NeonColors.cyan
    var showBorder: Bool = true
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(NeonColors.bgCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                showBorder ? borderColor.opacity(0.3) : Color.clear,
                                lineWidth: 1
                            )
                    )
            )
    }
}

extension View {
    func neonCard(borderColor: Color = NeonColors.cyan, showBorder: Bool = true) -> some View {
        modifier(NeonCard(borderColor: borderColor, showBorder: showBorder))
    }
}

// MARK: - Neon Button Style
struct NeonButtonStyle: ButtonStyle {
    let color: Color
    let isSmall: Bool
    
    init(color: Color = NeonColors.cyan, isSmall: Bool = false) {
        self.color = color
        self.isSmall = isSmall
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(isSmall ? .caption.bold() : .body.bold())
            .foregroundColor(.white)
            .padding(.horizontal, isSmall ? 12 : 20)
            .padding(.vertical, isSmall ? 6 : 10)
            .background(
                RoundedRectangle(cornerRadius: isSmall ? 8 : 12)
                    .fill(color.opacity(configuration.isPressed ? 0.4 : 0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: isSmall ? 8 : 12)
                            .stroke(color.opacity(0.8), lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Animated Neon Border (static gradient, no animation)
struct AnimatedNeonBorder: View {
    let color: Color
    let cornerRadius: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .stroke(
                AngularGradient(
                    gradient: Gradient(colors: [
                        color, color.opacity(0.3), .clear, .clear,
                        color.opacity(0.3), color
                    ]),
                    center: .center
                ),
                lineWidth: 2
            )
    }
}

// MARK: - Pulse Animation (static glow, no animation)
struct PulseAnimation: ViewModifier {
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Circle()
                    .stroke(color.opacity(0.3), lineWidth: 1.5)
                    .scaleEffect(1.5)
            )
    }
}

extension View {
    func pulseEffect(color: Color = NeonColors.cyan) -> some View {
        modifier(PulseAnimation(color: color))
    }
}

// MARK: - Grid Background (rendered once as a static image layer)
struct GridBackground: View {
    let lineColor: Color
    let spacing: CGFloat
    
    init(lineColor: Color = NeonColors.cyan.opacity(0.05), spacing: CGFloat = 30) {
        self.lineColor = lineColor
        self.spacing = spacing
    }
    
    var body: some View {
        Canvas { context, size in
            // Vertical lines
            var x: CGFloat = 0
            while x < size.width {
                let path = Path { p in
                    p.move(to: CGPoint(x: x, y: 0))
                    p.addLine(to: CGPoint(x: x, y: size.height))
                }
                context.stroke(path, with: .color(lineColor), lineWidth: 0.5)
                x += spacing
            }
            // Horizontal lines
            var y: CGFloat = 0
            while y < size.height {
                let path = Path { p in
                    p.move(to: CGPoint(x: 0, y: y))
                    p.addLine(to: CGPoint(x: size.width, y: y))
                }
                context.stroke(path, with: .color(lineColor), lineWidth: 0.5)
                y += spacing
            }
        }
        .drawingGroup()
        .allowsHitTesting(false)
    }
}

// MARK: - Hexagon Shape
struct HexagonShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        var path = Path()
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3 - .pi / 6
            let point = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
            if i == 0 { path.move(to: point) }
            else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Time Display Helper
struct TimeFormatter {
    private static let shortTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()
    
    private static let dateTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm"
        return f
    }()
    
    static func formatTimeRemaining(_ interval: TimeInterval) -> String {
        if interval <= 0 { return "00:00:00" }
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    static func formatShortTime(_ date: Date) -> String {
        shortTimeFormatter.string(from: date)
    }
    
    static func formatDateTime(_ date: Date) -> String {
        dateTimeFormatter.string(from: date)
    }
    
    static func formatRelative(_ date: Date) -> String {
        let interval = date.timeIntervalSinceNow
        if interval < 0 { return "Overdue" }
        if interval < 60 { return "< 1 min" }
        if interval < 3600 { return "\(Int(interval / 60)) min" }
        if interval < 86400 { return "\(Int(interval / 3600))h \(Int((interval.truncatingRemainder(dividingBy: 3600)) / 60))m" }
        return "\(Int(interval / 86400))d"
    }
}

// MARK: - Field Label (shared component)
struct FieldLabel: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .bold, design: .monospaced))
            .foregroundColor(NeonColors.textSecondary)
            .tracking(2)
    }
}
