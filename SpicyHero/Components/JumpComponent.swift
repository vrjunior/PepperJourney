//
//  Jump.swift
//  SpicyHero
//
//  Created by Valmir Junior on 19/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import GameKit
import SceneKit

class JumpComponent : GKComponent {
    var impulse: Float
    var character: SCNNode
    
    
    init(character: SCNNode, impulse: Float) {
        self.character = character
        self.impulse = impulse
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func jump()
    {
        let currentPosition = self.character.presentation.position
        let jumpDirection = currentPosition.y + impulse
        let direction = SCNVector3(0, jumpDirection, 0)
        self.character.physicsBody?.applyForce(direction, asImpulse: true)
    }
    
}
