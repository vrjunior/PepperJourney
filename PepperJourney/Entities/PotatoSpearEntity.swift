//
//  PotatoSpearEntity.swift
//  PepperJourney
//
//  Created by Richard Vaz da Silva Netto on 07/12/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import GameplayKit

enum PotatoSpearType: String
{
	case model1 = "potatoSpear"
}

class PotatoSpearEntity: GKEntity
{
	// reference to main scene
	private var scene: SCNScene!
	// reference to potatoModel
	private var potatoModel: ModelComponent!
	
	//seek component params for potatoes
	
	private let maxSpeed: Float = 150
	private let maxAcceleration: Float = 50
	
	
	
	init(model: PotatoType, scene: SCNScene, position: SCNVector3, trakingAgent: GKAgent3D)
	{
		super.init()
		
		self.scene = scene
		let path = "Game.scnassets/characters/potato/potatoSpear.scn"
		
		self.potatoModel = ModelComponent(modelPath: path, scene: scene, position: position)
		self.addComponent(self.potatoModel)
		
		self.addSeekBehavior(trackingAgent: trakingAgent)
		self.loadAnimations()
		
		self.playAnimation(type: .running)
		
		let soundRandomComponent = SoundRandomComponent(soundPath: "potatoSound.wav", entity: self)
		self.addComponent(soundRandomComponent)
		
	}
	
	required init?(coder aDecoder: NSCoder)
	{
		fatalError("init(coder:) has not been implemented")
	}
	
	private func addSeekBehavior(trackingAgent: GKAgent3D)
	{
		
		let seekComponent = SeekComponent(target: trackingAgent, maxSpeed: maxSpeed, maxAcceleration: maxAcceleration)
		self.addComponent(seekComponent)
		
	}
	
	//Load all animation of the Potato
	private func loadAnimations()
	{
		let animations:[AnimationType] = [.running]
		
		for anim in animations {
			let animation = SCNAnimationPlayer.withScene(named: "Game.scnassets/characters/potato/\(anim.rawValue).dae")
			
			animation.stop()
			self.potatoModel.modelNode.addAnimationPlayer(animation, forKey: anim.rawValue)
		}
	}
	// Coloque nessa função tudo que precisa ser tratado quando for remover uma batata
	func prepareToKillPotato()
	{
		// Prepara o Sink Component para ser removido
		self.component(ofType: SinkComponent.self)?.prepareToRemoveComponent()
		
		// Remove o nó da cena
		self.potatoModel.removeModel()
		
	}
	
	
	func playAnimation(type: AnimationType) {
		self.potatoModel.modelNode.animationPlayer(forKey: type.rawValue)?.play()
	}
	
	func stopAnimation(type: AnimationType) {
		self.potatoModel.modelNode.animationPlayer(forKey: type.rawValue)?.stop()
	}
	
	func getPosition() -> SCNVector3
	{
		return self.potatoModel.modelNode.presentation.position
	}
	
	func pauseNode() {
		self.potatoModel.modelNode.isPaused = true
	}
}

