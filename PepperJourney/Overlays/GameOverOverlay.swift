//
//  GameOverOverlay.swift
//  SpicyHero
//
//  Created by Marcelo Martimiano Junior on 28/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.

import Foundation
import SpriteKit


class GameOverOverlay: SKScene {
    public var gameOptionsDelegate: GameOptions?
    
    private var restartButton: SKButton!
    private var menuButton: SKButton!
    private var settingsButton: SKButton!
    
    public var enableAds: Bool = true
    private var showAdButton: SKButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //setup nodes
        self.restartButton = self.childNode(withName: "buttonsNode/restartButton") as! SKButton
        self.restartButton.delegate = self
        
//        self.menuButton = self.childNode(withName: "menuButton") as! SKButton
//        self.menuButton.delegate = self

        // Video ad buttons
        self.showAdButton = self.childNode(withName: "buttonsNode/showAdButton") as! SKButton
        self.showAdButton.delegate = self
        
        self.showAdButton.isHidden = true
    }
    public func setupAds(enableAds: Bool) {
        self.enableAds = enableAds
        if enableAds {
            self.restartButton.position.x = 160
            self.showAdButton.isHidden = false
        }
        else {
            self.restartButton.position.x = 0
            self.showAdButton.isHidden = true
        }
    }
}

extension GameOverOverlay : SKButtonDelegate {
    func buttonReleased(target: SKButton) {
        target.colorBlendFactor = 0
        
        if target == self.restartButton {
            
            // cancel the video load
            if self.showAdButton.isHidden {
                
                gameOptionsDelegate?.cancelAd()
            }
            gameOptionsDelegate?.restart()
        }
        else if target == self.menuButton {
            //TODO handle menuButton
        }
        else if target ==  self.settingsButton {
            //TODO handle settingsButtons
        }
        
        else if target == self.showAdButton {

            // Change button
            self.showAdButton.colorBlendFactor = target.defaultColorBlendFactor
            
            gameOptionsDelegate?.loadAd(loadedVideoFeedback: self.adLoaded)
        }
    }
   
    
    // Go to the initial state
    func adLoaded() {
        self.showAdButton.colorBlendFactor = 0
    }
    
    func buttonPressed(target: SKButton) {
        
        target.colorBlendFactor = target.defaultColorBlendFactor
    }
}
