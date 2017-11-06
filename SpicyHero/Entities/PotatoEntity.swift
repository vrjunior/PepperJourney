//
//  PotatoEntity.swift
//  SpicyHero
//
//  Created by Marcelo Martimiano Junior on 20/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import GameplayKit

enum PotatoType: String
{
    case model1 = "potato"
}

class PotatoEntity: GKEntity
{
    // reference to main scene
    private var scene: SCNScene!
    // reference to potatoModel
    private var potatoModel: ModelComponent!
    
    //seek component params for potatoes
    private let maxSpeed: Float = 0.000019
    private let maxAcceleration: Float = 0.00001
    
    init(model: PotatoType, scene: SCNScene, position: SCNVector3, trakingAgent: GKAgent3D)
    {
        super.init()
        
        self.scene = scene

        let path = "Game.scnassets/potato/potato.scn"
        self.potatoModel = ModelComponent(modelPath: path, scene: scene, position: position)
        
        self.addComponent(self.potatoModel)
        
        self.addSeekBehavior(trackingAgent: trakingAgent)
        self.loadAnimations()
        
        self.playAnimation(type: .running)
        
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSeekBehavior(trackingAgent: GKAgent3D)
    {
        guard let mass = self.potatoModel.modelNode.physicsBody?.mass else {
            print("Could not get potato mass")
            return
        }
        
        let seekComponent = SeekComponent(target: trackingAgent, maxSpeed: maxSpeed, maxAcceleration: maxAcceleration, mass: Float(mass))
        self.addComponent(seekComponent)
    }
    
    //Load all animation of the Potato
    private func loadAnimations()
    {
        let animations:[AnimationType] = [.running]
        
        for anim in animations {
            let animation = SCNAnimationPlayer.withScene(named: "Game.scnassets/potato/\(anim.rawValue).dae")
        
            animation.stop()
            self.potatoModel.modelNode.addAnimationPlayer(animation, forKey: anim.rawValue)
        }
    }
    
    func removeModelNodeFromScene()
    {
        self.potatoModel.removeModel()
    }
    
    func playAnimation(type: AnimationType) {
        self.potatoModel.modelNode.animationPlayer(forKey: type.rawValue)?.play()
    }
    
    func stopAnimation(type: AnimationType) {
        self.potatoModel.modelNode.animationPlayer(forKey: type.rawValue)?.stop()
    }
}

