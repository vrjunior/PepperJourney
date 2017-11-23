//
//  PauseOverlay.swift
//  SpicyHero
//
//  Created by Valmir Junior on 13/11/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import SpriteKit

class SettingsOverlay: SKScene {
    
    private var musicSwitch: SKLabelNode!
    private var songSwitch: SKLabelNode!
    //public var gameOptionsDelegate: GameOptions?
    
    override func sceneDidLoad() {
        
        //setup nodes
        self.musicSwitch = self.childNode(withName: "musicSwitch") as! SKLabelNode
        self.songSwitch = self.childNode(withName: "songSwitch") as! SKLabelNode
        
    }
    
    override func didMove(to view: SKView) {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SettingsOverlay.handleTap(_:)))
        
        view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        
        var location = gesture.location(in: self.view)
        location.y = (self.view?.frame.height)! - location.y
        
        if musicSwitch.contains(location) {
            //call the delegate to turnon or turnoff
        }
            
        else if songSwitch.contains(location) {
            //call the delegate to turnon or turnoff
        }
        
    }
    
}

