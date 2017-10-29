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

class EntityManager
{
    private var scene: SCNScene!
    private var chasedTargetAgent: GKAgent3D!
    
    // colocar aqui os components system
    var seekComponentSystem = GKComponentSystem(componentClass: SeekComponent.self)
    
    // Game entities
    var potatoesEntities = [GKEntity]()
    
    /// Keeps track of the time for use in the update method.
    var previousUpdateTime: TimeInterval = 0
    
    init (scene: SCNScene, chasedTarget: Character)
    {
        self.scene = scene
        self.chasedTargetAgent = chasedTarget.component(ofType: GKAgent3D.self)
        guard self.chasedTargetAgent != nil else { return }
        
    }
    
    func createChasingPotato(position: SCNVector3)
    {
        let potato = PotatoEntity(model: PotatoType.model1 , scene: self.scene, position: position, trakingAgent: self.chasedTargetAgent)
        
        let seekComponent = potato.component(ofType: SeekComponent.self)!
        
        self.seekComponentSystem.addComponent(seekComponent)
        
        self.potatoesEntities.append(potato)
    }
    
    func update(deltaTime: TimeInterval)
    {
        self.seekComponentSystem.update(deltaTime: deltaTime)
    }
    
    func killAllPotatoes ()
    {
        for potato in self.potatoesEntities
        {
            let potato = potato as! PotatoEntity
            potato.removeModelNodeFromScene()
        }
        
        self.potatoesEntities.removeAll()
    }
}
