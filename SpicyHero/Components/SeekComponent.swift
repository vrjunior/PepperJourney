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

class SeekComponent: GKAgent3D, GKAgentDelegate
{
    init(target: GKAgent3D)
    {
        super.init()
        var goal = GKGoal(toSeekAgent: target)
        
        self.behavior = GKBehavior(goal: goal, weight: 1)
        self.maxSpeed = 0.00002
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
        

        position = float3(modelComponent.modelNode.presentation.position)
        
    }
    func agentDidUpdate(_ agent: GKAgent) {
        
        guard let modelComponent = self.entity?.component(ofType: ModelComponent.self) else {return}
        modelComponent.modelNode.position.x = position.x
        modelComponent.modelNode.position.z = position.z
        
        print("speed: \(speed) | position: \(position)")
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        // It calls agentWillUpdate before and agentDidUpdate after
        super.update(deltaTime: seconds)
        
    }
}
