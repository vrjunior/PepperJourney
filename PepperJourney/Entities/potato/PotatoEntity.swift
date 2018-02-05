//
//  PotatoEntity2.swift
//  PepperJourney
//
//  Created by Marcelo Martimiano Junior on 21/12/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.

import Foundation
import GameplayKit

public enum PotatoType: String {
    case disarmad = "disarmadPotato"
    case spear = "spearPotato"
}

class PotatoEntity: GKEntity {
    // reference to main scene
    private var scene: SCNScene!
    
    // Type of potato
    public var potatoType: PotatoType!
    public var tag: String?
    
    //seek component params for potatoes
    
    private let maxSpeedDefault: Float = 150
    private let maxAccelerationDefault: Float = 50
    
    private var persecutedTarget: GKAgent3D!
    
    public var stateMachine: GKStateMachine!
    
    init(type: PotatoType, scene: SCNScene, position: SCNVector3, animations:[AnimationType], potatoStates: [PotatoState], tag: String? = nil) {
        super.init()
        
        self.potatoType = type
        self.tag = tag
        
        // Add model component
        let path = "Game.scnassets/characters/potato/\(self.potatoType.rawValue)/potato.scn"
        let modelComponent = ModelComponent(modelPath: path, scene: scene, position: position)
        self.addComponent(modelComponent)
        
        
        // Add animations
        self.loadAnimations(animationList: animations)
        
        self.stateMachine = PotatoStateMachine(states: potatoStates, potato: self)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //Load all animation of the Potato
    private func loadAnimations(animationList: [AnimationType])
    {
        let modelComponent = self.getModelComponent()
        for anim in animationList {
            let animation = SCNAnimationPlayer.withScene(named: "Game.scnassets/characters/potato/\(potatoType.rawValue)/\(anim.rawValue).dae")
            
            animation.stop()
            
            modelComponent.modelNode.addAnimationPlayer(animation, forKey: anim.rawValue)
        }
    }
    
    func playAnimation(type: AnimationType, speed: CGFloat? = nil, repeatCount: CGFloat? = nil, runBlockAfter: ((SCNAnimation, SCNAnimatable, Bool) -> Void)? = nil) {
        
        if let animation = self.getModelComponent().modelNode.animationPlayer(forKey: type.rawValue) {
            
            if let animationSpeed = speed {
                animation.speed = animationSpeed
            }
            if let repeatCount = repeatCount {
                animation.animation.repeatCount = repeatCount
            }
            if let block = runBlockAfter {
                animation.animation.animationDidStop = block
            }
            
            animation.play()
            print("animation ok")
        }
        else {
            print("Error getting " + type.rawValue + "animation!!!!!!")
        }
    }
    
    func stopAnimation(type: AnimationType) {
        self.getModelComponent().modelNode.animationPlayer(forKey: type.rawValue)?.stop()
    }
    
    func getModelComponent() -> ModelComponent {
        guard let modelComponent = self.component(ofType: ModelComponent.self) else {
            fatalError("Error getting modelComponent")
        }
        return modelComponent
    }
    
    public func setPersecutionBehavior(persecutedTarget: GKAgent3D, maxSpeed: Float? = nil, maxAcceleration: Float? = nil)
    {
        // Set max Speed
        var limitSpeed: Float
        if maxSpeed != nil {
            limitSpeed = maxSpeed!
        }
        else {
            limitSpeed = self.maxSpeedDefault
        }
        
        // Set max acceleration
        var limitAcceleration: Float
        if maxAcceleration != nil {
            limitAcceleration = maxAcceleration!
        }
        else {
            limitAcceleration = self.maxAccelerationDefault
        }
        
        let pursueComponent = PursueComponent(target: persecutedTarget, maxSpeed: limitSpeed, maxAcceleration: limitAcceleration)
        
        self.addComponent(pursueComponent)
        
        // Add the component to the component system
        EntityManager.sharedInstance.loadToComponentSystem(component: pursueComponent)
    }
    
    public func removesPersecutionBehavior() {
        
        if let pursueComponent = self.component(ofType: PursueComponent.self) {
            EntityManager.sharedInstance.removeOfComponentSystem(component: pursueComponent)
            self.removeComponent(ofType: PursueComponent.self)
        }
    }
    
    public func setSinkBehavior() {
        
        // Add the component that enable the potato sink in water
        guard let potatoNode = self.getModelComponent().modelNode else {
            print("Error getting model Node")
            return
        }
        
        let sinkComponent = SinkComponent(node: potatoNode, entity: self)
        
        self.addComponent(sinkComponent)
        
        // add the sinkComponent to ComponentSystem
        EntityManager.sharedInstance.loadToComponentSystem(component: sinkComponent)
    }
    
    public func killPotato() {
        // Prepara o Sink Component para ser removido
        self.component(ofType: SinkComponent.self)?.prepareToRemoveComponent()
        
        // Remove o nó da cena
        self.getModelComponent().removeModel()
    }
    
    /************************************************************************************************************************************************************************************/
    func getPosition() -> SCNVector3
    {
        return  self.getModelComponent().modelNode.presentation.position
    }
    
    func pauseNode() {
        self.getModelComponent().modelNode.isPaused = true
    }
    
    func getEnemyNode() -> SCNNode {
        return self.getModelComponent().modelNode
    }
    
    func attack() {
        
    }
    
}

