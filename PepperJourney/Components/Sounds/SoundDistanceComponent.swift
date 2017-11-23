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
	var audioSource: SCNAudioSource!
	var audioPlayer: SCNAudioPlayer!
	var actionPoint: CGPoint!
	var radius: Float!
	var entityAgent3D: GKAgent3D!
	var node: SCNNode!
	var isPlaying: Bool! = false
	
	init (soundPath: String, entity: GKEntity, actionPoint: CGPoint, minRadius: Float, node: SCNNode)
	{
		super.init()
        guard let audioSource = SCNAudioSource(fileNamed: soundPath) else
        {
            fatalError("The audio file (\(soundPath)) could not be found.")
        }
        guard let agent = entity.component(ofType: GKAgent3D.self) else
        {
            fatalError("No Agent to calculate position.")
        }
        self.entityAgent3D = agent
        self.audioSource = audioSource
        self.actionPoint = actionPoint
        self.radius = minRadius
        self.node = node
		
	}
	public func playMusic(){
		
		self.audioSource.volume = 0.3
		self.audioSource.loops = false
		self.audioSource.shouldStream = true
		self.audioSource.isPositional = false

		self.audioPlayer =  SCNAudioPlayer(source: audioSource)
		node.addAudioPlayer(self.audioPlayer)
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
                playMusic()
                isPlaying = true
            }
        }
    }
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

