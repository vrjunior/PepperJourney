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
    private var fowardButton: SKButton!
    
    private var video: SKVideoNode!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setupNodes()
    }
    
    func setupNodes() {
        self.menuButton = self.childNode(withName: "menuButton") as! SKButton
        self.menuButton.delegate = self
        
        self.restartButton = self.childNode(withName: "restartButton") as! SKButton
        self.restartButton.delegate = self
        
        self.fowardButton = self.childNode(withName: "fowardButton") as! SKButton
        self.fowardButton.delegate = self
    }
    
}

extension FinishOverlay : SKButtonDelegate {
    
    func buttonPressed(target: SKButton) {
        
        if target == restartButton {
            gameOptionsDelegate?.restart()
        }
        else if target == fowardButton {
            //TODO handle fowardbutton
        }
        else if target == menuButton {
            //TODO handle menuButton
        }
        
    }
    
}
