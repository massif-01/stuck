import Foundation

/// 16 型 MBTI 基础配置：路径权重、停顿频率、特殊动作、触觉风格
struct MBTIConfig {
    let mbti: MBTI
    let pathWeights: [PathType: Int]
    let idleFrequency: IdleFrequency
    let specialActions: [ActionType]
    let hapticStyle: HapticStyle

    enum IdleFrequency: String {
        case veryLow, low, medium, high, veryHigh
    }

    enum HapticStyle: String {
        case sharp, soft, heavy, doubleTap
        case pulse, ethereal, success, burst
        case rigid, warm, thud, cyclic
        case impactful, fluid, violent, sparkling
    }

    static func config(for mbti: MBTI) -> MBTIConfig {
        switch mbti {
        case .INTJ:
            return MBTIConfig(
                mbti: .INTJ,
                pathWeights: [.straight: 70, .rightAngle: 20],
                idleFrequency: .medium,
                specialActions: [.observe],
                hapticStyle: .sharp
            )
        case .INTP:
            return MBTIConfig(
                mbti: .INTP,
                pathWeights: [.randomDrift: 30],
                idleFrequency: .veryHigh,
                specialActions: [.stare, .crouchCircle],
                hapticStyle: .soft
            )
        case .ENTJ:
            return MBTIConfig(
                mbti: .ENTJ,
                pathWeights: [.sprint: 50, .burst: 40],
                idleFrequency: .low,
                specialActions: [.standProud, .hitWall],
                hapticStyle: .heavy
            )
        case .ENTP:
            return MBTIConfig(
                mbti: .ENTP,
                pathWeights: [.centerBounce: 40, .diagonal: 40],
                idleFrequency: .medium,
                specialActions: [.dance, .bounce],
                hapticStyle: .doubleTap
            )
        case .INFJ:
            return MBTIConfig(
                mbti: .INFJ,
                pathWeights: [.alongEdge: 60],
                idleFrequency: .high,
                specialActions: [.observe, .edgeSlide],
                hapticStyle: .pulse
            )
        case .INFP:
            return MBTIConfig(
                mbti: .INFP,
                pathWeights: [.arc: 40],
                idleFrequency: .veryHigh,
                specialActions: [.sit, .stare, .curlUp],
                hapticStyle: .ethereal
            )
        case .ENFJ:
            return MBTIConfig(
                mbti: .ENFJ,
                pathWeights: [.centerBounce: 50],
                idleFrequency: .low,
                specialActions: [.standWave, .wave, .jump, .airBasketball],
                hapticStyle: .success
            )
        case .ENFP:
            return MBTIConfig(
                mbti: .ENFP,
                pathWeights: [.fullScreenChaos: 70],
                idleFrequency: .veryLow,
                specialActions: [.randomSprint, .jump, .handstand, .airGeneric],
                hapticStyle: .burst
            )
        case .ISTJ:
            return MBTIConfig(
                mbti: .ISTJ,
                pathWeights: [.fixedPendulum: 80],
                idleFrequency: .medium,
                specialActions: [.umbrella],
                hapticStyle: .rigid
            )
        case .ISFJ:
            return MBTIConfig(
                mbti: .ISFJ,
                pathWeights: [.randomDrift: 70],
                idleFrequency: .high,
                specialActions: [.crouchCircle, .edgeHold],
                hapticStyle: .warm
            )
        case .ESTJ:
            return MBTIConfig(
                mbti: .ESTJ,
                pathWeights: [.diagonal: 60, .sprint: 40],
                idleFrequency: .low,
                specialActions: [.hitWall],
                hapticStyle: .thud
            )
        case .ESFJ:
            return MBTIConfig(
                mbti: .ESFJ,
                pathWeights: [.clockwiseEdge: 80],
                idleFrequency: .medium,
                specialActions: [.observe],
                hapticStyle: .cyclic
            )
        case .ISTP:
            return MBTIConfig(
                mbti: .ISTP,
                pathWeights: [.burst: 30],
                idleFrequency: .veryHigh,
                specialActions: [],
                hapticStyle: .impactful
            )
        case .ISFP:
            return MBTIConfig(
                mbti: .ISFP,
                pathWeights: [.curve: 50, .sCurve: 30],
                idleFrequency: .medium,
                specialActions: [.catchSnow, .catchRaindrop, .airPiano],
                hapticStyle: .fluid
            )
        case .ESTP:
            return MBTIConfig(
                mbti: .ESTP,
                pathWeights: [.sprint: 60, .burst: 30],
                idleFrequency: .veryLow,
                specialActions: [.hitWall],
                hapticStyle: .violent
            )
        case .ESFP:
            return MBTIConfig(
                mbti: .ESFP,
                pathWeights: [.upperHalfJump: 50],
                idleFrequency: .low,
                specialActions: [.jump, .dance, .wave],
                hapticStyle: .sparkling
            )
        }
    }
}
