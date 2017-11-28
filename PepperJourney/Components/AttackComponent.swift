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
    
    func atack(launchPosition: SCNVector3, eulerAngle: Float)
    {
        guard let scene = SCNScene(named: "Game.scnassets/character/FireBall.scn") else
        {
            fatalError("Error getting FireBall.scn")
        }
        guard let fireBall = scene.rootNode.childNode(withName: "fireball", recursively: false) else {
            fatalError("Error getting fireball node")
        }
        
        fireBall.position = launchPosition
        
        // Then the angle is between -pi and pi
        let rad = 2 * eulerAngle
        
        let planeComponents = TrigonometryLib.getAxisComponents(rad: rad)
        //print (planeComponents)
        
        var forceVector = SCNVector3(planeComponents.y * 10, 15, planeComponents.x * 10)
        
        fireBall.physicsBody?.applyForce(forceVector, asImpulse: true)
        self.scene.rootNode.addChildNode(fireBall)
        self.madeAttacks.append(fireBall)
        let time: TimeInterval = 0
        self.attackTimes.append(time)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        var index = 0
        while index < self.attackTimes.count
        {
            self.attackTimes[index] += seconds
            
            if self.attackTimes[index] > 5
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
