//
//  GameEntryController.swift
//  PepperJourney
//
//  Created by Marcelo Martimiano Junior on 02/03/18.
//  Copyright © 2018 Valmir Junior. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

class GameEntryController: NSObject, SCNSceneRendererDelegate {
    public var scnView: SCNView!
    public var sceneRenderer: SCNSceneRenderer?
    public weak var gameControllerDelegate: GameViewControllerDelagate?
    
    init(scnView: SCNView, gameControllerDelegate: GameViewControllerDelagate) {
        super.init()
        
        //set scnView
        self.scnView = scnView
        scnView.scene = SCNScene(named: "Game.scnassets/fases/comicScene.scn")
        scnView.delegate = self
        self.gameControllerDelegate = gameControllerDelegate
        
        self.scnView.pointOfView = self.scnView.scene?.rootNode.childNode(withName: "comicCamera", recursively: true)
        self.scnView.scene?.rootNode.runAction(SCNAction.wait(duration: 5), completionHandler: {
            self.setTapToStart()
        })
    }
    
    func setTapToStart() {
        if let tapOverlay = SKScene(fileNamed: "StartOverlay.sks") as? StartOverlay {
            tapOverlay.gameOptionsDelegate = self
            tapOverlay.scaleMode = .aspectFill
            self.scnView.overlaySKScene = tapOverlay
        }
    }
    
}


extension GameEntryController: GameOptions {
    func resetGame() {}
    
    func start() {
        self.gameControllerDelegate?.setComic(named: "level1")
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
    func goToComic(comic: String) {}
}

