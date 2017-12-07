//
//  TimeAlarmComponent.swift
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
protocol TimeAlarmProtocol {
    func fireAlarm()
}

class TimeAlarmComponent: GKComponent {
    private var time: TimeInterval = 0
    private var trigerTime: TimeInterval!
    
    init(trigerTime: TimeInterval) {
        super.init()
        self.trigerTime = trigerTime
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        
        self.time += seconds
        
        if self.time > self.trigerTime {
            let entity = self.entity as! TimeAlarmProtocol
            entity.fireAlarm()
            self.entity?.removeComponent(ofType: TimeAlarmComponent.self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

