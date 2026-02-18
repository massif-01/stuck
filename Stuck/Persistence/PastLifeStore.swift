import Foundation

/// iCloud 前世档案存储：仅记录，不恢复。重装=新存档。
enum PastLifeStore {

    private static let key = "Stuck.PastLives"
    private static let currentKey = "Stuck.CurrentLifeSnapshot"

    struct PastLifeRecord: Codable {
        let personalityId: String
        let lifespanHours: Int
        let endedAt: Date
    }

    /// 将当前生命快照写入 iCloud（定期备份，卸载时无法执行）。无 iCloud 账号时仅存本地。
    static func saveCurrentSnapshot() {
        guard let pid = GameStorage.personalityId,
              let created = GameStorage.createdAt else { return }
        let hours = GameStorage.lifespanHours
        let snapshot: [String: Any] = [
            "personalityId": pid,
            "lifespanHours": hours,
            "createdAt": created.timeIntervalSince1970
        ]
        UserDefaults.standard.set(snapshot, forKey: currentKey)
        guard FileManager.default.ubiquityIdentityToken != nil else { return }
        let store = NSUbiquitousKeyValueStore.default
        store.set(snapshot, forKey: currentKey)
        store.synchronize()
    }

    /// 应用启动时同步 iCloud。无 iCloud 账号时跳过。
    static func synchronize() {
        guard FileManager.default.ubiquityIdentityToken != nil else { return }
        NSUbiquitousKeyValueStore.default.synchronize()
    }
}
