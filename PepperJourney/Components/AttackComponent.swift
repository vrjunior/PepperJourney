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
    private var attackTimes = [TimeInterval]()
    private weak var scene: SCNScene!
    
    init(scene: SCNScene)
    {
        super.init()
        self.scene = scene
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func atack(originNode: SCNNode, angle: Float)
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
        fireBall.position.y += 5
        
        // add to the scene
        self.scene.rootNode.addChildNode(fireBall)
        
        // Handle with the movimentation
        let planeComponents = TrigonometryLib.getAxisComponents(rad: angle)
        var forceVector = SCNVector3()
        guard let nodeVelocity = originNode.physicsBody?.velocity else { fatalError("Error in attack component. Physic body not found")}
        
        forceVector.x = planeComponents.y * 10 + nodeVelocity.x
        forceVector.z = planeComponents.x * 10 + nodeVelocity.z
        forceVector.y = 20
        
        fireBall.physicsBody?.applyForce(forceVector, asImpulse: true)
        
        // Controller of disapear the fireballs
        self.madeAttacks.append(fireBall)
        let time: TimeInterval = 0
        self.attackTimes.append(time)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        var index = 0
        while index < self.attackTimes.count
        {
            self.attackTimes[index] += seconds
            
            if self.attackTimes[index] > 1
            {
                self.madeAttacks[index].removeFromParentNode()
                self.madeAttacks.remove(at: index)
                self.attackTimes.remove(at: index)
            }
            else
            {
                index += 1
            }
        }
        super.update(deltaTime: seconds)
    }
    
}
