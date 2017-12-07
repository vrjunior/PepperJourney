//
//  attackLimiterComponent.swift
//  PepperJourney
//
//  Created by Marcelo Martimiano Junior on 07/12/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import SceneKit
import GameplayKit

class AttackLimiterComponent: GKComponent {
    private var rechargeInterval: TimeInterval!
    private var timer: TimeInterval = 0
    private(set) var dischargeRate: Float!
    private(set) var chargeRate: Float!
    
    
    init(rechargeInterval: TimeInterval, chargeRate: Float, dischargeRate: Float) {
        super.init()
        self.rechargeInterval = rechargeInterval
        self.chargeRate = chargeRate
        self.dischargeRate = dischargeRate
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tryAttack(originNode: SCNNode, direction: float3, velocity: float3)
    {
        guard let entity = self.entity else { fatalError()}
        
        guard let powerLevelComponent = entity.component(ofType: PowerLevelCompoenent.self) else {fatalError()}
        
        let powerLevel: Float? = powerLevelComponent.dischargePower(discharge: self.dischargeRate)
        //ATUALIZAR OVERLAY
        if powerLevel == nil {
            emptyFireLevelHandler()
        }
        else {
            guard let attackComponent = entity.component(ofType: AttackComponent.self) else {fatalError()}
            
            
            attackComponent.attack(originNode: originNode, direction: direction, velocity: velocity)
        }
        
        
    }
    func emptyFireLevelHandler() {
        
    }
    override func update(deltaTime seconds: TimeInterval) {
        self.timer += seconds
        
        if self.timer > self.rechargeInterval {
            guard let entity = self.entity else { fatalError()}
            guard let powerLevelComponent = entity.component(ofType: PowerLevelCompoenent.self) else {fatalError()}
            let _ = powerLevelComponent.chargePower(charge: self.chargeRate)
            
            // Update the indicator overlay
            
            
            self.timer = 0
        }
        
    }
}
