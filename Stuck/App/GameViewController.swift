import UIKit
import SpriteKit

final class GameViewController: UIViewController {

    override func loadView() {
        view = SKView(frame: .zero)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let skView = view as? SKView else { return }
        skView.ignoresSiblingOrder = true
        skView.showsFPS = false
        skView.showsNodeCount = false

        let scene = GameScene(size: view.bounds.size)
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    override var prefersStatusBarHidden: Bool {
        true
    }
}
