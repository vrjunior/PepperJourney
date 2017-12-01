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

class SoundDistanceComponent: GKComponent
{
	
	var actionPoint: CGPoint!
	var radius: Float!
	var entityAgent3D: GKAgent3D!
	var isPlaying: Bool! = false
	private weak var soundController: SoundController!
	private var soundName: String!
	private weak var node: SCNNode!
	
	init (fileName: String, actionPoint: CGPoint, minRadius: Float, entity: GKEntity, node: SCNNode, soundController: SoundController)
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
	
	deinit {
		self.soundController.removeAudioSource(soundName: soundName)
	}
	
	public func playSoundEffect() {
		// Executes the sound
		self.soundController.playSoundEffect(soundName: self.soundName, loops: false, node: self.node)
	}
	
    
    override func update(deltaTime seconds: TimeInterval) {
        
        //get the distance
        if !isPlaying {
            let distanceOfPoint = sqrt(
                powf(Float(actionPoint.x) - self.entityAgent3D.position.x, 2)
                    + powf(Float(actionPoint.y) - self.entityAgent3D.position.z, 2)
            )
            
            //Check if its close
            if distanceOfPoint < self.radius {
                isPlaying = true
                print("sound played")
                playSoundEffect()
            }
        }
    }
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

