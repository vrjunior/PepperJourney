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
    weak var character: Character?
    
    
    // colocar aqui os components system
    var seekComponentSystem = GKComponentSystem(componentClass: SeekComponent.self)
    
    // Game entities
    var potatoesEntities = [GKEntity]()
    var potatoGeneratorSystem: PotatoGeneratorSystem?
    
    /// Keeps track of the time for use in the update method.
    var previousUpdateTime: TimeInterval = 0
    
    init (scene: SCNScene, character: Character)
    {
        self.scene = scene
        self.character = character
        self.chasedTargetAgent = character.component(ofType: GKAgent3D.self)
        guard self.chasedTargetAgent != nil else { return }
        
    }
    
    func setupGameInitialization()
    {
        guard let characterNode = self.character?.node else
        {
            fatalError("Error at find character node")
        }
        self.potatoGeneratorSystem = PotatoGeneratorSystem(scene: self.scene, characterNode: characterNode)
        
        let potatoSpawnPoint = SCNVector3(2,50, 285)
        var i = 10
        while i > 0 {
            self.createChasingPotato(position: potatoSpawnPoint)
            i -= 1
        }
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
        if seekComponentSystem.components.count > 0
        {
            self.seekComponentSystem.update(deltaTime: deltaTime)
        }
        // Verify the potato generator points
        self.potatoGeneratorSystem?.update(deltaTime: deltaTime)
        // Create points that are needed.
        if let readyPotatoGenerators = self.potatoGeneratorSystem?.getReadyPotatoGenerators()
        {
            for potatoGenerator in readyPotatoGenerators
            {
                let creationPosition = potatoGenerator.position
                self.createChasingPotato(position: creationPosition)
            }
        }
        self.previousUpdateTime = deltaTime
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
    func killAPotato(node: SCNNode)
    {
        
        for index in 0 ..< self.potatoesEntities.count
        {
            let potato = self.potatoesEntities[index] as! PotatoEntity
            guard let potatoNode = potato.component(ofType: ModelComponent.self)?.modelNode else
            {
                return
            }
            
            if node == potatoNode
            {
                potato.removeModelNodeFromScene()
                potatoesEntities.remove(at: index)
                break
            }
            
        }
    }
}
