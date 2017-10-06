//
//  ControlOverlay.swift
//  SpicyHero
//
//  Created by Valmir Junior on 06/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import SpriteKit

class ControlOverlay: SKNode {
    
    let buttonMargin = CGFloat( 25 )
    
    var directionPad = PadOverlay()
    
    init(frame: CGRect) {
        super.init()
        
        directionPad.position = CGPoint(x: CGFloat(20), y: CGFloat(40))
        addChild(directionPad)
        
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
