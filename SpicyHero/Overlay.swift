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
    private var overlayNode: SKNode
    
    #if os( iOS )
    public var controlOverlay: ControlOverlay?
    #endif
    
    // MARK: - Initialization
    init(size: CGSize, controller: GameController) {
        
        overlayNode = SKNode()
        super.init(size: size)
        
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        
        // Setup the game overlays using SpriteKit.
        scaleMode = .resizeFill
        
        self.addChild(overlayNode)
        overlayNode.position = CGPoint(x: 0.0, y: h)
        
        // The virtual D-pad
        #if os( iOS )
            controlOverlay = ControlOverlay(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: w, height: h))
            controlOverlay!.directionPad.delegate = controller
            addChild(controlOverlay!)
        #endif
        
        // disable interation in scenekit
        self.isUserInteractionEnabled = false
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    #if os( iOS )
    func showVirtualPad() {
    controlOverlay!.isHidden = false
    }
    
    func hideVirtualPad() {
    controlOverlay!.isHidden = true
    }
    #endif
    
}
