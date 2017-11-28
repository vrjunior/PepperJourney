//
//  GameOverOverlay.swift
//  SpicyHero
//
//  Created by Marcelo Martimiano Junior on 28/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.

import Foundation
import SpriteKit


class GameOverOverlay: SKScene {
    public var gameOptionsDelegate: GameOptions?
    
    private var restartButton: SKSpriteNode!
    private var menuButton: SKSpriteNode!
    private var settingsButton: SKSpriteNode!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //setup node
        self.restartButton = self.childNode(withName: "restartButton") as! SKSpriteNode
        self.menuButton = self.childNode(withName: "menuButton") as! SKSpriteNode
        self.settingsButton = self.childNode(withName: "settingsButton") as! SKSpriteNode
    }
    
    override func didMove(to view: SKView) {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(GameOverOverlay.handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        
        let location = gesture.location(in: self.view).fromUiView(height: self.view!.frame.height)
        
        if self.restartButton.contains(location) {
            gameOptionsDelegate?.restart()
        }
        else if self.menuButton.contains(location) {
            //TODO handle menuButton
        }
        else if self.settingsButton.contains(location) {
            //TODO handle settingsButtons
        }
    }
}
