import Foundation

/// 天气对路径权重的修正值（加减固定值）
struct WeatherModifiers {

    static func pathModifiers(for condition: WeatherCondition) -> [PathType: Int] {
        var mods: [PathType: Int] = [:]
        switch condition {
        case .sunny:
            mods[.sprint] = 20
            mods[.burst] = 15
        case .rainy:
            mods[.randomDrift] = -30
            mods[.alongEdge] = 10
        case .snowy:
            mods[.straight] = -20
            mods[.arc] = 15
        case .stormy:
            mods[.sprint] = 40
            mods[.burst] = 30
        case .windy:
            mods[.randomDrift] = 25
        case .cloudy:
            mods[.randomDrift] = 10
        case .extremeCold, .extremeHot:
            break
        }
        return mods
    }
}
