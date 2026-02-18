import CoreGraphics

/// 火柴人姿态：7 个关节点（头、躯干下、左肩、左手、右手、髋、左脚、右脚）
/// 坐标系：y 向上，原点在脚底中心
struct StickFigurePose {
    /// [头, 髋/躯干下, 左肩, 左手, 右手, 左脚, 右脚]
    var joints: [CGPoint]

    init(joints: [CGPoint]) {
        self.joints = joints
    }

    /// 站立
    static var standing: StickFigurePose {
        let h: CGFloat = 60
        return StickFigurePose(joints: [
            CGPoint(x: 0, y: h),           // 头
            CGPoint(x: 0, y: h * 0.55),    // 髋
            CGPoint(x: 0, y: h * 0.7),     // 左肩
            CGPoint(x: -12, y: h * 0.6),   // 左手
            CGPoint(x: 12, y: h * 0.6),   // 右手
            CGPoint(x: -6, y: 0),          // 左脚
            CGPoint(x: 6, y: 0)            // 右脚
        ])
    }

    /// 走路 - 可传入相位 0...1 做循环
    static func walking(phase: CGFloat) -> StickFigurePose {
        let h: CGFloat = 60
        let swing: CGFloat = sin(phase * .pi * 2) * 12
        let armSwing: CGFloat = sin(phase * .pi * 2) * 15
        return StickFigurePose(joints: [
            CGPoint(x: 0, y: h),
            CGPoint(x: 0, y: h * 0.55),
            CGPoint(x: 0, y: h * 0.7),
            CGPoint(x: -12 - armSwing, y: h * 0.6),
            CGPoint(x: 12 + armSwing, y: h * 0.6),
            CGPoint(x: -6 + swing, y: 0),
            CGPoint(x: 6 - swing, y: 0)
        ])
    }

    /// 坐下
    static var sitting: StickFigurePose {
        let h: CGFloat = 60
        return StickFigurePose(joints: [
            CGPoint(x: 0, y: h * 0.5),
            CGPoint(x: 0, y: h * 0.25),
            CGPoint(x: 0, y: h * 0.35),
            CGPoint(x: -8, y: h * 0.2),
            CGPoint(x: 8, y: h * 0.2),
            CGPoint(x: -15, y: 0),
            CGPoint(x: 15, y: 0)
        ])
    }

    /// 蹲下画圈
    static var crouching: StickFigurePose {
        let h: CGFloat = 60
        return StickFigurePose(joints: [
            CGPoint(x: 0, y: h * 0.35),
            CGPoint(x: 0, y: h * 0.15),
            CGPoint(x: -5, y: h * 0.2),
            CGPoint(x: -20, y: 0),
            CGPoint(x: 10, y: 0),
            CGPoint(x: -8, y: 0),
            CGPoint(x: 8, y: 0)
        ])
    }

    /// 举手挥手
    static func waving(phase: CGFloat) -> StickFigurePose {
        let h: CGFloat = 60
        let armY = h * 0.9 + sin(phase * .pi * 2) * 5
        return StickFigurePose(joints: [
            CGPoint(x: 0, y: h),
            CGPoint(x: 0, y: h * 0.55),
            CGPoint(x: 0, y: h * 0.7),
            CGPoint(x: 15, y: armY),
            CGPoint(x: 12, y: h * 0.6),
            CGPoint(x: -6, y: 0),
            CGPoint(x: 6, y: 0)
        ])
    }

    /// 跳跃
    static func jumping(phase: CGFloat) -> StickFigurePose {
        let h: CGFloat = 60
        let lift: CGFloat = 15 + sin(phase * .pi) * 20
        return StickFigurePose(joints: [
            CGPoint(x: 0, y: h + lift),
            CGPoint(x: 0, y: h * 0.55 + lift),
            CGPoint(x: 0, y: h * 0.7 + lift),
            CGPoint(x: -18, y: h * 0.5 + lift),
            CGPoint(x: 18, y: h * 0.5 + lift),
            CGPoint(x: -10, y: lift),
            CGPoint(x: 10, y: lift)
        ])
    }

    /// 撞墙后仰
    static var hitWall: StickFigurePose {
        let h: CGFloat = 60
        return StickFigurePose(joints: [
            CGPoint(x: 5, y: h * 0.9),
            CGPoint(x: 0, y: h * 0.5),
            CGPoint(x: -5, y: h * 0.65),
            CGPoint(x: -25, y: h * 0.4),
            CGPoint(x: 10, y: h * 0.5),
            CGPoint(x: -8, y: 5),
            CGPoint(x: 6, y: 0)
        ])
    }

    /// 睡觉（躺下）
    static var sleeping: StickFigurePose {
        let h: CGFloat = 60
        return StickFigurePose(joints: [
            CGPoint(x: 15, y: h * 0.2),
            CGPoint(x: 10, y: h * 0.15),
            CGPoint(x: 5, y: h * 0.18),
            CGPoint(x: -5, y: h * 0.1),
            CGPoint(x: 25, y: h * 0.1),
            CGPoint(x: 0, y: 0),
            CGPoint(x: 30, y: 0)
        ])
    }

    /// 太极 - 缓慢动作
    static func taiChi(phase: CGFloat) -> StickFigurePose {
        let h: CGFloat = 60
        let armAngle = phase * .pi
        return StickFigurePose(joints: [
            CGPoint(x: 0, y: h),
            CGPoint(x: 0, y: h * 0.55),
            CGPoint(x: 0, y: h * 0.7),
            CGPoint(x: -10 + cos(armAngle) * 15, y: h * 0.6 + sin(armAngle) * 10),
            CGPoint(x: 10 - cos(armAngle) * 15, y: h * 0.6 - sin(armAngle) * 10),
            CGPoint(x: -6, y: 0),
            CGPoint(x: 6, y: 0)
        ])
    }

    /// 瑜伽伸展
    static func yoga(phase: CGFloat) -> StickFigurePose {
        let h: CGFloat = 60
        let lift = sin(phase * .pi * 2) * 8
        return StickFigurePose(joints: [
            CGPoint(x: 0, y: h + lift),
            CGPoint(x: 0, y: h * 0.5 + lift),
            CGPoint(x: -5, y: h * 0.65),
            CGPoint(x: -20, y: h * 0.8 + lift),
            CGPoint(x: 20, y: h * 0.8 + lift),
            CGPoint(x: -15, y: 0),
            CGPoint(x: 15, y: 0)
        ])
    }

    /// 空气投篮
    static func airShot(phase: CGFloat) -> StickFigurePose {
        let h: CGFloat = 60
        let armUp = phase < 0.5 ? phase * 2 : 1 - (phase - 0.5) * 2
        return StickFigurePose(joints: [
            CGPoint(x: 0, y: h),
            CGPoint(x: 0, y: h * 0.55),
            CGPoint(x: 0, y: h * 0.7),
            CGPoint(x: 18, y: h * 0.9 * (1 - armUp) + h * 0.5 * armUp),
            CGPoint(x: 12, y: h * 0.6),
            CGPoint(x: -6, y: 0),
            CGPoint(x: 6, y: 0)
        ])
    }

    /// 翻跟头
    static func flip(phase: CGFloat) -> StickFigurePose {
        let h: CGFloat = 60
        let angle = phase * .pi * 2
        let r: CGFloat = 25
        let cx: CGFloat = 0, cy: CGFloat = h * 0.5
        let headP = CGPoint(x: cx + cos(angle) * r, y: cy + sin(angle) * r)
        let hipP = CGPoint(x: cx + cos(angle + .pi * 0.5) * r, y: cy + sin(angle + .pi * 0.5) * r)
        return StickFigurePose(joints: [
            headP,
            hipP,
            CGPoint(x: (headP.x + hipP.x) / 2, y: (headP.y + hipP.y) / 2),
            CGPoint(x: headP.x - 15, y: headP.y),
            CGPoint(x: headP.x + 15, y: headP.y),
            CGPoint(x: hipP.x - 10, y: hipP.y - 15),
            CGPoint(x: hipP.x + 10, y: hipP.y - 15)
        ])
    }

    /// 劈叉
    static var split: StickFigurePose {
        let h: CGFloat = 60
        return StickFigurePose(joints: [
            CGPoint(x: 0, y: h),
            CGPoint(x: 0, y: h * 0.4),
            CGPoint(x: 0, y: h * 0.65),
            CGPoint(x: -12, y: h * 0.5),
            CGPoint(x: 12, y: h * 0.5),
            CGPoint(x: -40, y: 0),
            CGPoint(x: 40, y: 0)
        ])
    }

    /// 跳舞
    static func dance(phase: CGFloat) -> StickFigurePose {
        let h: CGFloat = 60
        let bounce = sin(phase * .pi * 4) * 5
        let armSwing = sin(phase * .pi * 4) * 20
        return StickFigurePose(joints: [
            CGPoint(x: armSwing * 0.2, y: h + bounce),
            CGPoint(x: 0, y: h * 0.55 + bounce),
            CGPoint(x: 0, y: h * 0.7 + bounce),
            CGPoint(x: -15 - armSwing, y: h * 0.6 + bounce),
            CGPoint(x: 15 + armSwing, y: h * 0.6 + bounce),
            CGPoint(x: -8 - armSwing * 0.3, y: bounce),
            CGPoint(x: 8 + armSwing * 0.3, y: bounce)
        ])
    }

    /// 低头垂泪
    static var bowHead: StickFigurePose {
        let h: CGFloat = 60
        return StickFigurePose(joints: [
            CGPoint(x: 0, y: h * 0.9),
            CGPoint(x: 0, y: h * 0.5),
            CGPoint(x: -5, y: h * 0.65),
            CGPoint(x: -20, y: h * 0.4),
            CGPoint(x: 10, y: h * 0.55),
            CGPoint(x: -8, y: 0),
            CGPoint(x: 8, y: 0)
        ])
    }

    /// 打伞
    static var umbrella: StickFigurePose {
        let h: CGFloat = 60
        return StickFigurePose(joints: [
            CGPoint(x: 0, y: h),
            CGPoint(x: 0, y: h * 0.55),
            CGPoint(x: 0, y: h * 0.75),
            CGPoint(x: 25, y: h * 1.1),
            CGPoint(x: 8, y: h * 0.6),
            CGPoint(x: -6, y: 0),
            CGPoint(x: 6, y: 0)
        ])
    }

    /// 抱头蹲下
    static var crouchCover: StickFigurePose {
        let h: CGFloat = 60
        return StickFigurePose(joints: [
            CGPoint(x: 0, y: h * 0.25),
            CGPoint(x: 0, y: h * 0.1),
            CGPoint(x: -8, y: h * 0.2),
            CGPoint(x: -15, y: h * 0.35),
            CGPoint(x: -15, y: h * 0.35),
            CGPoint(x: -10, y: 0),
            CGPoint(x: 10, y: 0)
        ])
    }

    /// 惊吓跳起
    static var startledJump: StickFigurePose {
        let h: CGFloat = 60
        return StickFigurePose(joints: [
            CGPoint(x: 0, y: h + 25),
            CGPoint(x: 0, y: h * 0.5 + 25),
            CGPoint(x: -15, y: h * 0.6 + 25),
            CGPoint(x: -30, y: h * 0.5 + 25),
            CGPoint(x: 20, y: h * 0.5 + 25),
            CGPoint(x: -12, y: 20),
            CGPoint(x: 12, y: 20)
        ])
    }

    /// 擦汗
    static var wipeSweat: StickFigurePose {
        let h: CGFloat = 60
        return StickFigurePose(joints: [
            CGPoint(x: 0, y: h),
            CGPoint(x: 0, y: h * 0.55),
            CGPoint(x: 5, y: h * 0.75),
            CGPoint(x: 15, y: h * 0.95),
            CGPoint(x: 12, y: h * 0.6),
            CGPoint(x: -6, y: 0),
            CGPoint(x: 6, y: 0)
        ])
    }

    /// 哈气
    static var exhale: StickFigurePose {
        let h: CGFloat = 60
        return StickFigurePose(joints: [
            CGPoint(x: 0, y: h),
            CGPoint(x: 0, y: h * 0.55),
            CGPoint(x: 0, y: h * 0.7),
            CGPoint(x: -10, y: h * 0.65),
            CGPoint(x: 10, y: h * 0.65),
            CGPoint(x: -6, y: 0),
            CGPoint(x: 6, y: 0)
        ])
    }

    /// 缩成一团
    static var curlUp: StickFigurePose {
        let h: CGFloat = 60
        return StickFigurePose(joints: [
            CGPoint(x: 0, y: h * 0.2),
            CGPoint(x: 0, y: h * 0.08),
            CGPoint(x: -5, y: h * 0.12),
            CGPoint(x: -15, y: 0),
            CGPoint(x: 5, y: h * 0.1),
            CGPoint(x: -12, y: 0),
            CGPoint(x: 12, y: 0)
        ])
    }

    /// 搓手
    static func rubHands(phase: CGFloat) -> StickFigurePose {
        let h: CGFloat = 60
        let dx = sin(phase * .pi * 4) * 5
        return StickFigurePose(joints: [
            CGPoint(x: 0, y: h),
            CGPoint(x: 0, y: h * 0.55),
            CGPoint(x: 0, y: h * 0.65),
            CGPoint(x: -15 + dx, y: h * 0.5),
            CGPoint(x: 15 - dx, y: h * 0.5),
            CGPoint(x: -6, y: 0),
            CGPoint(x: 6, y: 0)
        ])
    }

    /// 接雪花 / 接雨滴
    static var catchSnow: StickFigurePose {
        let h: CGFloat = 60
        return StickFigurePose(joints: [
            CGPoint(x: 0, y: h),
            CGPoint(x: 0, y: h * 0.55),
            CGPoint(x: 0, y: h * 0.7),
            CGPoint(x: -18, y: h * 0.95),
            CGPoint(x: 18, y: h * 0.95),
            CGPoint(x: -6, y: 0),
            CGPoint(x: 6, y: 0)
        ])
    }

    /// 倒立
    static var handstand: StickFigurePose {
        let h: CGFloat = 60
        return StickFigurePose(joints: [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 0, y: h * 0.45),
            CGPoint(x: 0, y: h * 0.2),
            CGPoint(x: -12, y: -5),
            CGPoint(x: 12, y: -5),
            CGPoint(x: -8, y: h),
            CGPoint(x: 8, y: h)
        ])
    }

    /// 翻滚
    static func roll(phase: CGFloat) -> StickFigurePose {
        let h: CGFloat = 60
        let angle = phase * .pi * 2
        let r: CGFloat = 20
        return StickFigurePose(joints: [
            CGPoint(x: cos(angle) * r, y: h * 0.5 + sin(angle) * r),
            CGPoint(x: cos(angle + .pi * 0.5) * r, y: h * 0.5 + sin(angle + .pi * 0.5) * r),
            CGPoint(x: 0, y: h * 0.5),
            CGPoint(x: -12, y: h * 0.4),
            CGPoint(x: 12, y: h * 0.4),
            CGPoint(x: -10, y: 0),
            CGPoint(x: 10, y: 0)
        ])
    }

    /// 昂首挺胸
    static var standProud: StickFigurePose {
        let h: CGFloat = 60
        return StickFigurePose(joints: [
            CGPoint(x: 0, y: h + 3),
            CGPoint(x: 0, y: h * 0.6),
            CGPoint(x: 0, y: h * 0.75),
            CGPoint(x: -15, y: h * 0.5),
            CGPoint(x: 15, y: h * 0.5),
            CGPoint(x: -6, y: 0),
            CGPoint(x: 6, y: 0)
        ])
    }

    /// 贴墙站立
    static var edgeHold: StickFigurePose {
        let h: CGFloat = 60
        return StickFigurePose(joints: [
            CGPoint(x: 5, y: h),
            CGPoint(x: 5, y: h * 0.55),
            CGPoint(x: 5, y: h * 0.7),
            CGPoint(x: -5, y: h * 0.6),
            CGPoint(x: 5, y: h * 0.6),
            CGPoint(x: -2, y: 0),
            CGPoint(x: 8, y: 0)
        ])
    }

    /// 无实物表演：凭空弹琴 / 投篮 / 通用
    static func airPerformance(phase: CGFloat, kind: AirPerformanceKind) -> StickFigurePose {
        let h: CGFloat = 60
        let armAngle = sin(phase * .pi * 2) * 0.3
        switch kind {
        case .piano:
            return StickFigurePose(joints: [
                CGPoint(x: 0, y: h),
                CGPoint(x: 0, y: h * 0.5),
                CGPoint(x: 0, y: h * 0.65),
                CGPoint(x: -25, y: h * 0.55 + armAngle * 10),
                CGPoint(x: 25, y: h * 0.55 + armAngle * 10),
                CGPoint(x: -6, y: 0),
                CGPoint(x: 6, y: 0)
            ])
        case .basketball:
            return StickFigurePose(joints: [
                CGPoint(x: 0, y: h),
                CGPoint(x: 0, y: h * 0.55),
                CGPoint(x: 0, y: h * 0.7),
                CGPoint(x: 20, y: h * 0.85),
                CGPoint(x: 12, y: h * 0.6),
                CGPoint(x: -6, y: 0),
                CGPoint(x: 6, y: 0)
            ])
        case .generic:
            return StickFigurePose(joints: [
                CGPoint(x: 0, y: h),
                CGPoint(x: 0, y: h * 0.55),
                CGPoint(x: 0, y: h * 0.7),
                CGPoint(x: -15 + armAngle * 20, y: h * 0.65),
                CGPoint(x: 15 - armAngle * 20, y: h * 0.65),
                CGPoint(x: -6, y: 0),
                CGPoint(x: 6, y: 0)
            ])
        }
    }
}

enum AirPerformanceKind {
    case piano, basketball, generic
}
