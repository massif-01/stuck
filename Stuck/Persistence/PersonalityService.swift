import Foundation

/// 性格服务：首次启动随机分配 MBTI，后续从存储读取
enum PersonalityService {

    static var currentMBTI: MBTI {
        if let id = GameStorage.personalityId, let mbti = MBTI(rawValue: id) {
            return mbti
        }
        let mbti = MBTI.random()
        GameStorage.personalityId = mbti.rawValue
        return mbti
    }

    static func initializeIfNeeded() {
        if GameStorage.createdAt == nil {
            GameStorage.createdAt = Date()
            _ = currentMBTI
        }
    }
}
