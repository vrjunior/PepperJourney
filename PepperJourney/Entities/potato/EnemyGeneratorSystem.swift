//
//  PotatoGeneratorSystem.swift
//  SpicyHero
//
//  Created by Marcelo Martimiano Junior on 29/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import SceneKit
import GameplayKit

class EnemyGeneratorSystem: GKEntity {
    var originalEnemiesList = [SCNNode]()
    var enemiesToGenerate = [SCNNode]()
    var readyEnemies = [SCNNode]()
    
    var distanceToGenerate:Float = 150
    weak var characterNode: SCNNode!
    
    init(scene: SCNScene, characterNode: SCNNode, generationNodes: SCNNode? = nil, distanceToGenerate: Float? = nil)
    {
        super.init()
        
        if distanceToGenerate != nil {
            self.distanceToGenerate = distanceToGenerate!
        }
        var generationPointsNode: SCNNode
        
        if generationNodes != nil {
            generationPointsNode = generationNodes!
        }
        else {
            guard let generationPoints = scene.rootNode.childNode(withName: "generationPoints" ,recursively: false) else
            {
                fatalError("Error at find generationPoints node")
            }
            generationPointsNode = generationPoints
        }
        
            
        self.characterNode = characterNode
        
        let generationPoints = generationPointsNode.childNodes
        
        for generationPoint in generationPoints
        {
            self.originalEnemiesList.append(generationPoint)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Use this function to reset the points of creation
    func setupPotatoGeneratorSystem() {
        self.enemiesToGenerate = self.originalEnemiesList
        
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        let characterPosition = self.characterNode.presentation.position
        
        guard !self.characterNode.isPaused else {
            return
        }
        
        self.readyEnemies.removeAll()
        
        var index = 0
        
        while index < self.enemiesToGenerate.count
        {
            let potatoPosition = self.enemiesToGenerate[index].worldPosition
            
            if self.potatoIsReady(characterPosition: characterPosition, potatoPosition: potatoPosition)
            {
                let readyPotato = self.enemiesToGenerate.remove(at: index)
                
                self.readyEnemies.append(readyPotato)
            }
            else
            {
                index += 1
            }
        }
    }
    
    func getReadyPotatoes() -> [SCNNode]
    {
        return self.readyEnemies
    }
    
    func potatoIsReady(characterPosition: SCNVector3, potatoPosition: SCNVector3) -> Bool
    {
    
        let deltaX = characterPosition.x - potatoPosition.x
        let deltaY = characterPosition.y - potatoPosition.y
        let deltaZ = characterPosition.z - potatoPosition.z
    
        let distance = sqrt((deltaX * deltaX) + (deltaY * deltaY) + (deltaZ * deltaZ))
        
        if distance < self.distanceToGenerate
        {
            return true
        }
        else
        {
            return false
        }
    }
}

