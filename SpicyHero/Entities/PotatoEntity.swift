//
//  PotatoEntity.swift
//  SpicyHero
//
//  Created by Marcelo Martimiano Junior on 20/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import GameplayKit

class PotatoEntity: GKEntity
{
    // Reference to model of potato
    var potatoNode: SCNNode!
    
    // reference to main scene
    private var scene: SCNScene!
    
    private var assetsPath: String!
    
    init(model: PotatoType, scene: SCNScene, position: SCNVector3, trakingAgent: GKAgent3D)
    {
        super.init()
        
        self.assetsPath = "Game.scnassets/potato/\(model.rawValue)/"
        
        self.scene = scene
        
        self.loadPotato(position: position)
        
        self.addSeekBehavior(trackingAgent: trakingAgent)
        self.loadAnimations()
        
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadPotato(position: SCNVector3)
    {
        let potatoScene = SCNScene(named: (self.assetsPath + "model.scn"))!
        
        let name = "potatoNode"
        
        guard let potatoNode = potatoScene.rootNode.childNode(withName: name, recursively: false) else
        {
            fatalError("Making box with name \(name) failed because the GameScene scene file contains no nodes with that name.")
        }
        
        self.potatoNode = potatoNode
        
        potatoNode.position = position
        
        self.scene.rootNode.addChildNode(self.potatoNode)
        
    }
    
    private func addSeekBehavior(trackingAgent: GKAgent3D)
    {
        let seekComponent = SeekComponent(target: trackingAgent)
        //seekComponent.delegate = self
        self.addComponent(seekComponent)
    }
    
    //Load all animation of the Potato
    private func loadAnimations()
    {
        let animations:[AnimationType] = [.running]
        
        for anim in animations {
            let animation = SCNAnimationPlayer.withScene(named: (self.assetsPath + anim.rawValue))
        
            animation.stop()
            self.potatoNode.addAnimationPlayer(animation, forKey: anim.rawValue)
        }
    }
    
    func playAnimation(type: AnimationType) {
        self.potatoNode.animationPlayer(forKey: type.rawValue)?.play()
    }
    
    func stopAnimation(type: AnimationType) {
        self.potatoNode.animationPlayer(forKey: type.rawValue)?.stop()
    }
}

