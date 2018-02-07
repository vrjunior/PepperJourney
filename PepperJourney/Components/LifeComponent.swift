//
//  LifeComponent.swift
//  PepperJourney
//
//  Created by Valmir Junior on 07/12/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import GameKit

class LifeComponent : GKComponent {
    
    private var lifeValue: Float = 100
    private let maxLifeValue: Float = 100
    
    public var canReceiveDamage: Bool = true
    
    func receiveDamage(enemyCategory: CategoryMaskType, waitTime: Double) {
        
        if self.canReceiveDamage {
            self.canReceiveDamage = false
            
            if self.entity is Character {
                
                if enemyCategory == .potato {
                    self.lifeValue -= 30
                }
                // cactus
                if enemyCategory == .obstacle {
                    self.lifeValue -= 10
                }
            }
            
            if self.entity is PotatoEntity {
                
            }
        }
        
        let when = DispatchTime.now() + waitTime
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.canReceiveDamage = true
        }
    }
    
    func heal(value: Float) {
        if(value <= 0 || value > maxLifeValue) {
            return
        }
        
        self.lifeValue += value
    }
    
    func healAll() {
        self.lifeValue = self.maxLifeValue
    }
    
    func getLifePercentage() -> Float {
        return self.lifeValue / maxLifeValue
    }
    
}
