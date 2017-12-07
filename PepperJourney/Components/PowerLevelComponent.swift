//
//  FireLevelComponent.swift
//  PepperJourney
//
//  Created by Marcelo Martimiano Junior on 07/12/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import SceneKit
import GameplayKit

class PowerLevelCompoenent: GKComponent {
    private(set) var currentPowerLevel: Float = 0
    private(set) var defaultPowerLevel: Float!
    private(set) var MaxPower: Float!

    init(MaxPower: Float, defaultPowerLevel: Float) {
        super.init()
        self.MaxPower = MaxPower
        self.defaultPowerLevel = defaultPowerLevel
        self.resetPowerLevel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resetPowerLevel() {
       self.currentPowerLevel = self.defaultPowerLevel
    }
    
    func chargePower(charge: Float) -> Float
    {
        if self.currentPowerLevel  + charge > self.MaxPower {
            self.currentPowerLevel = self.MaxPower
        }
        else {
            self.currentPowerLevel += charge
        }

        return Float(self.currentPowerLevel) / Float(self.MaxPower)
    }
    
    
    func dischargePower(discharge: Float) -> Float?
    {
        if self.currentPowerLevel - discharge < 0 {
            return nil
        }
        else {
            self.currentPowerLevel -= discharge
        }
        
        return Float(self.currentPowerLevel) / Float(self.MaxPower)
    }
}
