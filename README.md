# Neon Reminder

一款具有未来科技感 UI 的 Mac 原生强制提醒应用，使用 SwiftUI 构建。

## 功能特性

### 1. Task Reminder（任务提醒）
- 创建待办任务，设置截止时间和提前提醒时间
- 支持 4 级优先级：Low / Medium / High / Critical
- 到达提醒时间时，弹出**全屏强制提醒**，必须长按 2 秒才能关闭
- 任务列表实时显示剩余时间、是否逾期

### 2. Countdown Timer（倒计时）
- 设置目标时间，实时显示倒计时
- 倒计时归零时触发全屏强制提醒
- 可视化进度环显示

### 3. Focus Session（专注模式）
- 设置专注时长（15 分钟 ~ 120 分钟）
- 专注期间顶部显示实时倒计时
- 专注结束时触发全屏强制提醒

### 4. Habit Tracker（习惯打卡）
- 创建每日习惯，设置提醒时间
- 连续打卡天数统计
- 过去 7 天打卡可视化
- 可手动触发强制提醒

## 强制提醒系统

提醒弹出时：
- **全屏覆盖**，遮挡所有其他窗口
- 窗口层级为 `screenSaver`，无法被其他窗口遮挡
- 必须**长按 2 秒**才能关闭，防止误触
- 科幻风格动画：旋转光环、扫描线、脉冲效果
- 根据优先级显示不同颜色

## 运行方式

### 直接运行
```bash
open NeonReminder.app
```

### 重新编译
```bash
./build.sh          # Release 编译
./build.sh debug    # Debug 编译
```

## 系统要求

- macOS 14.0 (Sonoma) 或更高版本
- Apple Silicon (arm64)

## 技术栈

- Swift 6.2 + SwiftUI
- Swift Package Manager
- AppKit（全屏窗口管理）
- UserDefaults（数据持久化）

## 项目结构

```
NeonReminder/
├── Package.swift           # SwiftPM 配置
├── build.sh               # 构建脚本
├── NeonReminder.app/      # 编译好的应用
├── Sources/
│   ├── NeonReminderApp.swift    # 应用入口
│   ├── Models.swift             # 数据模型
│   ├── DataStore.swift          # 数据存储
│   ├── AlertManager.swift       # 提醒管理器
│   ├── NeonTheme.swift          # 主题和 UI 组件
│   ├── ContentView.swift        # 主界面
│   ├── TaskListView.swift       # 任务列表
│   ├── CountdownView.swift      # 倒计时
│   ├── FocusView.swift          # 专注模式
│   ├── HabitView.swift          # 习惯打卡
│   └── FullScreenAlertView.swift # 全屏提醒
└── README.md
```
