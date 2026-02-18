# Stuck

极简主义 iOS 挂机观察类游戏。火柴人在纯色背景上按性格随机活动，用户仅作观察。

## 技术栈

- Swift 5 / UIKit / SpriteKit
- iOS 16+
- Game Center、iCloud Key-Value、Photos、Core Location

## 项目结构

```
Stuck/
├── App/           # AppDelegate、SceneDelegate、GameViewController
├── Scene/         # GameScene
├── Character/     # 火柴人渲染、骨骼、姿态
├── Behavior/      # 状态机、路径引擎
├── Weight/        # 权重引擎、MBTI 配置、天气修正、性格漂移
├── Environment/   # 天气、电量、时间
├── Haptic/        # 触觉反馈
├── Persistence/   # 本地存储、iCloud 前世
├── Achievement/   # Game Center 成就
└── Screenshot/    # 截屏日记
```

## 构建

1. 用 Xcode 打开 `Stuck.xcodeproj`
2. 在 Signing 中配置 Team
3. 在 Capabilities 中启用：
   - Game Center
   - iCloud (Key-Value storage)
4. 在 App Store Connect 创建对应成就 ID（与 `AchievementService` 中一致）

## 核心机制

- **16 型 MBTI** 决定路径权重、停顿频率、特殊动作、触觉风格
- **天气** 修正行为权重，背景色随天气微调
- **时间** 0–6 点移动概率降低，14–18 点最活跃
- **电量** 低电量时减速、线条变灰，充电中 +10% 速度
