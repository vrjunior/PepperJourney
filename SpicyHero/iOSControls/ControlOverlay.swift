//
//  ControlOverlay.swift
//  SpicyHero
//
//  Created by Valmir Junior on 06/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import SpriteKit

class ControlOverlay: SKNode {
        
    var directionPad:PadOverlay!
    
    init(frame: CGRect) {
        super.init()
        
        self.directionPad = PadOverlay(width: frame.width / 2, height: frame.height)
        directionPad.position = CGPoint(x: CGFloat(0), y: CGFloat(0))
        addChild(directionPad)
        
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
