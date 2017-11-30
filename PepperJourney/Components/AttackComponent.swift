//
//  AtackComponent.swift
//  PepperJourney
//
//  Created by Marcelo Martimiano Junior on 27/11/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import GameplayKit
import SceneKit

struct Attack {
    var fireBall: SCNNode
    var time: TimeInterval
}
class AttackComponent: GKComponent
{
    private var attacks = [Attack]()
    private weak var scene: SCNScene!
    private var fireBallLifeTime: TimeInterval = 1
    
    init(scene: SCNScene)
    {
        super.init()
        self.scene = scene
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func atack(originNode: SCNNode, direction: float3, velocity: float3)
    {
        guard let scene = SCNScene(named: "Game.scnassets/character/FireBall.scn") else
        {
            fatalError("Error getting FireBall.scn")
        }
        guard let fireBall = scene.rootNode.childNode(withName: "fireball", recursively: false) else {
            fatalError("Error getting fireball node")
        }
        
        // Initial position
        fireBall.position = originNode.presentation.position
        fireBall.position.y += 7
        fireBall.position.z += 2
        
        // add to the scene
        self.scene.rootNode.addChildNode(fireBall)
        
        // Handle with the movimentation of fireball
        var forceVector = SCNVector3()
        
        if velocity.allZero()
        {
            // Parameters chosen empirically
            forceVector.x = 10 * direction.x
            forceVector.z = 10 * direction.z
            print(direction)
        }
        else
        {
            forceVector.x = direction.x + 15 * velocity.x
            forceVector.z = direction.z + 15 * velocity.z
           
        }

        forceVector.y = 20
        
        fireBall.physicsBody?.applyForce(forceVector, asImpulse: true)
        
        // Controller of disapear the fireballs
        let newAttack = Attack(fireBall: fireBall, time: 0)
        self.attacks.append(newAttack)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        
        var index = 0
        while index < self.attacks.count
        {
            self.attacks[index].time += seconds
            
            if self.attacks[index].time > self.fireBallLifeTime
            {
                self.attacks[index].fireBall.removeFromParentNode()
                self.attacks.remove(at: index)
            }
            else
            {
                index += 1
            }
        }
        
        super.update(deltaTime: seconds)
    }
    
}
