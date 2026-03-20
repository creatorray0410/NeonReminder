<p align="center">
  <img src="AppIcon.png" width="128" height="128" alt="Neon Reminder" style="border-radius: 24px;" />
</p>

<h1 align="center">Neon Reminder</h1>

<p align="center">
  <strong>A macOS native task manager that refuses to let you forget.</strong><br/>
  Full-screen forced alerts · Focus sessions · Habit tracking · Cyberpunk UI
</p>

<p align="center">
  <a href="https://github.com/CreatorRay0410/NeonReminder/releases/latest"><img src="https://img.shields.io/github/v/release/CreatorRay0410/NeonReminder?style=flat-square&color=00e5cc" alt="Release" /></a>
  <img src="https://img.shields.io/badge/platform-macOS%2014%2B-blue?style=flat-square" alt="Platform" />
  <img src="https://img.shields.io/badge/swift-6.2-orange?style=flat-square" alt="Swift" />
  <img src="https://img.shields.io/github/license/CreatorRay0410/NeonReminder?style=flat-square" alt="License" />
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#build-from-source">Build</a> •
  <a href="#中文说明">中文说明</a>
</p>

---

## Why Neon Reminder?

Regular notifications are easy to ignore — a small banner appears, you swipe it away, and the meeting starts without you. **Neon Reminder takes a different approach**: when it's time, a full-screen alert takes over your entire display. You **cannot** switch apps, click through it, or dismiss it accidentally. You must **long-press for 2 seconds** to acknowledge and close it. It's impossible to miss.

## Features

### Task Reminder
Create todos with deadlines and set advance reminder times (1 min to 1 hour before). Supports 4 priority levels — **Low**, **Medium**, **High**, and **Critical** — each with its own neon color. When the reminder fires, a full-screen forced alert blocks everything until you acknowledge it.

### Countdown Timer
Set a target time and watch a real-time countdown with a visual progress ring. When it reaches zero, the full-screen alert triggers automatically.

### Focus Session
Pomodoro-style focus timer with configurable duration (15–120 minutes). A persistent countdown bar stays visible at the top of the app. When the session ends, a forced alert reminds you to take a break.

### Habit Tracker
Create daily habits with optional reminder times. Track your streaks with a 7-day visual heatmap. Mark habits as complete each day and build consistency.

## The Alert System

The core of Neon Reminder is its **unmissable alert mechanism**:

| Feature | Detail |
|---------|--------|
| **Coverage** | Overlays all windows at `screenSaver` level |
| **Dismissal** | Requires a **2-second long press** — no accidental taps |
| **Visual Style** | Rotating neon rings, scan lines, pulse effects |
| **Priority Colors** | Cyan (Low) → Green (Medium) → Purple (High) → Magenta (Critical) |
| **Audio** | System alert sound on trigger |

## Installation

### Download (Recommended)

1. Go to the [Releases page](https://github.com/CreatorRay0410/NeonReminder/releases/latest)
2. Download `NeonReminder-v1.0.0.dmg`
3. Open the DMG and drag **Neon Reminder** to your Applications folder
4. On first launch, right-click the app → **Open** (required for unsigned apps)

> **Note:** This app is not signed with an Apple Developer certificate. macOS may show a warning on first launch. Go to **System Settings → Privacy & Security** and click **Open Anyway**.

### Build from Source

```bash
git clone https://github.com/CreatorRay0410/NeonReminder.git
cd NeonReminder
swift build -c release
./build.sh          # Builds .app bundle
open NeonReminder.app
```

## System Requirements

| Requirement | Minimum |
|-------------|---------|
| **macOS** | 14.0 Sonoma or later |
| **Architecture** | Apple Silicon (arm64) & Intel (x86_64) |
| **Memory** | ~110 MB RAM |
| **CPU** | 0.1–0.5% idle usage |

## Tech Stack

- **Swift 6.2** + **SwiftUI** — Modern declarative UI
- **AppKit** — Full-screen window management at `screenSaver` level
- **Swift Package Manager** — Zero external dependencies
- **UserDefaults** — Lightweight local data persistence

## Project Structure

```
NeonReminder/
├── Package.swift                  # SwiftPM configuration
├── build.sh                       # Build script (.app bundle)
├── build_dmg.sh                   # DMG installer builder
├── AppIcon.png                    # App icon source
├── Sources/
│   ├── NeonReminderApp.swift      # App entry point & window management
│   ├── Models.swift               # Data models (TodoItem, ReminderMode)
│   ├── DataStore.swift            # Persistence layer (UserDefaults)
│   ├── Localization.swift         # i18n — Chinese/English strings
│   ├── AlertManager.swift         # Timer monitoring & alert triggering
│   ├── FullScreenAlertView.swift  # Full-screen forced alert UI
│   ├── NeonTheme.swift            # Cyberpunk theme & shared components
│   ├── ContentView.swift          # Main layout with sidebar navigation
│   ├── TaskListView.swift         # Task reminder list & creation form
│   ├── CountdownView.swift        # Countdown timer with progress ring
│   ├── FocusView.swift            # Focus session (Pomodoro) mode
│   └── HabitView.swift            # Habit tracker with streak display
└── README.md
```

## Language Support

Neon Reminder supports **English** and **Chinese (简体中文)** with a one-click toggle in the sidebar. The language preference is saved and persists across launches.

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.

## License

This project is open source. See the repository for license details.

---

## 中文说明

**Neon Reminder** 是一款具有赛博朋克风格的 macOS 原生强制提醒应用。

### 核心理念

普通通知太容易被忽略 —— 一个小横幅弹出来，随手一划就没了，然后会议已经开始了你还不知道。Neon Reminder 采用完全不同的方式：到了提醒时间，一个全屏遮罩会覆盖你的整个屏幕，你**无法**切换应用、点击穿透或误触关闭。你必须**长按 2 秒**才能确认并关闭它。绝对不可能错过。

### 四大功能模式

| 模式 | 功能 |
|------|------|
| **任务提醒** | 创建待办事项，设置截止时间和提前提醒（1分钟~1小时），支持 4 级优先级 |
| **倒计时** | 设置目标时间，实时倒计时，归零时触发全屏提醒 |
| **专注模式** | 番茄钟式专注计时（15~120 分钟），结束时强制提醒休息 |
| **习惯打卡** | 每日习惯追踪，连续打卡统计，7 天可视化热力图 |

### 安装方式

**下载安装（推荐）：** 前往 [Release 页面](https://github.com/CreatorRay0410/NeonReminder/releases/latest) 下载 `.dmg` 文件，打开后将应用拖入 Applications 文件夹。首次打开需右键点击应用 → 打开。

**从源码编译：**
```bash
git clone https://github.com/CreatorRay0410/NeonReminder.git
cd NeonReminder
swift build -c release
./build.sh
open NeonReminder.app
```

### 系统要求

- macOS 14.0 (Sonoma) 或更高版本
- 支持 Apple Silicon 和 Intel 芯片

### 语言支持

应用内置中英文切换，在侧边栏底部一键切换，选择会自动保存。
