//
//  NewMission.swift
//  PepperJourney
//
//  Created by Marcelo Martimiano Junior on 15/01/18.
//  Copyright © 2018 Valmir Junior. All rights reserved.
//

import Foundation
import SpriteKit

class NewMissionOverlay: SKScene, SKButtonDelegate {
    
    public var gameOptionsDelegate: GameOptions?
    private var resumeButton: SKButton!
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        self.resumeButton = self.childNode(withName: "resumeButton") as! SKButton
        self.resumeButton.delegate = self
    }
    
    func buttonPressed(target: SKButton) {
        
    }
    
    func buttonReleased(target: SKButton) {
        if target == self.resumeButton {
            self.gameOptionsDelegate?.resume()
        }
    }
}
