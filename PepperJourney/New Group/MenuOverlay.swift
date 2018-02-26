//
//  MenuOverlay.swift
//  PepperJourney
//
//  Created by Marcelo Martimiano Junior on 26/02/18.
//  Copyright © 2018 Valmir Junior. All rights reserved.
//

import Foundation
import SpriteKit
class MenuOverlay: SKScene {
    
    public var gameOptionsDelegate: GameOptions?
    
    private var comics = [SKButton]()
    private let comicsNumber = 5
    override func sceneDidLoad() {
        
        //setup nodes
        for comic in 0 ..< self.comicsNumber {
            if let comicButton = self.childNode(withName: "buttons/\(comic + 1)") as? SKButton {
                comicButton.delegate = self
                self.comics.append(comicButton)
            }
        }
    
    }
}

extension MenuOverlay : SKButtonDelegate {
    func buttonReleased(target: SKButton) {
        target.colorBlendFactor = 0
    }
    
    func buttonPressed(target: SKButton) {
        
        target.colorBlendFactor = target.defaultColorBlendFactor
        
        guard let name = target.name else {
            return
        }
        
        var comic: String
        
        switch name {
        case "1":
            comic = "level1"
        case "2":
            comic = "cutscene1"
        case "3":
            comic = "cutscene2"
        case "4":
            comic = "level2"
        case "5":
            comic = "cutscene3"
        default:
            comic = "level1"
        }
        
        self.gameOptionsDelegate?.goToComic(comic: comic)
    }
    
}

