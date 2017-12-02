//
//  SoundDistanceComponent.swift
//  SpicyHero
//
//  Created by Richard Vaz da Silva Netto on 21/11/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import SceneKit
import GameplayKit
import UIKit

/*
 ATENÇÃO!!!
 Antes de remover o componente chame a função removeSoundPoint
 */

class SoundDistanceComponent: GKComponent
{
	
	var actionPoint: float2!
	var radius: Float!
	var entityAgent3D: GKAgent3D!
	var wasPlayed: Bool! = false
	private weak var soundController: SoundController!
	private var soundName: String!
	private weak var node: SCNNode!
	
	init (fileName: String, actionPoint: float2, minRadius: Float, entity: GKEntity, node: SCNNode, soundController: SoundController)
	{
		super.init()
        guard let agent = entity.component(ofType: GKAgent3D.self) else
        {
            fatalError("No Agent to calculate position.")
        }
        self.entityAgent3D = agent
        self.actionPoint = actionPoint
        self.radius = minRadius
		self.soundController = soundController
		self.soundName = "DistanceComponent" + entity.description + ": sound -> " + fileName
		self.node = node
		
		// Load the audio source in the memory
        self.soundController.loadSound(fileName: fileName, soundName: soundName, volume: 30)
		
	}
    
    func resetComponent()
    {
        self.wasPlayed = false
    }
    
    // Remove from memory the sound
    func removeSoundPoint() {
    
        self.soundController.removeAudioSource(soundName: self.soundName)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        
        //get the distance
        if !wasPlayed {
            let distanceOfPoint = sqrt(
                powf(Float(actionPoint.x) - self.entityAgent3D.position.x, 2)
                    + powf(Float(actionPoint.y) - self.entityAgent3D.position.z, 2)
            )
            
            //Check if its close
            if distanceOfPoint < self.radius {
                wasPlayed = true

                // Executes the sound
                self.soundController.playSoundEffect(soundName: self.soundName, loops: false, node: self.node)
            }
        }
    }
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

