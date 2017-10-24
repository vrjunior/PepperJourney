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
    private(set) var node: SCNNode!
    
    init (modelPath: String, scene: SCNScene, position: SCNVector3)
    {
        super.init()
        guard let modelScene = SCNScene(named: modelPath) else {return}
        guard modelScene.rootNode.childNode(withName: "model", recursively: false) != nil else {return}
        
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
