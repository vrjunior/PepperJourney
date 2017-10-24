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
    // reference to main scene
    private var scene: SCNScene!
    
    private var assetsPath: String!
    
    init(model: PotatoType, scene: SCNScene, position: SCNVector3, trakingAgent: GKAgent3D)
    {
        super.init()
        
        let path = "Game.scnassets/Potato/Potato.scn"
        let modelComponent = ModelComponent(modelPath: path, scene: scene, position: position)
       
        
       self.addComponent(modelComponent)
        
        self.addSeekBehavior(trackingAgent: trakingAgent)
        self.loadAnimations()
        
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
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

//            let animation = SCNAnimationPlayer.withScene(named: (self.assetsPath + "jumping.scn"))
//            
//            animation.stop()
//            self.potatoNode.addAnimationPlayer(animation, forKey: "jumping")
            
        
    }
}

