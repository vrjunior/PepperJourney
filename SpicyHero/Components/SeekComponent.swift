//
//  SeekComponent.swift
//  SpicyHero
//
//  Created by Marcelo Martimiano Junior on 23/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import GameplayKit
import SceneKit
import CoreGraphics

class SeekComponent: GKAgent3D, GKAgentDelegate
{
    init(target: GKAgent3D)
    {
        super.init()
        let goal = GKGoal(toSeekAgent: target)
        
        self.behavior = GKBehavior(goal: goal, weight: 1)
        self.maxSpeed = 0.00001
        self.maxAcceleration = 0.00000001
        self.mass = 30.0
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func agentWillUpdate(_ agent: GKAgent)
    {
        
        guard let modelComponent = self.entity?.component(ofType: ModelComponent.self) else {return}
        

        self.position = float3(modelComponent.modelNode.presentation.position)
        self.position.y = 0
        
    }
    func agentDidUpdate(_ agent: GKAgent) {
        
        guard let modelComponent = self.entity?.component(ofType: ModelComponent.self) else {return}
        modelComponent.modelNode.position.x = position.x
        modelComponent.modelNode.position.z = position.z
        
        let xVelocity = self.velocity.x
        let zVelocity = self.velocity.z
        
        let angle = -Float(atan2(zVelocity, xVelocity)) + Float.pi/2
        
        modelComponent.modelNode.rotation = SCNVector4(0,1,0, angle)
        
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        // It calls agentWillUpdate before and agentDidUpdate after
        super.update(deltaTime: seconds)
        
    }
}

