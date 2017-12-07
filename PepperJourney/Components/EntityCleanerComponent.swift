//
//  EntityCleanerComponent.swift
//  PepperJourney
//
//  Created by Marcelo Martimiano Junior on 07/12/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import GameplayKit
import SceneKit

class EntityCleanerComponent: GKComponent {
    weak var entityManager: EntityManager?
    private(set) var readyToClean: Bool = false
    
    init(entityManager: EntityManager) {
        super.init()
        self.entityManager = entityManager
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        if self.readyToClean {
            
            guard let entity = self.entity else { fatalError() }
            
            if let modelComponent = entity.component(ofType: ModelComponent.self) {
                modelComponent.removeModel()
                entity.removeComponent(ofType: ModelComponent.self)
            }
            
            if entity.component(ofType: SeekComponent.self) != nil {
                self.entityManager?.removeSeekComponent(entity: entity)
                entity.removeComponent(ofType: SeekComponent.self)
            }
            
            if entity.component(ofType: DistanceAlarmComponent.self) != nil {
                self.entityManager?.removeDistanceAlarm(entity: entity)
                entity.removeComponent(ofType: DistanceAlarmComponent.self)
            }
            
            self.readyToClean = false
        }
    }
    func prepareToCleanEntity() {
        self.readyToClean = true
    }
}
