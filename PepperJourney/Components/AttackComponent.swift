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

class AttackComponent: GKComponent
{
    private var madeAttacks = [SCNNode]()
    private var scene: SCNScene!
    
    
    init(scene: SCNScene)
    {
        super.init()
        self.scene = scene
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func atack(launchPosition: SCNVector3, direction: vector_float2)
    {
        let sphere = SCNSphere(radius: 3)
        let fireBall = SCNNode(geometry: sphere)
        fireBall.position = launchPosition
        
        print(direction)
        let direction1 = SCNVector3(direction.x, 10, direction.y)
        fireBall.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        fireBall.physicsBody?.applyForce(direction1, asImpulse: true)
        scene.rootNode.addChildNode(fireBall)
        self.madeAttacks.append(fireBall)
    }
    
}
