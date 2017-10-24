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
    
    init (modelPath: String, scene: SCNScene, position: SCNVector3)
    {
        super.init()
        
        guard let modelScene = SCNScene(named: modelPath) else
        {
            fatalError("The scene file (\(modelPath)) contains no nodes with that name wanted.")
        }
        
        self.modelNode = modelScene.rootNode.childNode(withName: "modelNode", recursively: false)
        
        guard self.modelNode != nil else {return}
        
        self.modelNode.position = position
        
        scene.rootNode.addChildNode(self.modelNode)

        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
