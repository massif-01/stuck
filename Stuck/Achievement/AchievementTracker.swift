import Foundation

/// 成就追踪：仅前台时计入，追踪动作触发次数等
final class AchievementTracker {

    static let shared = AchievementTracker()

    private let wallHitKey = "Stuck.WallHitCount"
    private let dancedKey = "Stuck.HasDanced"
    private let airPerformanceKey = "Stuck.HasAirPerformance"
    private let lastOpenKey = "Stuck.LastOpenDate"
    private let streakKey = "Stuck.CurrentStreak"

    var wallHitCount: Int {
        get { UserDefaults.standard.integer(forKey: wallHitKey) }
        set { UserDefaults.standard.set(newValue, forKey: wallHitKey) }
    }

    func recordWallHit() {
        wallHitCount += 1
        if wallHitCount >= 1000 {
            AchievementService.shared.reportWallEnemy(progress: 100)
        } else {
            AchievementService.shared.reportWallEnemy(progress: Double(wallHitCount))
        }
    }

    func recordDance() {
        guard !UserDefaults.standard.bool(forKey: dancedKey) else { return }
        UserDefaults.standard.set(true, forKey: dancedKey)
        AchievementService.shared.reportLonelyDancer()
    }

    func recordAirPerformance() {
        guard !UserDefaults.standard.bool(forKey: airPerformanceKey) else { return }
        UserDefaults.standard.set(true, forKey: airPerformanceKey)
        AchievementService.shared.reportMysteryRitual()
    }

    func recordDailyOpen() {
        let today = Calendar.current.startOfDay(for: Date())
        let last = UserDefaults.standard.object(forKey: lastOpenKey) as? Date
        var streak = UserDefaults.standard.integer(forKey: streakKey)
        if let l = last {
            let days = Calendar.current.dateComponents([.day], from: l, to: today).day ?? 0
            if days == 1 {
                streak += 1
            } else if days > 1 {
                streak = 1
            }
        } else {
            streak = 1
        }
        UserDefaults.standard.set(today, forKey: lastOpenKey)
        UserDefaults.standard.set(streak, forKey: streakKey)
        if streak >= 30 {
            AchievementService.shared.reportThirtyDaysStreak()
        }
    }

    func checkLifespanAchievements() {
        let hours = GameStorage.lifespanHours
        if hours >= 24 * 100 {
            AchievementService.shared.reportHundredDays()
        }
    }
}
