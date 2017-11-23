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
    var potatoGenerators = [PotatoGenerator]()
    var readyPotatoGenerator = [PotatoGenerator]()
    
    let distanceToGenerate:Float = 10
    weak var characterNode: SCNNode?
    
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
            let potatoGenerator  = PotatoGenerator(position: position, distanceToCreate: self.distanceToGenerate)
            
            self.potatoGenerators.append(potatoGenerator)
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        guard let characterPosition = self.characterNode?.presentation.position else
        {
            fatalError("Error at find character node in Potato Generator System")
        }
        var removeList = [Int]()
        for index in 0 ..< self.potatoGenerators.count
        {
            
            if potatoGenerators[index].isReady(characterPosition: characterPosition)
            {
                removeList.append(index)
            }
        }
        
        // Remove and add
        for index in removeList
        {
            let removed = potatoGenerators.remove(at: index)
            self.readyPotatoGenerator.append(removed)
        }
    }
    func getReadyPotatoGenerators() -> [PotatoGenerator]
    {
        var removedElements = [PotatoGenerator]()
        
        while self.readyPotatoGenerator.count > 0
        {
            removedElements.append(self.readyPotatoGenerator.remove(at: 0))
        }
        
        return removedElements
    }
}
