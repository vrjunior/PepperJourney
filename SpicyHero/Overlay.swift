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
    
    var controller:GameController? {
        didSet {
            self.padOverlay.delegate = controller
        }
    }
    var padOverlay: PadOverlay!
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.scaleMode = .resizeFill
        
        // The virtual D-pad
        #if os( iOS )
            self.padOverlay = self.childNode(withName: "padOverlay") as! PadOverlay
        #endif
        
       //self.padOverlay.size = CGSize(width: self.size.width / 2, height: self.size.height)
        
        // disable interation in scenekit
        self.isUserInteractionEnabled = false
    }
    
}
