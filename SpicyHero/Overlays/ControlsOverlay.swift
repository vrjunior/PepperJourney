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

// MARK: Controls Protocol

protocol Controls {
    func jump()
    func attack()
}

class ControlsOverlay: SKScene {
    
    var padDelegate:PadOverlayDelegate? {
        didSet {
            self.padOverlay.delegate = padDelegate
        }
    }
    var padOverlay: PadOverlay!
    var pauseButton: SKSpriteNode!
    var movesOverlay: SKSpriteNode!
    var controlsDelegate: Controls?
    var gameOptionsDelegate: GameOptions?
    
    public var isPausedControl:Bool = false {
        didSet {
            self.padOverlay.isPausedControl = self.isPausedControl
        }
    }
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.scaleMode = .resizeFill
        
        // The virtual D-pad
        #if os( iOS )
            self.padOverlay = self.childNode(withName: "padOverlay") as! PadOverlay
            self.movesOverlay = self.childNode(withName: "movesOverlay") as! SKSpriteNode
            self.pauseButton = self.childNode(withName: "pauseButton") as! SKSpriteNode
        #endif
        
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
        
        else if(isMovesSide(location: location)) {
            self.controlsDelegate?.jump()
        }
        
    }
    
    func isMovesSide(location: CGPoint) -> Bool{
        if(self.movesOverlay.frame.contains(location)) {
            return true
        }
        return false
    }
    
}
