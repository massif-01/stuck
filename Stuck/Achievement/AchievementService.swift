import Foundation
import GameKit

/// Game Center 成就服务，仅前台时计入
struct AchievementService {

    static let shared = AchievementService()

    private enum AchievementID {
        static let firstMeet = "stuck.first_meet"
        static let hundredDays = "stuck.hundred_days"
        static let thirtyDaysStreak = "stuck.thirty_days_streak"
        static let allSports = "stuck.all_sports"
        static let wallEnemy = "stuck.wall_enemy"
        static let lonelyDancer = "stuck.lonely_dancer"
        static let mysteryRitual = "stuck.mystery_ritual"
    }

    func authenticate() {
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            if let vc = viewController {
                UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .flatMap { $0.windows }
                    .first { $0.isKeyWindow }?
                    .rootViewController?
                    .present(vc, animated: true)
            }
        }
    }

    func reportFirstMeet() {
        report(achievement: AchievementID.firstMeet, percent: 100)
    }

    func reportHundredDays() {
        report(achievement: AchievementID.hundredDays, percent: 100)
    }

    func reportThirtyDaysStreak() {
        report(achievement: AchievementID.thirtyDaysStreak, percent: 100)
    }

    func reportAllSports() {
        report(achievement: AchievementID.allSports, percent: 100)
    }

    func reportWallEnemy(progress: Double) {
        report(achievement: AchievementID.wallEnemy, percent: min(100, progress / 10))
    }

    func reportLonelyDancer() {
        report(achievement: AchievementID.lonelyDancer, percent: 100)
    }

    func reportMysteryRitual() {
        report(achievement: AchievementID.mysteryRitual, percent: 100)
    }

    private func report(achievement id: String, percent: Double) {
        guard GKLocalPlayer.local.isAuthenticated else { return }
        let a = GKAchievement(identifier: id)
        a.percentComplete = percent
        a.showsCompletionBanner = true
        GKAchievement.report([a]) { _ in }
    }
}
