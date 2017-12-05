//
//  Overlay.swift
//  SpicyHero
//
//  Created by Valmir Junior on 06/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

class ControlsOverlay: SKScene {
    
    public var controlsDelegate: Controls? {
        didSet {
            self.padOverlay.delegate = controlsDelegate
            self.cameraControl.delegate = controlsDelegate
            self.attackButton.delegate = controlsDelegate
            self.jumpButton.delegate = controlsDelegate
        }
    }
    
    public var gameOptionsDelegate: GameOptions?
    
    
    private var jumpButton: JumpButton!
    private var attackButton: AttackButton!
    private var padOverlay: PadOverlay!
    private var pauseButton: SKSpriteNode!
    private var cameraControl: CameraControl!
    
    public var isPausedControl:Bool = false {
        didSet {
            self.padOverlay.isPausedControl = self.isPausedControl
            self.jumpButton.isPausedControls = self.isPausedControl
            self.attackButton.isPausedControls = self.isPausedControl
            self.cameraControl.isPausedControl = self.isPausedControl
        }
    }
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.scaleMode = .aspectFill
        
        
        self.padOverlay = self.childNode(withName: "padOverlay") as! PadOverlay
        self.jumpButton = self.childNode(withName: "jumpButton") as! JumpButton
        self.attackButton = self.childNode(withName: "attackButton") as! AttackButton
        self.pauseButton = self.childNode(withName: "pauseButton") as! SKSpriteNode
        self.cameraControl = self.childNode(withName: "cameraControl") as! CameraControl
        
        // disable interation in scenekit
        self.isUserInteractionEnabled = false
    }
    
}

extension ControlsOverlay {
    
    override func didMove(to view: SKView) {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ControlsOverlay.handleTap(_:)))
        
        view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        
        var location = gesture.location(in: self.view)
        location.y = (self.view?.frame.height)! - location.y
        
        if pauseButton.contains(location) {
            self.gameOptionsDelegate?.pause()
        }
        
    }
    
    
}
