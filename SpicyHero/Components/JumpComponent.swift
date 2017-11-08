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

//Jump delegate to call when jump begins
protocol JumpDelegate {
    func didJumpBegin(node:SCNNode)
}

class JumpComponent : GKComponent {
    var impulse: Float
    var character: SCNNode
    
    //delegate is optional to set
    var delegate: JumpDelegate?
    
    init(character: SCNNode, impulse: Float) {
        self.character = character
        self.impulse = impulse
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func jump() {
        let jumpDirection = impulse
        let direction = SCNVector3(0, jumpDirection, 0)
        self.character.physicsBody?.applyForce(direction, asImpulse: true)
        
        
        //yeahhhh, gambiarra a gente aceita, o que a gente não aceita é a derrota
        let when = DispatchTime.now() + 0.1
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.delegate?.didJumpBegin(node: self.character)
        }
    }
    
}
