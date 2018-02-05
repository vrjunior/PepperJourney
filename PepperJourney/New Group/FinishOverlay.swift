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
    private var backwardButton: SKButton!
    private var forwardButton: SKButton!
    
    private var video: SKVideoNode!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setupNodes()
    }
    
    func setupNodes() {
        self.backwardButton = self.childNode(withName: "buttons/backwardButton") as! SKButton
        self.backwardButton.delegate = self
        
        self.restartButton = self.childNode(withName: "buttons/restartButton") as! SKButton
        self.restartButton.delegate = self
        self.restartButton.isHidden = false
        
        self.forwardButton = self.childNode(withName: "buttons/forwardButton") as! SKButton
        self.forwardButton.delegate = self
    }
    
    func setBackwardMode() {
        self.forwardButton.isHidden = true
        self.backwardButton.position.x = -150
        self.restartButton.position.x = 150
    }
    func setForwardMode() {
        self.backwardButton.isHidden = true
        self.forwardButton.position.x = 150
        self.restartButton.position.x = -150
    }
    
}

extension FinishOverlay : SKButtonDelegate {
    func buttonReleased(target: SKButton) {
        if target == restartButton {
            gameOptionsDelegate?.restart()
        }
        else if target == forwardButton {
            gameOptionsDelegate?.nextLevel()
        }
        else if target == backwardButton {
            gameOptionsDelegate?.previousLevel()
        }
    }
    
    
    func buttonPressed(target: SKButton) {
        
       

        
    }
    
}
