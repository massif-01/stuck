import UIKit

/// 电量服务：正常/低电量，充电中 10% 速度加成
struct BatteryService {
    static let shared = BatteryService()

    var isLowPower: Bool {
        guard UIDevice.current.batteryState != .unknown else { return false }
        return UIDevice.current.batteryLevel <= 0.2
    }

    var isCharging: Bool {
        UIDevice.current.batteryState == .charging || UIDevice.current.batteryState == .full
    }

    /// 速度 modifier：低电量 0.4，充电中 1.1，正常 1.0
    var speedModifier: Double {
        if isCharging { return 1.1 }
        if isLowPower { return 0.4 }
        return 1.0
    }
}
