import Foundation

/// 状态机上层：大状态
enum BehaviorMacroState: String, CaseIterable {
    case moving = "moving"
    case idle = "idle"
    case special = "special"
}

/// 路径类型（与动作解耦）
enum PathType: String, CaseIterable {
    case straight
    case rightAngle
    case arc
    case spiral
    case sCurve
    case alongEdge
    case randomDrift
    case centerBounce
    case fullScreenChaos
    case fixedPendulum
    case diagonal
    case clockwiseEdge
    case burst
    case curve
    case sprint
    case upperHalfJump
}

/// 动作类型
enum ActionType: String, CaseIterable {
    case walk
    case stroll
    case pause
    case hitWall
    case taiChi
    case yoga
    case airShot
    case flip
    case split
    case crouchCircle
    case measureSteps
    case dance
    case sleep
    case sit
    case stare
    case bowHead
    case umbrella
    case crouchCover
    case startledJump
    case wipeSweat
    case exhale
    case curlUp
    case rubHands
    case catchSnow
    case wave
    case handstand
    case roll
    case standProud
    case bounce
    case observe
    case edgeSlide
    case standWave
    case randomSprint
    case jump
    case edgeHold
    case catchRaindrop
    case airPiano
    case airBasketball
    case airGeneric
}
