//
//  PauseOverlay.swift
//  SpicyHero
//
//  Created by Valmir Junior on 13/11/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import SpriteKit

class PauseOverlay: SKScene {
    
    private var resumeButton: SKSpriteNode!
    private var restartButton: SKSpriteNode!
    public var gameOptionsDelegate: GameOptions?
    
    override func sceneDidLoad() {
        
        //setup nodes
        self.resumeButton = self.childNode(withName: "resumeButton") as! SKSpriteNode
        self.restartButton = self.childNode(withName: "restartButton") as! SKSpriteNode
        
    }
    
    override func didMove(to view: SKView) {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(StartOverlay.handleTap(_:)))
        
        view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        
        var location = gesture.location(in: self.view)
        location.y = (self.view?.frame.height)! - location.y
        
        if restartButton.contains(location) {
            self.gameOptionsDelegate?.restart()
        }
        
        else if resumeButton.contains(location) {
            self.gameOptionsDelegate?.resume()
        }
        
    }
    
}
