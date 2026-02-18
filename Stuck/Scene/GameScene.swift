import SpriteKit

final class GameScene: SKScene {

    private var stickFigure: StickFigureNode!
    private var pathEngine: PathEngine!
    private var weightEngine: WeightEngine!
    private var currentPosition: CGPoint = .zero
    private var currentDirection: CGFloat = 0
    private var isAnimating = false

    override func didMove(to view: SKView) {
        backgroundColor = backgroundColorForWeather(WeatherService.shared.currentCondition)

        PersonalityService.initializeIfNeeded()

        let bounds = CGRect(origin: .zero, size: size)
        pathEngine = PathEngine(bounds: bounds)
        let weather = WeatherService.shared
        weather.refresh()
        var weatherMods: [PathType: Int] = [:]
        for (path, delta) in WeatherModifiers.pathModifiers(for: weather.currentCondition) {
            weatherMods[path, default: 0] += delta
        }
        let mbti = PersonalityService.currentMBTI
        weightEngine = WeightEngine(
            mbti: mbti,
            weatherModifiers: weatherMods,
            timeCoefficient: TimeService.shared.coefficient,
            batteryModifier: BatteryService.shared.speedModifier,
            weatherCondition: weather.currentCondition
        )

        stickFigure = StickFigureNode()
        stickFigure.speedMultiplier = CGFloat(BatteryService.shared.speedModifier)
        stickFigure.strokeColor = BatteryService.shared.isLowPower ? UIColor(red: 0.83, green: 0.83, blue: 0.83, alpha: 1) : .black
        stickFigure.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(stickFigure)
        currentPosition = stickFigure.position

        ScreenshotDiaryService.shared.scene = self
        scheduleNextBehavior()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        pathEngine = PathEngine(bounds: CGRect(origin: .zero, size: size))
    }

    private func scheduleNextBehavior() {
        guard !isAnimating else { return }

        let state = weightEngine.selectMacroState()

        switch state {
        case .moving:
            executeMove()
        case .idle:
            executeIdle()
        case .special:
            executeSpecial()
        }
    }

    private func executeMove() {
        isAnimating = true
        let pathType = weightEngine.selectPath()
        let points = pathEngine.generatePath(
            type: pathType,
            from: currentPosition,
            direction: currentDirection
        )
        guard points.count >= 2 else {
            isAnimating = false
            scheduleNextBehavior()
            return
        }

        var sequence: [SKAction] = []
        for i in 1..<points.count {
            let to = points[i]
            let dist = hypot(to.x - currentPosition.x, to.y - currentPosition.y)
            let duration = TimeInterval(dist / 80)
            currentDirection = atan2(to.y - currentPosition.y, to.x - currentPosition.x)
            sequence.append(.move(to: to, duration: duration))
            currentPosition = to
        }

        stickFigure.run(.sequence(sequence)) { [weak self] in
            if let w = self?.weightEngine {
                let style = MBTIConfig.config(for: w.mbti).hapticStyle
                HapticService.trigger(
                    action: .walk,
                    mbtiStyle: .init(rawValue: style.rawValue) ?? .soft
                )
            }
            if pathType == .burst || pathType == .sprint {
                AchievementTracker.shared.recordWallHit()
            }
            self?.isAnimating = false
            self?.scheduleNextBehavior()
        }

        // 走路姿态循环
        animateWalking(duration: sequence.reduce(0) { $0 + ($1.duration) })
    }

    private func animateWalking(duration: TimeInterval) {
        let steps = max(2, Int(duration / 0.15))
        for i in 0..<steps {
            stickFigure.run(.sequence([
                .wait(forDuration: Double(i) * 0.15),
                .run { [weak self] in
                    self?.stickFigure.applyPose(.walking(phase: CGFloat(i % 2) * 0.5))
                }
            ]))
        }
    }

    private func executeIdle() {
        isAnimating = true
        let config = MBTIConfig.config(for: weightEngine.mbti)
        let action = weightEngine.selectAction(from: config.specialActions + [.sit, .stare])
            ?? .stare

        stickFigure.applyPose(poseForAction(action))
        let duration = Double.random(in: 2...5)
        stickFigure.run(.wait(forDuration: duration)) { [weak self] in
            self?.isAnimating = false
            self?.scheduleNextBehavior()
        }
    }

    private func executeSpecial() {
        isAnimating = true
        let config = MBTIConfig.config(for: weightEngine.mbti)
        let action = weightEngine.selectAction(from: config.specialActions)
            ?? config.specialActions.randomElement()
            ?? .wave

        if action == .hitWall { AchievementTracker.shared.recordWallHit() }
        if action == .dance { AchievementTracker.shared.recordDance() }
        if [.airPiano, .airBasketball, .airGeneric].contains(action) {
            AchievementTracker.shared.recordAirPerformance()
        }

        stickFigure.applyPose(poseForAction(action))
        let duration = Double.random(in: 1.5...4)
        stickFigure.run(.wait(forDuration: duration)) { [weak self] in
            self?.isAnimating = false
            self?.scheduleNextBehavior()
        }
    }

    private func poseForAction(_ action: ActionType) -> StickFigurePose {
        let phase = CGFloat.random(in: 0...1)
        switch action {
        case .sit, .stare, .observe: return .sitting
        case .crouchCircle: return .crouching
        case .crouchCover: return .crouchCover
        case .wave, .standWave: return .waving(phase: phase)
        case .jump: return .jumping(phase: 0.5)
        case .hitWall: return .hitWall
        case .sleep: return .sleeping
        case .taiChi: return .taiChi(phase: phase)
        case .yoga: return .yoga(phase: phase)
        case .airShot: return .airShot(phase: phase)
        case .flip: return .flip(phase: phase)
        case .split: return .split
        case .dance: return .dance(phase: phase)
        case .bowHead: return .bowHead
        case .umbrella: return .umbrella
        case .startledJump: return .startledJump
        case .wipeSweat: return .wipeSweat
        case .exhale: return .exhale
        case .curlUp: return .curlUp
        case .rubHands: return .rubHands(phase: phase)
        case .catchSnow, .catchRaindrop: return .catchSnow
        case .handstand: return .handstand
        case .roll: return .roll(phase: phase)
        case .standProud: return .standProud
        case .edgeHold: return .edgeHold
        case .airPiano: return .airPerformance(phase: phase, kind: .piano)
        case .airBasketball: return .airPerformance(phase: phase, kind: .basketball)
        case .airGeneric: return .airPerformance(phase: phase, kind: .generic)
        default: return .standing
        }
    }

    private func backgroundColorForWeather(_ condition: WeatherCondition) -> UIColor {
        let base = UIColor(red: 1, green: 0.976, blue: 0.882, alpha: 1)
        switch condition {
        case .sunny:
            return UIColor(red: 1, green: 0.985, blue: 0.92, alpha: 1)
        case .rainy, .stormy:
            return UIColor(red: 0.95, green: 0.93, blue: 0.82, alpha: 1)
        case .snowy:
            return UIColor(red: 0.98, green: 0.97, blue: 0.9, alpha: 1)
        case .cloudy:
            return UIColor(red: 0.97, green: 0.96, blue: 0.88, alpha: 1)
        default:
            return base
        }
    }
}
