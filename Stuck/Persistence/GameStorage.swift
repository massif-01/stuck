import Foundation

/// 游戏持久化存储，用于获取生存时长等。首启性格随机在 PersonalityService 中处理。
enum GameStorage {
    private static let createdAtKey = "Stuck.CreatedAt"
    private static let personalityIdKey = "Stuck.PersonalityId"

    static var createdAt: Date? {
        get { UserDefaults.standard.object(forKey: createdAtKey) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: createdAtKey) }
    }

    static var personalityId: String? {
        get { UserDefaults.standard.string(forKey: personalityIdKey) }
        set { UserDefaults.standard.set(newValue, forKey: personalityIdKey) }
    }

    /// 生存时长（小时），从出生起累计（实时间）
    static var lifespanHours: Int {
        guard let created = createdAt else { return 0 }
        return Int(Date().timeIntervalSince(created) / 3600)
    }

    static func clearForNewLife() {
        createdAt = nil
        personalityId = nil
    }
}
