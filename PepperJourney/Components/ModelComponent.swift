//
//  ModelComponent.swift
//  SpicyHero
//
//  Created by Marcelo Martimiano Junior on 24/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import SceneKit
import GameplayKit

class ModelComponent: GKComponent
{
    private(set) var modelNode: SCNNode!
    
    /*
     modelPath: scene of the model
     scene: Scene destination
     Atenção: o nome do nó contendo a mash deve ser "modelNode"
     */
    init (modelPath: String, scene: SCNScene, position: SCNVector3)
    {
        super.init()
        
        guard let modelScene = SCNScene(named: modelPath) else
        {
            fatalError("The scene file (\(modelPath)) contains no nodes with that name wanted.")
        }
        
        self.modelNode = modelScene.rootNode.childNode(withName: "modelNode", recursively: false)
        
        guard self.modelNode != nil else {
            fatalError("Error! Not found \"modelNode\" in scene \(modelPath)")
        }
        
        self.modelNode.position = position
        
        scene.rootNode.addChildNode(self.modelNode)
        
        
    }
    public func removeModel() {
        if modelNode.parent != nil {
            self.modelNode.removeFromParentNode()
        }
        else{
            print("já foi removido")
        }
    }
    
    public func setPosition(newPosition: SCNVector3) {
        self.modelNode.position = newPosition
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

