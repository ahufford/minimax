//
//  GameViewController.swift
//  MiniMax
//
//  Created by Alec on 5/11/20.
//  Copyright © 2020 Huff Limitied. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    var scene: GameScene?
    @IBOutlet var label: UILabel!
    @IBOutlet var winsLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        scene = GameScene(size:view.bounds.size)
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene!.scaleMode = .aspectFit
        scene!.viewController = self

        skView.presentScene(scene)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    @IBAction func restartPressed(_ sender: UIButton) {
        scene!.restartPressed()
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
