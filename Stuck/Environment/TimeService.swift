import Foundation

/// 时间服务：提供时间系数（白昼/深夜/睡眠时段）
struct TimeService {
    static let shared = TimeService()

    private init() {}

    /// 时间系数乘数，影响动作权重
    var coefficient: Double {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 0 && hour < 6 {
            return 0.2
        }
        if hour >= 8 && hour < 22 {
            return 1.0
        }
        if hour >= 14 && hour < 18 {
            return 1.2
        }
        return 0.6
    }
}
