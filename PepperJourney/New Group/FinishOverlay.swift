//
//  FinishOverlay.swift
//  PepperJourney
//
//  Created by Valmir Junior on 28/11/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import SpriteKit
import UIKit.UIGestureRecognizer

class FinishOverlay: SKScene {
    
    public var gameOptionsDelegate: GameOptions?
    
    private var restartButton: SKSpriteNode!
    private var menuButton: SKSpriteNode!
    private var fowardButton: SKSpriteNode!
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        self.restartButton = self.childNode(withName: "menuButton") as! SKSpriteNode
        self.restartButton = self.childNode(withName: "restartButton") as! SKSpriteNode
        self.restartButton = self.childNode(withName: "fowardButton") as! SKSpriteNode
        
    }
    
    override func didMove(to view: SKView) {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FinishOverlay.handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        
        let location = gesture.location(in: self.view).fromUiView(height: (self.view?.frame.height)!)
        
        //tap on restardButton
        if self.restartButton.contains(location) {
            gameOptionsDelegate?.restart()
            
        }
        //tap on fowardButton
        else if self.fowardButton.contains(location) {
            //TODO handle fowardbutton
            
        }
        //tap on menuButton
        else if self.menuButton.contains(location) {
            //TODO handle menuButton
            
        }
        
    }
    
}
