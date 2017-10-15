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

class Overlay: SKScene {
    
    var padDelegate:PadOverlayDelegate? {
        didSet {
            self.padOverlay.delegate = padDelegate
        }
    }
    var padOverlay: PadOverlay!
    var movesOverlay: SKSpriteNode!
    var movesDelegate: CharacterMovesDelegate?
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.scaleMode = .resizeFill
        
        // The virtual D-pad
        #if os( iOS )
            self.padOverlay = self.childNode(withName: "padOverlay") as! PadOverlay
            self.movesOverlay = self.childNode(withName: "movesOverlay") as! SKSpriteNode
        #endif
        
       //self.padOverlay.size = CGSize(width: self.size.width / 2, height: self.size.height)
        
        // disable interation in scenekit
        self.isUserInteractionEnabled = false
    }
    
}


// MARK: Character Moves

protocol CharacterMovesDelegate {
    func jump()
    func attack()
}

extension Overlay {
    
    override func didMove(to view: SKView) {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(Overlay.handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        if(isMovesSide(location: gesture.location(in: self.view))) {
            self.movesDelegate?.jump()
        }
    }
    
    func isMovesSide(location: CGPoint) -> Bool{
        if(self.movesOverlay.frame.contains(location)) {
            return true
        }
        return false
    }
    
}
