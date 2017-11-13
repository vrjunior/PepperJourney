//
//  GameOverOverlay.swift
//  SpicyHero
//
//  Created by Marcelo Martimiano Junior on 28/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.

import Foundation
import SpriteKit


class GameOverOverlay: SKScene
{
    var gameOptionsDelegate: GameOptions?
    
    override func sceneDidLoad()
    {
        
    }
    
    override func didMove(to view: SKView)
    {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(GameOverOverlay.handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer)
    {
        gameOptionsDelegate?.restart()
    }
}
