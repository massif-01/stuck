import Foundation

/// 性格漂移：7 日天气滚动窗口，每日修正 ≤1%，软上限不跨型
struct PersonalityDrift {

    private static let maxDailyDrift: Double = 0.01
    private static let driftWindowDays = 7
    private static let storageKey = "Stuck.WeatherDriftMatrix"

    /// I/E, S/N, T/F, J/P 四个维度的漂移值，范围 -1...1
    var driftVector: (I: Double, N: Double, F: Double, P: Double) = (0, 0, 0, 0)

    mutating func recordDailyWeather(_ condition: WeatherCondition) {
        let dailyDelta: (I: Double, N: Double, F: Double, P: Double)
        switch condition {
        case .rainy, .snowy, .cloudy:
            dailyDelta = (0.005, 0, 0.005, 0.005)
        case .sunny, .windy:
            dailyDelta = (-0.005, 0, -0.005, -0.005)
        case .stormy:
            dailyDelta = (0.003, 0, 0.003, 0)
        case .extremeCold, .extremeHot:
            dailyDelta = (0.004, 0, 0.002, 0.004)
        }

        driftVector.I = clamp(driftVector.I + dailyDelta.I)
        driftVector.N = clamp(driftVector.N + dailyDelta.N)
        driftVector.F = clamp(driftVector.F + dailyDelta.F)
        driftVector.P = clamp(driftVector.P + dailyDelta.P)
    }

    private func clamp(_ v: Double) -> Double {
        min(max(v, -0.3), 0.3)
    }

    func save() {
        let arr = [driftVector.I, driftVector.N, driftVector.F, driftVector.P]
        UserDefaults.standard.set(arr, forKey: Self.storageKey)
    }

    static func load() -> PersonalityDrift {
        guard let arr = UserDefaults.standard.array(forKey: storageKey) as? [Double],
              arr.count >= 4 else { return PersonalityDrift() }
        var d = PersonalityDrift()
        d.driftVector = (arr[0], arr[1], arr[2], arr[3])
        return d
    }
}
