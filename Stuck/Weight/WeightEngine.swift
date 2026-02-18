import Foundation

/// 权重引擎：P(action) = normalize((base_weight + weather_modifier) * time_coefficient * battery_modifier)
struct WeightEngine {

    var mbti: MBTI
    var weatherModifiers: [PathType: Int] = [:]
    var timeCoefficient: Double = 1.0
    var batteryModifier: Double = 1.0
    var weatherCondition: WeatherCondition = .sunny

    /// 按权重随机选择路径类型
    func selectPath() -> PathType {
        let config = MBTIConfig.config(for: mbti)
        var weights: [PathType: Double] = [:]

        for (path, base) in config.pathWeights {
            let mod = Double(weatherModifiers[path] ?? 0)
            let w = (Double(base) + mod) * timeCoefficient * batteryModifier
            weights[path, default: 0] += max(0, w)
        }

        // 若无可选路径，回退到直线
        guard !weights.isEmpty else { return .straight }

        var total = weights.values.reduce(0, +)
        if total <= 0 {
            total = 1
            weights[.straight] = 1
        }

        let r = Double.random(in: 0..<total)
        var acc = 0.0
        for (path, w) in weights.sorted(by: { $0.key.rawValue < $1.key.rawValue }) {
            acc += w
            if r < acc { return path }
        }
        return weights.keys.first ?? .straight
    }

    /// 按权重随机选择动作类型（用于特殊状态）
    func selectAction(from actions: [ActionType]) -> ActionType? {
        guard !actions.isEmpty else { return nil }
        return actions.randomElement()
    }

    /// 选择大状态：moving / idle / special
    func selectMacroState() -> BehaviorMacroState {
        let config = MBTIConfig.config(for: mbti)
        let idleWeight: Int
        switch config.idleFrequency {
        case .veryLow: idleWeight = 5
        case .low: idleWeight = 15
        case .medium: idleWeight = 30
        case .high: idleWeight = 50
        case .veryHigh: idleWeight = 65
        }
        let moveWeight = 100 - idleWeight
        let specialWeight = 10
        let total = moveWeight + idleWeight + specialWeight
        let r = Int.random(in: 0..<total)
        if r < moveWeight { return .moving }
        if r < moveWeight + idleWeight { return .idle }
        return .special
    }
}
