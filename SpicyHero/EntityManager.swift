//
//  EntityManager.swift
//  SpicyHero
//
//  Created by Marcelo Martimiano Junior on 20/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import GameplayKit
import SceneKit
import Foundation

enum PotatoType: String
{
    case model1 = "Potato1"
    case model2 = "Potato2"
}

class EntityManager
{
    private var scene: SCNScene!
    
    // colocar aqui os components system
    
    // Game entities
    var entities = [GKEntity]()
    
    /// Keeps track of the time for use in the update method.
    var previousUpdateTime: TimeInterval = 0
    
    init (scene: SCNScene)
    {
        self.scene = scene
        
    }
    
    
}
