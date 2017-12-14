//
//  Stick.swift
//  SpicyHero
//
//  Created by Valmir Junior on 11/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import SpriteKit

@IBDesignable class Stick : SKSpriteNode {
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        self.color = UIColor.clear
        
        let lineWidth:CGFloat = 6.0
        
        let stickRect = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(self.size.width), height: CGFloat(self.size.height))
    
        let stick = SKShapeNode()
        stick.path = CGPath( ellipseIn: stickRect, transform: nil)
        stick.lineWidth = lineWidth
        stick.strokeColor = SKColor.black
        stick.fillColor = SKColor.white
        
        self.addChild(stick)
    }
    
}
