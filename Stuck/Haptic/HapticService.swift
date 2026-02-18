import UIKit

/// 触觉服务：动作类型基础 + MBTI 风格叠加
enum HapticService {

    enum ActionHaptic {
        case light
        case medium
        case heavy
        case rigid
    }

    enum MBTIHapticStyle: String {
        case sharp, soft, heavy, doubleTap
        case pulse, ethereal, success, burst
        case rigid, warm, thud, cyclic
        case impactful, fluid, violent, sparkling
    }

    /// 根据动作类型获取基础触觉
    static func hapticForAction(_ action: ActionType) -> ActionHaptic {
        switch action {
        case .walk, .stroll: return .light
        case .flip, .split: return .medium
        case .hitWall, .randomSprint, .jump: return .heavy
        case .pause, .observe: return .rigid
        default: return .medium
        }
    }

    /// 触发触觉：动作基础 + MBTI 强度微调
    static func trigger(
        action: ActionType,
        mbtiStyle: MBTIHapticStyle
    ) {
        let base = hapticForAction(action)
        let intensity = intensityMultiplier(for: mbtiStyle)
        perform(base, intensity: intensity)
    }

    private static func intensityMultiplier(for style: MBTIHapticStyle) -> CGFloat {
        switch style {
        case .sharp, .violent: return 1.2
        case .soft, .ethereal, .warm: return 0.6
        case .heavy, .impactful: return 1.15
        case .rigid, .thud: return 1.0
        case .doubleTap, .burst, .sparkling: return 0.9
        case .pulse, .success, .cyclic, .fluid: return 0.85
        }
    }

    private static func perform(_ base: ActionHaptic, intensity: CGFloat) {
        switch base {
        case .light:
            let g = UIImpactFeedbackGenerator(style: .light)
            g.impactOccurred()
        case .medium:
            let g = UIImpactFeedbackGenerator(style: .medium)
            g.impactOccurred()
        case .heavy:
            let g = UIImpactFeedbackGenerator(style: .heavy)
            g.impactOccurred()
        case .rigid:
            let g = UIImpactFeedbackGenerator(style: .rigid)
            g.impactOccurred()
        }
    }

    /// 双击式触觉（ENTP 等）
    static func doubleTap() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }

    /// 脉冲式（INFJ 等，每 30 秒）
    static func pulse() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }

    /// 截屏快门反馈
    static func screenshotShutter() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.8)
    }
}
