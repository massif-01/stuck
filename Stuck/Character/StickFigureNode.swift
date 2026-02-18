import SpriteKit

/// 火柴人（Antony74 风格）：12 顶点树、11 线段、椭圆头、加粗线条
final class StickFigureNode: SKNode {

    /// 线段节点（共 11 段）
    private var segments: [SKShapeNode] = []
    private let headShape = SKShapeNode()
    private var lastJoints: [CGPoint] = []

    var lineWidth: CGFloat = 6 {
        didSet { updateStroke() }
    }
    var strokeColor: UIColor = .black {
        didSet { updateStroke() }
    }
    var speedMultiplier: CGFloat = 1.0

    private let segmentLength: CGFloat = 24

    override init() {
        super.init()
        setupSegments()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSegments()
    }

    private func setupSegments() {
        for _ in 0..<11 {
            let s = SKShapeNode()
            s.strokeColor = strokeColor
            s.lineWidth = lineWidth
            s.lineCap = .round
            s.lineJoin = .round
            addChild(s)
            segments.append(s)
        }
        headShape.strokeColor = strokeColor
        headShape.lineWidth = 1
        headShape.fillColor = strokeColor
        headShape.glowWidth = 0
        addChild(headShape)
        applyPose(.standing(pelvis: .zero, size: segmentLength))
    }

    private func updateStroke() {
        segments.forEach {
            $0.strokeColor = strokeColor
            $0.lineWidth = lineWidth
        }
        headShape.strokeColor = strokeColor
        headShape.fillColor = strokeColor
    }

    /// 应用姿态（无插值）
    func applyPose(_ pose: StickFigurePose) {
        let j = pose.joints()
        lastJoints = j
        render(j)
    }

    /// 姿态插值
    func applyPoseWithInterpolation(
        target: StickFigurePose,
        duration: TimeInterval,
        completion: (() -> Void)? = nil
    ) {
        let startJoints = lastJoints.isEmpty ? target.joints() : lastJoints
        let startPelvis = startJoints.count > 0 ? startJoints[0] : target.pelvis
        let startPose = poseFromJoints(startJoints, pelvis: startPelvis, size: target.segmentLength)
        let actualDuration = duration / Double(speedMultiplier)

        let action = SKAction.customAction(withDuration: actualDuration) { [weak self] _, elapsed in
            guard let self = self else { return }
            var t = CGFloat(min(1, elapsed / actualDuration))
            t = t * t * (3 - 2 * t)
            let interp = StickFigurePose.lerp(from: startPose, to: target, t: t)
            self.lastJoints = interp.joints()
            self.render(self.lastJoints)
        }
        run(action) { completion?() }
    }

    private func poseFromJoints(_ j: [CGPoint], pelvis: CGPoint, size: CGFloat) -> StickFigurePose {
        guard j.count >= 12 else { return .standing(pelvis: pelvis, size: size) }
        func dir(parent: CGPoint, child: CGPoint) -> CGFloat { atan2(child.y - parent.y, child.x - parent.x) }
        return StickFigurePose(pelvis: pelvis, segmentLength: size, headings: [
            dir(parent: j[0], child: j[1]), dir(parent: j[0], child: j[2]),
            dir(parent: j[1], child: j[3]), dir(parent: j[2], child: j[4]),
            dir(parent: j[0], child: j[5]), dir(parent: j[5], child: j[6]),
            dir(parent: j[6], child: j[7]),
            dir(parent: j[6], child: j[8]), dir(parent: j[6], child: j[9]),
            dir(parent: j[8], child: j[10]), dir(parent: j[9], child: j[11])
        ])
    }

    private func render(_ j: [CGPoint]) {
        guard j.count >= 12 else { return }

        func line(_ a: CGPoint, _ b: CGPoint) -> CGPath {
            let p = CGMutablePath()
            p.move(to: a)
            p.addLine(to: b)
            return p
        }

        segments[0].path = line(j[0], j[1])
        segments[1].path = line(j[0], j[2])
        segments[2].path = line(j[1], j[3])
        segments[3].path = line(j[2], j[4])
        segments[4].path = line(j[0], j[5])
        segments[5].path = line(j[5], j[6])
        segments[6].path = line(j[6], j[7])
        segments[7].path = line(j[6], j[8])
        segments[8].path = line(j[6], j[9])
        segments[9].path = line(j[8], j[10])
        segments[10].path = line(j[9], j[11])

        // 纯侧面：头部为圆（以 head 为中心，半径约为 segment 的 0.5）
        let r = segmentLength * 0.5
        headShape.path = CGPath(ellipseIn: CGRect(x: j[7].x - r, y: j[7].y - r, width: r * 2, height: r * 2), transform: nil)
    }

    func animateToPose(_ target: StickFigurePose, duration: TimeInterval, completion: (() -> Void)? = nil) {
        applyPoseWithInterpolation(target: target, duration: duration, completion: completion)
    }
}
