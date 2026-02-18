import CoreGraphics

/// 火柴人姿态（Antony74 风格）：根节点 pelvis 位置 + 11 个 heading
/// heading = 从该顶点指向父顶点的方向角（弧度），SpriteKit 中 0=右，π/2=上
struct StickFigurePose {

    /// pelvis（髋）世界坐标
    var pelvis: CGPoint

    /// 各段长度（与 Antony74 一致，全为 size）
    var segmentLength: CGFloat

    /// [左膝, 右膝, 左脚, 右脚, 胸, 颈, 头, 左肘, 右肘, 左手, 右手] 的 heading
    var headings: [CGFloat]

    init(pelvis: CGPoint, segmentLength: CGFloat, headings: [CGFloat]) {
        self.pelvis = pelvis
        self.segmentLength = segmentLength
        self.headings = headings
    }

    /// 计算 12 个顶点的世界坐标（用于绘制）
    func joints() -> [CGPoint] {
        let m = segmentLength
        let h = headings
        guard h.count >= 11 else { return [] }

        func add(_ p: CGPoint, heading: CGFloat, mag: CGFloat) -> CGPoint {
            CGPoint(x: p.x + cos(heading) * mag, y: p.y + sin(heading) * mag)
        }

        let pPelvis = pelvis
        let pLeftKnee = add(pPelvis, heading: h[0], mag: m)
        let pRightKnee = add(pPelvis, heading: h[1], mag: m)
        let pLeftFoot = add(pLeftKnee, heading: h[2], mag: m)
        let pRightFoot = add(pRightKnee, heading: h[3], mag: m)
        let pChest = add(pPelvis, heading: h[4], mag: m)
        let pNeck = add(pChest, heading: h[5], mag: m)
        let pHead = add(pNeck, heading: h[6], mag: m)
        let pLeftElbow = add(pNeck, heading: h[7], mag: m)
        let pRightElbow = add(pNeck, heading: h[8], mag: m)
        let pLeftHand = add(pLeftElbow, heading: h[9], mag: m)
        let pRightHand = add(pRightElbow, heading: h[10], mag: m)

        return [
            pPelvis, pLeftKnee, pRightKnee, pLeftFoot, pRightFoot,
            pChest, pNeck, pHead, pLeftElbow, pRightElbow, pLeftHand, pRightHand
        ]
    }

    /// 两姿态间线性插值（heading + pelvis）
    static func lerp(from a: StickFigurePose, to b: StickFigurePose, t: CGFloat) -> StickFigurePose {
        let u = min(max(t, 0), 1)
        var nh: [CGFloat] = []
        for i in 0..<min(a.headings.count, b.headings.count) {
            var da = b.headings[i] - a.headings[i]
            while da > .pi { da -= .pi * 2 }
            while da < -.pi { da += .pi * 2 }
            nh.append(a.headings[i] + da * u)
        }
        let np = CGPoint(
            x: a.pelvis.x + (b.pelvis.x - a.pelvis.x) * u,
            y: a.pelvis.y + (b.pelvis.y - a.pelvis.y) * u
        )
        return StickFigurePose(
            pelvis: np,
            segmentLength: a.segmentLength + (b.segmentLength - a.segmentLength) * u,
            headings: nh
        )
    }

    /// 纯侧面站立：左右肢体重叠为单侧可见
    static func standing(pelvis: CGPoint = .zero, size: CGFloat = 24) -> StickFigurePose {
        let down = -CGFloat.pi / 2
        return StickFigurePose(pelvis: pelvis, segmentLength: size, headings: [
            down, down, down, down,  // 膝、脚（重叠）
            CGFloat.pi / 2, CGFloat.pi / 2, CGFloat.pi / 2,
            -CGFloat.pi / 4, -CGFloat.pi / 4, -CGFloat.pi / 6, -CGFloat.pi / 6  // 肘、手（重叠）
        ])
    }

    /// 走路：phase ∈ [0,1]，纯侧面抬腿摆臂（前后摆动）
    static func walking(phase: CGFloat, pelvis: CGPoint = .zero, size: CGFloat = 24) -> StickFigurePose {
        let theta = phase * .pi * 2
        let down = -CGFloat.pi / 2
        let swing: CGFloat = 0.25  // 腿前后摆
        let armSwing: CGFloat = 0.35

        let leg = down + sin(theta) * swing
        let legFoot = down + sin(theta) * swing * 0.5
        let arm = -CGFloat.pi / 4 - sin(theta) * armSwing  // 手与腿反向
        let armHand = -CGFloat.pi / 6 - sin(theta) * armSwing * 0.5

        let tilt = sin(theta) * 0.02
        return StickFigurePose(pelvis: pelvis, segmentLength: size, headings: [
            leg, leg, legFoot, legFoot,
            CGFloat.pi / 2 + tilt, CGFloat.pi / 2, CGFloat.pi / 2,
            arm, arm, armHand, armHand
        ])
    }

    /// 坐下（侧面）
    static func sitting(pelvis: CGPoint = .zero, size: CGFloat = 24) -> StickFigurePose {
        let leg = CGFloat.pi / 3
        return StickFigurePose(pelvis: pelvis, segmentLength: size, headings: [
            leg, leg, leg * 0.5, leg * 0.5,
            CGFloat.pi / 2 - 0.2, CGFloat.pi / 2 - 0.1, CGFloat.pi / 2,
            leg * 0.8, leg * 0.8, leg * 0.5, leg * 0.5
        ])
    }

    /// 蹲下画圈（侧面）
    static func crouching(pelvis: CGPoint = .zero, size: CGFloat = 24) -> StickFigurePose {
        let leg = CGFloat.pi / 2
        return StickFigurePose(pelvis: pelvis, segmentLength: size, headings: [
            leg, leg, leg * 0.5, leg * 0.5,
            CGFloat.pi / 2 - 0.3, CGFloat.pi / 2 - 0.2, CGFloat.pi / 2,
            leg * 0.8, leg * 0.8, CGFloat.pi / 6, CGFloat.pi / 6
        ])
    }

    /// 挥手（侧面）
    static func waving(phase: CGFloat, pelvis: CGPoint = .zero, size: CGFloat = 24) -> StickFigurePose {
        let armUp = sin(phase * .pi * 2) * 0.5
        let arm = -CGFloat.pi / 2 - armUp
        return StickFigurePose(pelvis: pelvis, segmentLength: size, headings: [
            -CGFloat.pi / 2, -CGFloat.pi / 2, -CGFloat.pi / 2, -CGFloat.pi / 2,
            CGFloat.pi / 2, CGFloat.pi / 2, CGFloat.pi / 2,
            arm, arm, arm - 0.1, arm - 0.1
        ])
    }

    /// 跳跃（侧面）
    static func jumping(phase: CGFloat, pelvis: CGPoint = .zero, size: CGFloat = 24) -> StickFigurePose {
        let leg = CGFloat.pi / 4
        let arm = CGFloat.pi / 3
        return StickFigurePose(pelvis: pelvis, segmentLength: size, headings: [
            leg, leg, leg * 0.8, leg * 0.8,
            CGFloat.pi / 2, CGFloat.pi / 2, CGFloat.pi / 2,
            arm, arm, arm * 0.8, arm * 0.8
        ])
    }

    /// 撞墙后仰（侧面）
    static func hitWall(pelvis: CGPoint = .zero, size: CGFloat = 24) -> StickFigurePose {
        let leg = -CGFloat.pi / 8
        let arm = CGFloat.pi / 2
        return StickFigurePose(pelvis: pelvis, segmentLength: size, headings: [
            leg, leg, leg * 0.8, leg * 0.8,
            CGFloat.pi / 2 - 0.15, CGFloat.pi / 2 - 0.1, CGFloat.pi / 2 - 0.2,
            arm, arm, arm * 0.7, arm * 0.7
        ])
    }

    /// 睡觉（躺，侧面）
    static func sleeping(pelvis: CGPoint = .zero, size: CGFloat = 24) -> StickFigurePose {
        let leg = -CGFloat.pi / 2 - 0.2
        let arm = -CGFloat.pi * 0.7
        return StickFigurePose(pelvis: pelvis, segmentLength: size, headings: [
            leg, leg, leg, leg,
            -CGFloat.pi / 2, -CGFloat.pi / 2, -CGFloat.pi / 2,
            arm, arm, arm * 0.7, arm * 0.7
        ])
    }

    /// 太极（侧面）
    static func taiChi(phase: CGFloat, pelvis: CGPoint = .zero, size: CGFloat = 24) -> StickFigurePose {
        let a = sin(phase * .pi) * 0.2
        let arm = CGFloat.pi / 4 + a
        return StickFigurePose(pelvis: pelvis, segmentLength: size, headings: [
            -CGFloat.pi / 2, -CGFloat.pi / 2, -CGFloat.pi / 2, -CGFloat.pi / 2,
            CGFloat.pi / 2, CGFloat.pi / 2, CGFloat.pi / 2,
            arm, arm, arm * 0.5, arm * 0.5
        ])
    }

    /// 瑜伽（侧面）
    static func yoga(phase: CGFloat, pelvis: CGPoint = .zero, size: CGFloat = 24) -> StickFigurePose {
        let arm = -CGFloat.pi / 2 - sin(phase * .pi * 2) * 0.3
        return StickFigurePose(pelvis: pelvis, segmentLength: size, headings: [
            -CGFloat.pi / 2, -CGFloat.pi / 2, -CGFloat.pi / 2, -CGFloat.pi / 2,
            CGFloat.pi / 2, CGFloat.pi / 2, CGFloat.pi / 2,
            arm, arm, arm, arm
        ])
    }

    /// 空气投篮（侧面）
    static func airShot(phase: CGFloat, pelvis: CGPoint = .zero, size: CGFloat = 24) -> StickFigurePose {
        let up = phase < 0.5 ? phase * 2 : 1 - (phase - 0.5) * 2
        let arm = -CGFloat.pi / 2 - CGFloat(up) * .pi / 2
        return StickFigurePose(pelvis: pelvis, segmentLength: size, headings: [
            -CGFloat.pi / 2, -CGFloat.pi / 2, -CGFloat.pi / 2, -CGFloat.pi / 2,
            CGFloat.pi / 2, CGFloat.pi / 2, CGFloat.pi / 2,
            arm, arm, arm - 0.1, arm - 0.1
        ])
    }

    /// 翻跟头（侧面）
    static func flip(phase: CGFloat, pelvis: CGPoint = .zero, size: CGFloat = 24) -> StickFigurePose {
        let a = phase * .pi * 2
        let leg = CGFloat.pi / 2 + a * 0.5
        let arm = a + .pi / 4
        return StickFigurePose(pelvis: pelvis, segmentLength: size, headings: [
            leg, leg, leg * 0.8, leg * 0.8,
            a, a + .pi / 2, a + .pi,
            arm, arm, arm + .pi / 4, arm + .pi / 4
        ])
    }

    /// 劈叉（侧面：腿前后伸）
    static func split(pelvis: CGPoint = .zero, size: CGFloat = 24) -> StickFigurePose {
        let leg = -CGFloat.pi / 2 - 0.3
        let arm = CGFloat.pi / 4
        return StickFigurePose(pelvis: pelvis, segmentLength: size, headings: [
            leg, leg, leg, leg,
            CGFloat.pi / 2, CGFloat.pi / 2, CGFloat.pi / 2,
            arm, arm, arm * 0.5, arm * 0.5
        ])
    }

    /// 跳舞（侧面）
    static func dance(phase: CGFloat, pelvis: CGPoint = .zero, size: CGFloat = 24) -> StickFigurePose {
        let s = sin(phase * .pi * 4) * 0.25
        let leg = -CGFloat.pi / 2 + s
        let arm = -CGFloat.pi / 4 + s * 2
        return StickFigurePose(pelvis: pelvis, segmentLength: size, headings: [
            leg, leg, leg, leg,
            CGFloat.pi / 2 + s * 0.2, CGFloat.pi / 2, CGFloat.pi / 2,
            arm, arm, arm * 0.8, arm * 0.8
        ])
    }

    /// 低头垂泪（侧面）
    static func bowHead(pelvis: CGPoint = .zero, size: CGFloat = 24) -> StickFigurePose {
        let arm = CGFloat.pi / 2
        return StickFigurePose(pelvis: pelvis, segmentLength: size, headings: [
            -CGFloat.pi / 2, -CGFloat.pi / 2, -CGFloat.pi / 2, -CGFloat.pi / 2,
            CGFloat.pi / 2, CGFloat.pi / 2, CGFloat.pi / 2 - 0.15,
            arm, arm, arm * 0.7, arm * 0.7
        ])
    }

    /// 打伞（侧面）
    static func umbrella(pelvis: CGPoint = .zero, size: CGFloat = 24) -> StickFigurePose {
        let arm = -CGFloat.pi / 4
        return StickFigurePose(pelvis: pelvis, segmentLength: size, headings: [
            -CGFloat.pi / 2, -CGFloat.pi / 2, -CGFloat.pi / 2, -CGFloat.pi / 2,
            CGFloat.pi / 2, CGFloat.pi / 2, CGFloat.pi / 2 - 0.3,
            arm, arm, arm - 0.1, arm - 0.1
        ])
    }

    /// 抱头蹲下（侧面）
    static func crouchCover(pelvis: CGPoint = .zero, size: CGFloat = 24) -> StickFigurePose {
        let leg = CGFloat.pi / 2 - 0.2
        let arm = CGFloat.pi / 2
        return StickFigurePose(pelvis: pelvis, segmentLength: size, headings: [
            leg, leg, leg * 0.8, leg * 0.8,
            CGFloat.pi / 2 - 0.3, CGFloat.pi / 2 - 0.4, CGFloat.pi / 2 - 0.5,
            arm, arm, arm * 0.7, arm * 0.7
        ])
    }

    /// 惊吓跳起（侧面）
    static func startledJump(pelvis: CGPoint = .zero, size: CGFloat = 24) -> StickFigurePose {
        let leg = CGFloat.pi / 4
        let arm = CGFloat.pi / 2
        return StickFigurePose(pelvis: pelvis, segmentLength: size, headings: [
            leg, leg, leg, leg,
            CGFloat.pi / 2, CGFloat.pi / 2, CGFloat.pi / 2,
            arm, arm, arm, arm
        ])
    }

    /// 擦汗（侧面）
    static func wipeSweat(pelvis: CGPoint = .zero, size: CGFloat = 24) -> StickFigurePose {
        let arm = -CGFloat.pi / 3
        return StickFigurePose(pelvis: pelvis, segmentLength: size, headings: [
            -CGFloat.pi / 2, -CGFloat.pi / 2, -CGFloat.pi / 2, -CGFloat.pi / 2,
            CGFloat.pi / 2, CGFloat.pi / 2, CGFloat.pi / 2,
            arm, arm, arm - 0.1, arm - 0.1
        ])
    }

    /// 哈气（侧面）
    static func exhale(pelvis: CGPoint = .zero, size: CGFloat = 24) -> StickFigurePose {
        let arm = CGFloat.pi / 3
        return StickFigurePose(pelvis: pelvis, segmentLength: size, headings: [
            -CGFloat.pi / 2, -CGFloat.pi / 2, -CGFloat.pi / 2, -CGFloat.pi / 2,
            CGFloat.pi / 2, CGFloat.pi / 2, CGFloat.pi / 2,
            arm, arm, arm * 0.8, arm * 0.8
        ])
    }

    /// 缩成一团（侧面）
    static func curlUp(pelvis: CGPoint = .zero, size: CGFloat = 24) -> StickFigurePose {
        let leg = CGFloat.pi / 2 - 0.3
        let arm = CGFloat.pi / 2
        return StickFigurePose(pelvis: pelvis, segmentLength: size, headings: [
            leg, leg, leg, leg,
            CGFloat.pi / 2 - 0.2, CGFloat.pi / 2 - 0.3, CGFloat.pi / 2 - 0.5,
            arm, arm, arm, arm
        ])
    }

    /// 搓手（侧面）
    static func rubHands(phase: CGFloat, pelvis: CGPoint = .zero, size: CGFloat = 24) -> StickFigurePose {
        let s = sin(phase * .pi * 4) * 0.1
        let arm = CGFloat.pi / 4 + s
        return StickFigurePose(pelvis: pelvis, segmentLength: size, headings: [
            -CGFloat.pi / 2, -CGFloat.pi / 2, -CGFloat.pi / 2, -CGFloat.pi / 2,
            CGFloat.pi / 2, CGFloat.pi / 2, CGFloat.pi / 2,
            arm, arm, arm * 0.7, arm * 0.7
        ])
    }

    /// 接雪花（侧面）
    static func catchSnow(pelvis: CGPoint = .zero, size: CGFloat = 24) -> StickFigurePose {
        let arm = -CGFloat.pi / 2
        return StickFigurePose(pelvis: pelvis, segmentLength: size, headings: [
            -CGFloat.pi / 2, -CGFloat.pi / 2, -CGFloat.pi / 2, -CGFloat.pi / 2,
            CGFloat.pi / 2, CGFloat.pi / 2, CGFloat.pi / 2,
            arm, arm, arm, arm
        ])
    }

    /// 倒立（侧面）
    static func handstand(pelvis: CGPoint = .zero, size: CGFloat = 24) -> StickFigurePose {
        let leg = CGFloat.pi / 2 + 0.2
        let arm = CGFloat.pi
        return StickFigurePose(pelvis: pelvis, segmentLength: size, headings: [
            leg, leg, leg, leg,
            CGFloat.pi, CGFloat.pi, CGFloat.pi,
            arm * 0.6, arm * 0.6, arm * 0.8, arm * 0.8
        ])
    }

    /// 翻滚（侧面）
    static func roll(phase: CGFloat, pelvis: CGPoint = .zero, size: CGFloat = 24) -> StickFigurePose {
        let a = phase * .pi * 2
        let leg = CGFloat.pi / 2 + a
        let arm = CGFloat.pi / 4
        return StickFigurePose(pelvis: pelvis, segmentLength: size, headings: [
            leg, leg, leg, leg,
            CGFloat.pi / 2 + a * 0.5, CGFloat.pi / 2, CGFloat.pi / 2,
            arm, arm, arm * 0.5, arm * 0.5
        ])
    }

    /// 昂首挺胸（侧面）
    static func standProud(pelvis: CGPoint = .zero, size: CGFloat = 24) -> StickFigurePose {
        let arm = CGFloat.pi / 3
        return StickFigurePose(pelvis: pelvis, segmentLength: size, headings: [
            -CGFloat.pi / 2, -CGFloat.pi / 2, -CGFloat.pi / 2, -CGFloat.pi / 2,
            CGFloat.pi / 2, CGFloat.pi / 2, CGFloat.pi / 2 + 0.02,
            arm, arm, arm * 0.8, arm * 0.8
        ])
    }

    /// 贴墙（侧面）
    static func edgeHold(pelvis: CGPoint = .zero, size: CGFloat = 24) -> StickFigurePose {
        let arm = CGFloat.pi / 2 + 0.1
        return StickFigurePose(pelvis: pelvis, segmentLength: size, headings: [
            -CGFloat.pi / 2, -CGFloat.pi / 2, -CGFloat.pi / 2, -CGFloat.pi / 2,
            CGFloat.pi / 2, CGFloat.pi / 2, CGFloat.pi / 2,
            arm, arm, arm * 0.7, arm * 0.7
        ])
    }

    /// 无实物表演（侧面）
    static func airPerformance(phase: CGFloat, kind: AirPerformanceKind, pelvis: CGPoint = .zero, size: CGFloat = 24) -> StickFigurePose {
        let s = sin(phase * .pi * 2) * 0.1
        switch kind {
        case .piano:
            let arm = CGFloat.pi / 3 + s
            return StickFigurePose(pelvis: pelvis, segmentLength: size, headings: [
                -CGFloat.pi / 2, -CGFloat.pi / 2, -CGFloat.pi / 2, -CGFloat.pi / 2,
                CGFloat.pi / 2, CGFloat.pi / 2, CGFloat.pi / 2,
                arm, arm, arm * 0.8, arm * 0.8
            ])
        case .basketball:
            let arm = -CGFloat.pi / 4
            return StickFigurePose(pelvis: pelvis, segmentLength: size, headings: [
                -CGFloat.pi / 2, -CGFloat.pi / 2, -CGFloat.pi / 2, -CGFloat.pi / 2,
                CGFloat.pi / 2, CGFloat.pi / 2, CGFloat.pi / 2,
                arm, arm, arm * 0.8, arm * 0.8
            ])
        case .generic:
            let arm = CGFloat.pi / 4 + s
            return StickFigurePose(pelvis: pelvis, segmentLength: size, headings: [
                -CGFloat.pi / 2, -CGFloat.pi / 2, -CGFloat.pi / 2, -CGFloat.pi / 2,
                CGFloat.pi / 2, CGFloat.pi / 2, CGFloat.pi / 2,
                arm, arm, arm * 0.7, arm * 0.7
            ])
        }
    }
}

enum AirPerformanceKind {
    case piano, basketball, generic
}
