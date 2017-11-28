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
    
    public var gameOptionsDelegate: GameOptions?
    
    private var resumeButton: SKSpriteNode!
    private var restartButton: SKSpriteNode!
    private var menuButton: SKSpriteNode!
    private var settingsButton: SKSpriteNode!
    
    override func sceneDidLoad() {
        
        //setup nodes
        self.resumeButton = self.childNode(withName: "resumeButton") as! SKSpriteNode
        self.restartButton = self.childNode(withName: "restartButton") as! SKSpriteNode
        self.menuButton = self.childNode(withName: "menuButton") as! SKSpriteNode
        self.settingsButton = self.childNode(withName: "settingsButton") as! SKSpriteNode
        
    }
    
    override func didMove(to view: SKView) {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(StartOverlay.handleTap(_:)))
        
        view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        
        let location = gesture.location(in: self.view).fromUiView(height: self.view!.frame.height)
        
        if restartButton.contains(location) {
            self.gameOptionsDelegate?.restart()
        }
        
        else if resumeButton.contains(location) {
            self.gameOptionsDelegate?.resume()
        }
        
        else if menuButton.contains(location) {
            //TODO handle menuButton
        }
        
        else if settingsButton.contains(location) {
            //TODO handle settingsButton
        }
        
    }
    
}
