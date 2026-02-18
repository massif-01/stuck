import Foundation
import CoreLocation

/// 天气服务：每 60 分钟更新，预留 WeatherKit 接入；拒绝定位时降级为随机/默认晴天
final class WeatherService {
    static let shared = WeatherService()

    private static let cacheInterval: TimeInterval = 3600
    private static let cacheKey = "Stuck.WeatherCache"
    private static let cacheTimeKey = "Stuck.WeatherCacheTime"

    private(set) var currentCondition: WeatherCondition = .sunny
    private(set) var temperature: Double = 20
    private(set) var windSpeed: Double = 0

    init() {
        loadFromCache()
    }

    /// 刷新天气（每小时调用）
    func refresh() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
           CLLocationManager.authorizationStatus() == .authorizedAlways {
            // 预留：调用 WeatherKit 获取真实天气
            // Task { await fetchFromWeatherKit() }
        }
        useFallback()
        recordDriftIfNeeded()
    }

    private func recordDriftIfNeeded() {
        let key = "Stuck.LastDriftDate"
        let today = Calendar.current.startOfDay(for: Date())
        guard UserDefaults.standard.object(forKey: key) as? Date != today else { return }
        UserDefaults.standard.set(today, forKey: key)
        var drift = PersonalityDrift.load()
        drift.recordDailyWeather(currentCondition)
        drift.save()
    }

    /// 降级：随机天气或默认晴天
    private func useFallback() {
        let roll = Double.random(in: 0..<1)
        if roll < 0.7 {
            currentCondition = .sunny
            temperature = 22
            windSpeed = 2
        } else if roll < 0.85 {
            currentCondition = .rainy
            temperature = 18
            windSpeed = 3
        } else if roll < 0.92 {
            currentCondition = .snowy
            temperature = -2
            windSpeed = 1
        } else if roll < 0.96 {
            currentCondition = .stormy
            temperature = 15
            windSpeed = 12
        } else {
            currentCondition = .windy
            temperature = 16
            windSpeed = 8
        }
        saveToCache()
    }

    private func loadFromCache() {
        let time = UserDefaults.standard.double(forKey: Self.cacheTimeKey)
        guard Date().timeIntervalSince1970 - time < Self.cacheInterval else { return }
        if let raw = UserDefaults.standard.string(forKey: Self.cacheKey),
           let c = WeatherCondition(rawValue: raw) {
            currentCondition = c
            temperature = UserDefaults.standard.double(forKey: "\(Self.cacheKey).temp")
            if temperature == 0 { temperature = 20 }
            windSpeed = UserDefaults.standard.double(forKey: "\(Self.cacheKey).wind")
        }
    }

    private func saveToCache() {
        UserDefaults.standard.set(currentCondition.rawValue, forKey: Self.cacheKey)
        UserDefaults.standard.set(temperature, forKey: "\(Self.cacheKey).temp")
        UserDefaults.standard.set(windSpeed, forKey: "\(Self.cacheKey).wind")
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: Self.cacheTimeKey)
    }
}

/// 天气状况
enum WeatherCondition: String, CaseIterable {
    case sunny, rainy, snowy, stormy, windy, cloudy
    case extremeCold, extremeHot
}
