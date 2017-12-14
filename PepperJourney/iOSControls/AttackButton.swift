//
//  MovesOverlay.swift
//  PepperJourney
//
//  Created by Valmir Junior on 27/11/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import SpriteKit

class AttackButton: SKSpriteNode {
    
    var delegate: Controls?
    var parentOverlay: ControlsOverlay?
    
    var isPausedControls: Bool = false {
        didSet {
            if isPausedControls {
                self.destroyButton()
            }
            else {
                self.buildButton()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if !isPausedControls{
            delegate?.attack()
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.isUserInteractionEnabled = true
        
        self.parentOverlay = self.scene as? ControlsOverlay
        
//        self.draw()
    }
    
    func draw() {
        self.color = UIColor.clear
        
        let lineWidth:CGFloat = 3.0
        
        let circleRect = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(self.size.width), height: CGFloat(self.size.height))
        
        let circle = SKShapeNode()
        circle.path = CGPath( ellipseIn: circleRect, transform: nil )
        circle.strokeColor = SKColor.black
        circle.lineWidth = lineWidth
        circle.fillColor = SKColor.white.withAlphaComponent(0.5)
        
        self.addChild(circle)
    }
    
    func destroyButton() {
        self.alpha = 0
    }
    
    func buildButton() {
        self.alpha = 1
    }
    
}

