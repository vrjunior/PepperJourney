//
//  EscapeComponent.swift
//  PepperJourney
//
//  Created by Marcelo Martimiano Junior on 04/12/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import GameplayKit
import SceneKit

enum CaptiveType {
    case Avocado
    case Tomato
}
class CaptiveComponent: GKComponent {
    init (initialPosition: SCNVector3, type: CaptiveType) {
        super.init()
    }
    
    func getCharecterScene(type: CaptiveType) -> String {
        var characterScene: String
        
        switch type {
            case CaptiveType.Avocado:
                characterScene = "Game.scnassets/characters/Avocado.dae"
            case CaptiveType.Tomato:
                characterScene = "Game.scnassets/characters/Tomato.dae"
        }
        
        return characterScene
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
