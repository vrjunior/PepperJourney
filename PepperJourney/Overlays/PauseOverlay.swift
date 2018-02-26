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
    
    private var resumeButton: SKButton!
    private var restartButton: SKButton!
    private var menuButton: SKButton!
    private var settingsButton: SKButton!
    
    override func sceneDidLoad() {
        
        //setup nodes
        self.resumeButton = self.childNode(withName: "buttons/resumeButton") as! SKButton
        self.resumeButton.delegate = self
        
        self.restartButton = self.childNode(withName: "buttons/restartButton") as! SKButton
        self.restartButton.delegate = self
        
        self.menuButton = self.childNode(withName: "buttons/menuButton") as! SKButton
        self.menuButton.delegate = self
        
        self.settingsButton = self.childNode(withName: "buttons/settingsButton") as! SKButton
        self.settingsButton.delegate = self
        
    }
}

extension PauseOverlay : SKButtonDelegate {
    func buttonReleased(target: SKButton) {
        target.colorBlendFactor = 0
    }
    
    func buttonPressed(target: SKButton) {
        
        target.colorBlendFactor = target.defaultColorBlendFactor
        
        if target == restartButton {
            self.gameOptionsDelegate?.restart()
        }
        else if target == resumeButton {
            self.gameOptionsDelegate?.resume()
        }
        else if target == menuButton {
            self.gameOptionsDelegate?.goToMenu()
        }
        else if target == settingsButton {
            //TODO handle settingsButton
        }

    }
    
}
