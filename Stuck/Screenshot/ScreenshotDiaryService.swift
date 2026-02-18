import UIKit
import SpriteKit
import Photos

/// 截屏日记：监听截屏，生成带生命时长的分享图
final class ScreenshotDiaryService {

    static let shared = ScreenshotDiaryService()
    weak var scene: SKScene?

    private let backgroundColor = UIColor(red: 1, green: 0.976, blue: 0.882, alpha: 1)
    private let borderColor = UIColor.black
    private let margin: CGFloat = 20

    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDidTakeScreenshot),
            name: UIApplication.userDidTakeScreenshotNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func userDidTakeScreenshot() {
        HapticService.screenshotShutter()
        flashScreen()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.generateAndSave()
        }
    }

    private func flashScreen() {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else { return }
        let flash = UIView(frame: window.bounds)
        flash.backgroundColor = .white
        flash.alpha = 0.6
        window.addSubview(flash)
        UIView.animate(withDuration: 0.2, animations: { flash.alpha = 0 }) { _ in
            flash.removeFromSuperview()
        }
    }

    private func generateAndSave() {
        guard let scene = scene, let skView = scene.view else { return }

        let size = skView.bounds.size
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            skView.drawHierarchy(in: CGRect(origin: .zero, size: size), afterScreenUpdates: false)

            borderColor.setStroke()
            ctx.cgContext.setLineWidth(1)
            ctx.cgContext.stroke(CGRect(
                x: margin,
                y: margin,
                width: size.width - margin * 2,
                height: size.height - margin * 2
            ))

            let lifespan = "\(GameStorage.lifespanHours)h"
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                .foregroundColor: UIColor.black
            ]
            let textSize = lifespan.size(withAttributes: attrs)
            (lifespan as NSString).draw(
                at: CGPoint(x: size.width - margin - textSize.width - 8, y: margin + 4),
                withAttributes: attrs
            )
        }

        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
}
