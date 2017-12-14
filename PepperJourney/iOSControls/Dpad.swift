//
//  Dpad.swift
//  SpicyHero
//
//  Created by Valmir Junior on 11/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import SpriteKit

@IBDesignable class Dpad : SKSpriteNode {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.color = UIColor.clear
        
        let lineWidth:CGFloat = 9.0
        
        let backgroundRect = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(self.size.width), height: CGFloat(self.size.height))
        
        let background = SKShapeNode()
        background.path = CGPath( ellipseIn: backgroundRect, transform: nil )
        background.strokeColor = SKColor.black
        background.lineWidth = lineWidth
        
        self.addChild(background)
    }
    
}
