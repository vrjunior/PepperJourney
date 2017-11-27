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

class PotatoGeneratorSystem: GKEntity
{
    var originalPotatoList = [SCNVector3]()
    var potatoesPositionsToGenerate = [SCNVector3]()
    var readyPotatoes = [SCNVector3]()
    
    let distanceToGenerate:Float = 100
    weak var characterNode: SCNNode!
    
    init(scene: SCNScene, characterNode: SCNNode)
    {
        super.init()
        
        guard let generationPointsNode = scene.rootNode.childNode(withName: "generationPoints" ,recursively: false) else
        {
            fatalError("Error at find generationPoints node")
        }
        self.characterNode = characterNode
        
        let generationPoints = generationPointsNode.childNodes
        
        for generationPoint in generationPoints
        {
            let position = generationPoint.position
            self.originalPotatoList.append(position)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Use this function to reset the points of creation
    func setupPotatoGeneratorSystem() {
        self.potatoesPositionsToGenerate = self.originalPotatoList
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        let characterPosition = self.characterNode.presentation.position
        
        self.readyPotatoes.removeAll()
        
        var index = 0
        while index < self.potatoesPositionsToGenerate.count
        {
            let potatoPosition = self.potatoesPositionsToGenerate[index]
            
            if self.potatoIsReady(characterPosition: characterPosition, potatoPosition: potatoPosition)
            {
                let readyPotato = self.potatoesPositionsToGenerate.remove(at: index)
                
                self.readyPotatoes.append(readyPotato)
            }
            else
            {
                index += 1
            }
        }
    }
    
    func getReadyPotatoes() -> [SCNVector3]
    {
        return self.readyPotatoes
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

