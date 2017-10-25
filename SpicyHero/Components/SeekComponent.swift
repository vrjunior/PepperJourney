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
        self.maxSpeed = 0.000002//0.00001
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
        
//            float3(modelComponent.modelNode.presentation.eulerAngles))
        
    }
    func agentDidUpdate(_ agent: GKAgent) {
        
        guard let modelComponent = self.entity?.component(ofType: ModelComponent.self) else {return}
        modelComponent.modelNode.position.x = position.x
        modelComponent.modelNode.position.z = position.z
        
        
    
        let xVelocity = self.velocity.x
        let zVelocity = self.velocity.z
        
        let angle = -Float(atan2(zVelocity, xVelocity)) + Float.pi/2
        
        print (angle)
        
        modelComponent.modelNode.rotation = SCNVector4(0,1,0, angle)
        
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        // It calls agentWillUpdate before and agentDidUpdate after
        super.update(deltaTime: seconds)
        
    }
}
//extension matrix_float3x3
//{
//    var scnVector3: SCNVector3
//    {
//        get
//        {
//            return scnVector3
//        }
//        set
//        {
//            self.scnVector3 = newValue
//        }
//    }
//    init(matrix_float3x3Value: matrix_float3x3)
//    {
//        var sceneVector3Value = SCNVector3()
//
//        //sceneVector3Value.x = matrix_float3x3Value.columns.0
//    }
//
//}

