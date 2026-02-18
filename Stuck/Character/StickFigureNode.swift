import SpriteKit

/// 火柴人：6 段线段（躯干、四肢、头），程序化骨骼动画
final class StickFigureNode: SKNode {

    private let head = SKShapeNode()
    private let torso = SKShapeNode()
    private let leftArm = SKShapeNode()
    private let rightArm = SKShapeNode()
    private let leftLeg = SKShapeNode()
    private let rightLeg = SKShapeNode()

    /// 线宽与颜色（低电量时变浅灰）
    var lineWidth: CGFloat = 2 {
        didSet { updateStrokeWidth() }
    }
    var strokeColor: UIColor = .black {
        didSet { updateStrokeColor() }
    }

    /// 速度倍率（电量、充电、性格影响）
    var speedMultiplier: CGFloat = 1.0

    private let segmentLength: CGFloat = 24
    private var joints: [CGPoint] = []

    override init() {
        super.init()
        setupSegments()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSegments()
    }

    private func setupSegments() {
        [head, torso, leftArm, rightArm, leftLeg, rightLeg].forEach {
            $0.strokeColor = strokeColor
            $0.lineWidth = lineWidth
            $0.lineCap = .round
            $0.lineJoin = .round
            addChild($0)
        }
        applyPose(.standing)
    }

    private func updateStrokeWidth() {
        [head, torso, leftArm, rightArm, leftLeg, rightLeg].forEach {
            $0.lineWidth = lineWidth
        }
    }

    private func updateStrokeColor() {
        [head, torso, leftArm, rightArm, leftLeg, rightLeg].forEach {
            $0.strokeColor = strokeColor
        }
    }

    /// 程序化绘制：根据关节点生成线段
    func applyPose(_ pose: StickFigurePose) {
        joints = pose.joints
        let j = joints

        // 头：圆心
        head.path = CGPath(ellipseIn: CGRect(
            x: j[0].x - 6, y: j[0].y - 6,
            width: 12, height: 12
        ), transform: nil)

        // 躯干：颈到髋
        torso.path = linePath(from: j[0], to: j[1])

        // 左臂：肩到左手
        leftArm.path = linePath(from: j[2], to: j[3])
        rightArm.path = linePath(from: j[2], to: j[4])

        // 左腿：髋到左脚，右腿同理
        leftLeg.path = linePath(from: j[1], to: j[5])
        rightLeg.path = linePath(from: j[1], to: j[6])
    }

    private func linePath(from a: CGPoint, to b: CGPoint) -> CGPath {
        let p = CGMutablePath()
        p.move(to: a)
        p.addLine(to: b)
        return p
    }

    /// 动画到目标姿态（程序化补间）
    func animateToPose(
        _ target: StickFigurePose,
        duration: TimeInterval,
        completion: (() -> Void)? = nil
    ) {
        let actualDuration = duration / Double(speedMultiplier)
        // 简化：直接应用目标姿态。完整版可用 SKAction 或自定义插值
        run(.sequence([
            .wait(forDuration: actualDuration),
            .run { [weak self] in
                self?.applyPose(target)
                completion?()
            }
        ]))
        applyPose(target)
    }
}
