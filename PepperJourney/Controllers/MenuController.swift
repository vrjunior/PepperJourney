//
//  MenuController.swift
//  PepperJourney
//
//  Created by Marcelo Martimiano Junior on 25/02/18.
//  Copyright © 2018 Valmir Junior. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

class MenuController: NSObject, SCNSceneRendererDelegate {
    public var scnView: SCNView!
    public var sceneRenderer: SCNSceneRenderer?
    public weak var gameControllerDelegate: GameViewControllerDelagate?

    init(scnView: SCNView, gameControllerDelegate: GameViewControllerDelagate) {
        super.init()

        //set scnView
        self.scnView = scnView
        scnView.scene = SCNScene(named: "Game.scnassets/menuScene.scn")
        scnView.delegate = self
        self.gameControllerDelegate = gameControllerDelegate
        
        //        self.scnView.debugOptions = SCNDebugOptions.showPhysicsShapes
        //        self.scnView.showsStatistics = true
        
        if let tapOverlay = SKScene(fileNamed: "MenuOverlay.sks") as? MenuOverlay {
            tapOverlay.gameOptionsDelegate = self
            tapOverlay.scaleMode = .aspectFill
            self.scnView.overlaySKScene = tapOverlay
        }
    }
}
extension MenuController: GameOptions {
    func start() {
    }
    
    func restart() {}
    func pause() {}
    func resume() {}
    func loadAd(loadedVideoFeedback: @escaping () -> Void) {}
    func cancelAd() {}
    func nextLevel() {}
    func previousLevel() {}
    func tutorialClosed() {}
    func goToMenu() {}
    
    func goToComic(comic: String) {
        self.gameControllerDelegate?.setComic(named: comic)
    }
}

