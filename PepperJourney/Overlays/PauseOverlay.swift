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
        self.resumeButton = self.childNode(withName: "resumeButton") as! SKButton
        self.resumeButton.delegate = self
        
        self.restartButton = self.childNode(withName: "restartButton") as! SKButton
        self.restartButton.delegate = self
        
        self.menuButton = self.childNode(withName: "menuButton") as! SKButton
        self.resumeButton.delegate = self
        
        self.settingsButton = self.childNode(withName: "settingsButton") as! SKButton
        self.settingsButton.delegate = self
        
    }
}

extension PauseOverlay : SKButtonDelegate {
    
    func buttonPressed(target: SKButton) {
        
        if target == restartButton {
            self.gameOptionsDelegate?.restart()
        }
        else if target == resumeButton {
            self.gameOptionsDelegate?.resume()
        }
        else if target == menuButton {
            //TODO handle menuButton
        }
        else if target == settingsButton {
            //TODO handle settingsButton
        }
        
    }
    
}
