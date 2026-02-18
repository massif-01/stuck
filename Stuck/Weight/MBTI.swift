import Foundation

/// 16 型 MBTI 性格
enum MBTI: String, CaseIterable, Codable {
    case INTJ, INTP, ENTJ, ENTP
    case INFJ, INFP, ENFJ, ENFP
    case ISTJ, ISFJ, ESTJ, ESFJ
    case ISTP, ISFP, ESTP, ESFP

    static func random() -> MBTI {
        MBTI.allCases.randomElement() ?? .INFP
    }
}
