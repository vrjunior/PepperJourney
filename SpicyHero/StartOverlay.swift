//
//  StartOverlay.swift
//  SpicyHero
//
//  Created by Valmir Junior on 27/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import SpriteKit


class StartOverlay: SKScene {
    
    var gameOptionsDelegate:GameOptions?
    
    override func sceneDidLoad() {
        
    }
    
    override func didMove(to view: SKView) {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(StartOverlay.handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        gameOptionsDelegate?.start()
    }
}
