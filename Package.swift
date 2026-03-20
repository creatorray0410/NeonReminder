// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NeonReminder",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "NeonReminder",
            path: "Sources"
        )
    ]
)
