//
//  SinkComponent.swift
//  PepperJourney
//
//  Created by Marcelo Martimiano Junior on 24/11/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import GameplayKit
import SceneKit

/*
 ATENÇÃO!!!
 Antes de remover o componente chame a função prepareToRemoveComponent
 */
class SinkComponent: GKComponent
{
    private var isUsed: Bool = false
    private weak var soundController: SoundController!
    private weak var node: SCNNode!
    private var soundName: String!
    private static var lastSinkTimeSystem: TimeInterval = 0
    
    init(node: SCNNode, entity: GKEntity) {
        super.init()
        self.soundController = SoundController.sharedInstance
        self.node = node
        self.soundName = "sinkComponent-" + entity.description
        
        // Load the audio source in the memory
        
        self.soundController.loadSound(fileName: "splashingWater.wav", soundName: soundName, volume: 30)
    }
    
    
    func remove() {
        self.soundController.removeAudioSource(soundName: soundName)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func sinkInWater() {
        if !isUsed
        {
            // Block future reprodutions before restart the game
            self.isUsed = true
            
            // Make the physics alterations
//            self.node.physicsBody?.velocityFactor = SCNVector3(0, 0.9, 0)
//            self.node.physicsBody?.damping = 0.9
            
            // Executes the sound
            if SinkComponent.isSoundEnable() {
                self.soundController.playSoundEffect(soundName: self.soundName, loops: false, node: self.node)
            }
        }
    }

    static func isSoundEnable() -> Bool {
        var soundEnable = false
        let currentTime = Date.timeIntervalSinceReferenceDate
        
        // Duration of the current sink in water sound
        let soundDuration: TimeInterval = 2.21
        
        if (currentTime - self.lastSinkTimeSystem) > (soundDuration / 2) {
            soundEnable = true
        }
        self.lastSinkTimeSystem = currentTime
        
        return soundEnable
    }
    func resetComponent()
    {
        isUsed = false
        
        // reset do que foi alterado ao cair na agua
//        self.node.physicsBody?.velocityFactor = SCNVector3(1, 1, 1)
//        self.node.physicsBody?.damping = 0.1
    }
    
    func prepareToRemoveComponent()
    {
        // Remove from memory the sound
        self.soundController.removeAudioSource(soundName: self.soundName)
    }
}

