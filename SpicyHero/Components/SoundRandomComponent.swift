//
//  SoundRandomComponent.swift
//  SpicyHero
//
//  Created by Richard Vaz da Silva Netto on 21/11/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import SceneKit
import GameplayKit
import UIKit

class SoundRandomComponent: GKComponent
{
	var audioSource: SCNAudioSource!
	var audioPlayer: SCNAudioPlayer!
	var didFinishedPlaying: Bool!
	var deltaTimeInterval: TimeInterval! = 0
	var isPlaying: Bool! = false
	var tryPlaySound: Bool! = false
	var nextPlayTime: TimeInterval!
	let waitTime: UInt32! = 40
	
	init (soundPath: String, entity: GKEntity)
	{
		super.init()
		guard let audioSource = SCNAudioSource(fileNamed: soundPath) else
		{
			fatalError("The audio file (\(soundPath)) could not be found.")
		}
		self.audioSource = audioSource
		self.didFinishedPlaying = false
		self.nextPlayTime = TimeInterval(arc4random_uniform(waitTime))
		
		
	}
	public func playMusic(){
		
		self.audioSource.volume = 0.1
		self.audioSource.loops = false
		self.audioSource.shouldStream = false
		self.audioSource.isPositional = true
		
		if let node = self.entity?.component(ofType: ModelComponent.self) {
			self.audioPlayer =  SCNAudioPlayer(source: audioSource)
			node.modelNode.addAudioPlayer(self.audioPlayer)
		}
	}
	override func update(deltaTime seconds: TimeInterval) {
		
		
		if !isPlaying && tryPlaySound {
			self.playMusic()
			self.isPlaying = true
			self.audioPlayer.didFinishPlayback = {
				self.isPlaying = false
			}
		}

		if self.deltaTimeInterval > self.nextPlayTime {
			print("Delta: \(self.deltaTimeInterval)")
			self.deltaTimeInterval = 0
			self.tryPlaySound = true
			self.nextPlayTime = TimeInterval(arc4random_uniform(waitTime))
		}else {
			self.deltaTimeInterval = self.deltaTimeInterval + seconds
			print("Delta: \(self.deltaTimeInterval)")
			self.tryPlaySound = false
		}
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
