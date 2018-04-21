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
    private weak var originNode: SCNNode!
    private weak var targetNode: SCNNode!
    
    init(scene: SCNScene, originNode: SCNNode, targetNode: SCNNode)
    {
        super.init()
        self.scene = scene
        self.originNode = originNode
        self.targetNode = targetNode
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func attack(character: SCNNode, forceModule: Float)
    {
        guard let scene = SCNScene(named: "Game.scnassets/character/FireBall.scn") else
        {
            fatalError("Error getting FireBall.scn")
        }
        guard let fireBall = scene.rootNode.childNode(withName: "fireball", recursively: false) else {
            fatalError("Error getting fireball node")
        }
        
       
        
        
        let origin = self.originNode.presentation.worldPosition
        let target = self.targetNode.presentation.worldPosition
        
        
        // direction
        let direction = SCNVector3(target.x - origin.x, 0, target.z - origin.z)
        
        
        // add to the scene
        let characterPosition = character.presentation.worldPosition
        fireBall.worldPosition = characterPosition
        fireBall.worldPosition.y += 5
        self.scene.rootNode.addChildNode(fireBall)

        // Handle with the movimentation of fireball
        var forceVector = SCNVector3()

        forceVector.x = direction.x * forceModule
        forceVector.z = direction.z * forceModule
        forceVector.y = 20

        fireBall.physicsBody?.applyForce(forceVector, asImpulse: true)

        // Controller of disapear the fireballs
        let newAttack = Attack(fireBall: fireBall, time: 0)
        self.attacks.append(newAttack)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        // Make the balls disapears after fireBallLifeTime seconds
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
