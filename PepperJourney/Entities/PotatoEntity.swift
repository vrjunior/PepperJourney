//
//  PotatoEntity2.swift
//  PepperJourney
//
//  Created by Marcelo Martimiano Junior on 21/12/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.

import Foundation
import GameplayKit

public enum PotatoType: String {
    case model1 = "potato"
}

class PotatoEntity: GKEntity {
    // reference to main scene
    private var scene: SCNScene!
    // reference to potatoModel
    private var potatoModel: ModelComponent!
    
    //seek component params for potatoes
    
    private let defaultMaxSpeed: Float = 150
    private let defaultMaxAcceleration: Float = 50
    
    private var persecutedTarget: GKAgent3D!
    
    
    
    init(model: PotatoType, scene: SCNScene, position: SCNVector3, persecutedTarget: GKAgent3D, maxSpeed: Float? = nil, maxAcceleration: Float? = nil, persecutionBehavior: Bool = true)
    {
        super.init()
        
        self.scene = scene
        let path = "Game.scnassets/characters/potato/potato.scn"
        
        self.potatoModel = ModelComponent(modelPath: path, scene: scene, position: position)
        self.addComponent(self.potatoModel)
        
        self.persecutedTarget = persecutedTarget
       
         // Set max Speed
        var speedLimit: Float
        if maxSpeed != nil {
            speedLimit = maxSpeed!
        }
        else {
            speedLimit = self.defaultMaxSpeed
        }
        // Set max acceleration
        var accelerationLimit: Float
        if maxAcceleration != nil {
            accelerationLimit = maxAcceleration!
        }
        else {
            accelerationLimit = self.defaultMaxAcceleration
        }
        self.loadComponents(persecutionBehavior: persecutionBehavior, maxSpeed: speedLimit, maxAcceleration: accelerationLimit)
        
        self.loadAnimations()
        
        self.playAnimation(type: .running)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func definePersecutionBehavior(isEnable: Bool)
    {
        let seekComponent = self.component(ofType: SeekComponent.self)
        seekComponent?.isRunningEnable = isEnable
    }
    
    func loadComponents(persecutionBehavior: Bool, maxSpeed: Float, maxAcceleration: Float) {
        // Add the seek Component
        let seekComponent = SeekComponent(target: self.persecutedTarget, maxSpeed: maxSpeed, maxAcceleration: maxAcceleration, isRunningEnable: persecutionBehavior)
        self.addComponent(seekComponent)
        
        // Add the component to the component system
        EntityManager.sharedInstance.seekComponentSystem.addComponent(seekComponent)
        
        // Add the component that enable the potato sink in water
        guard let potatoNode = self.component(ofType: ModelComponent.self)?.modelNode else {fatalError("Error getting the node")}
        
        let sinkComponent = SinkComponent(node: potatoNode, entity: self)
        
        self.addComponent(sinkComponent)
        
        // add the sinkComponent to ComponentSystem
        EntityManager.sharedInstance.sinkComponentSystem.addComponent(sinkComponent)
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

extension PotatoEntity : EnemyEntity {
    
    func killEnemy() {
        // Prepara o Sink Component para ser removido
        self.component(ofType: SinkComponent.self)?.prepareToRemoveComponent()
        
        // Remove o nó da cena
        self.potatoModel.removeModel()
        
        
    }
    
    func getEnemyNode() -> SCNNode {
        return self.potatoModel.modelNode
    }
    
    func getEntity() -> GKEntity {
        return self
    }
    
    func attack() {
        
    }
    
}

