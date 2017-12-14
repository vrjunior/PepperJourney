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
    
    private var restartButton: SKButton!
    private var menuButton: SKButton!
    private var settingsButton: SKButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //setup nodes
        self.restartButton = self.childNode(withName: "restartButton") as! SKButton
        self.restartButton.delegate = self
        
        self.menuButton = self.childNode(withName: "menuButton") as! SKButton
        self.menuButton.delegate = self
        
        self.settingsButton = self.childNode(withName: "settingsButton") as! SKButton
        self.settingsButton.delegate = self
        
    }
    
}

extension GameOverOverlay : SKButtonDelegate {
    
    func buttonPressed(target: SKButton) {
        
        if target == self.restartButton {
            gameOptionsDelegate?.restart()
        }
        else if target == self.menuButton {
            //TODO handle menuButton
        }
        else if target ==  self.settingsButton {
            //TODO handle settingsButtons
        }
        
    }
    
}
