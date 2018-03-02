//
//  FinishOverlay.swift
//  PepperJourney
//
//  Created by Valmir Junior on 28/11/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import SpriteKit
import UIKit.UIGestureRecognizer
import AVFoundation
import UIKit

class FinishOverlay: SKScene {
    
    public var gameOptionsDelegate: GameOptions?
    public var finalCutSceneVideo: String = "" {
        didSet {
            let videoView = VideoViewController()
            videoView.cutScenePath = finalCutSceneVideo
            
        }
    }
    
    private var restartButton: SKButton!
    private var menuButton: SKButton!
    private var forwardButton: SKButton!
    
    private var video: SKVideoNode!
    public private(set) var levelSelected: Bool!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setupNodes()
        self.levelSelected = false
    }
    
    func setupNodes() {
        self.menuButton = self.childNode(withName: "buttons/menuButton") as! SKButton
        self.menuButton.delegate = self
        
        self.restartButton = self.childNode(withName: "buttons/restartButton") as! SKButton
        self.restartButton.delegate = self
        self.restartButton.isHidden = false
        
        self.forwardButton = self.childNode(withName: "buttons/forwardButton") as! SKButton
        self.forwardButton.delegate = self
    }
    
    func setNextLevel(enabled: Bool) {
        if enabled {
            self.forwardButton.isHidden = false
            self.forwardButton.position.x = 275
            self.menuButton.position.x = 0
            self.restartButton.position.x = -275
        }
        else {
            self.forwardButton.isHidden = true
            self.menuButton.position.x = -150
            self.restartButton.position.x = 150
        }
    }
}

extension FinishOverlay : SKButtonDelegate {
    
    func buttonReleased(target: SKButton) {
        if target == restartButton, !self.levelSelected {
            gameOptionsDelegate?.restart()
            self.restartButton.colorBlendFactor = target.defaultColorBlendFactor
        }
            
        else if target == forwardButton, !self.levelSelected {
            self.levelSelected = true
            gameOptionsDelegate?.nextLevel()
        }
        else if target == self.menuButton {
            self.gameOptionsDelegate?.goToMenu()
        }
    }
    
    
    func buttonPressed(target: SKButton) {
       target.colorBlendFactor = target.defaultColorBlendFactor

        
    }
    
}
