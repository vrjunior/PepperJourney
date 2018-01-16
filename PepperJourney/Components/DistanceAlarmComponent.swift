//
//  DistanceAlarmComponent.swift
//  PepperJourney
//
//  Created by Marcelo Martimiano Junior on 06/12/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import GameplayKit
import SceneKit
/*
 WARNING:
 The entity must implement DistanceAlarmProtocol
 */
protocol DistanceAlarmDelegate {
    func fireDistanceAlarm(modelComponent: ModelComponent)
}

// Atenção: a entidade precisar ter um ModelComponent

class DistanceAlarmComponent: GKComponent {
    private var targetPosition: SCNVector3!
    private var alarmTriggerRadius: Float!
    private var isAlarmFired: Bool = false
    private var entityManager = EntityManager.sharedInstance
    private var distanceAlarmDelegate: DistanceAlarmDelegate!
    
    
    init(targetPosition: SCNVector3, alarmTriggerRadius: Float, distanceAlarmDelegate: DistanceAlarmDelegate) {
        super.init()
        self.targetPosition = targetPosition
        self.alarmTriggerRadius = alarmTriggerRadius
        self.distanceAlarmDelegate = distanceAlarmDelegate
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        if self.isAlarmFired {
            return
        }
        
        guard let modelComponent = self.entity?.component(ofType: ModelComponent.self) else {
            fatalError("Error getting model Component in Distance Alarm Component")
        }
        let position = modelComponent.modelNode.presentation.position
        
        let distance = getDistance(point1: float3(position), point2: float3(targetPosition))
        
        if distance < self.alarmTriggerRadius {
            
            guard let entity = self.entity else {
                fatalError("Error getting entity of DistanceAlarmComponent")
            }
            
            self.distanceAlarmDelegate.fireDistanceAlarm(modelComponent: modelComponent)
            
            // fire the alarm
            self.isAlarmFired = true
        }
    }
    
    func getDistance(point1: float3, point2: float3) -> Float {
        let deltaX = point1.x - point2.x
        let deltaY = point1.y - point2.y
        let deltaZ = point1.z - point2.z
        return sqrt((deltaX * deltaX) + (deltaY * deltaY) + (deltaZ * deltaZ))
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

