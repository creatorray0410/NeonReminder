import SwiftUI
import AppKit

@main
struct NeonReminderApp: App {
    @StateObject private var store = DataStore()
    @StateObject private var alertManager = AlertManager()
    @StateObject private var l10n = LocalizationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(alertManager)
                .environmentObject(l10n)
                .frame(minWidth: 900, minHeight: 620)
                .background(NeonColors.bgDark)
                .preferredColorScheme(.dark)
                .onAppear {
                    alertManager.store = store
                    alertManager.l10n = l10n
                    alertManager.startMonitoring()
                    configureWindow()
                }
                .onDisappear {
                    alertManager.stopMonitoring()
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentMinSize)
        .defaultSize(width: 1100, height: 720)
    }
    
    private func configureWindow() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let window = NSApplication.shared.windows.first {
                window.isOpaque = false
                window.backgroundColor = NSColor(red: 0.04, green: 0.04, blue: 0.08, alpha: 1.0)
                window.titlebarAppearsTransparent = true
                window.titleVisibility = .hidden
                window.styleMask.insert(.fullSizeContentView)
            }
        }
    }
}
