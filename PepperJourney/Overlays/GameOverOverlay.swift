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
    private var adMessageLabel: SKLabelNode!
    private var loadingAdLabel: SKLabelNode!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //setup nodes
        self.restartButton = self.childNode(withName: "buttonsNode/restartButton") as! SKButton
        self.restartButton.delegate = self
        
        self.menuButton = self.childNode(withName: "buttonsNode/menuButton") as! SKButton
        self.menuButton.delegate = self

        // Video ad buttons
        self.showAdButton = self.childNode(withName: "buttonsNode/showAdButton") as! SKButton
        self.showAdButton.delegate = self
        
        self.showAdButton.isHidden = true
        
        self.adMessageLabel = self.childNode(withName: "adMessage") as! SKLabelNode
        self.loadingAdLabel = self.childNode(withName: "loadingAd") as! SKLabelNode
        
        self.setupAds(enableAds: false)
    }
    public func setupAds(enableAds: Bool) {
        
        self.loadingAdLabel.isHidden = true
        
        self.enableAds = enableAds
        if enableAds {
            self.adMessageLabel.isHidden = false
            
            self.restartButton.position.x = 270
            self.showAdButton.isHidden = false
            self.menuButton.position.x = -270
        }
        else {
            self.adMessageLabel.isHidden = true
            
            self.restartButton.position.x = 160
            self.showAdButton.isHidden = true
            self.menuButton.position.x = -160
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
            self.gameOptionsDelegate?.goToMenu()
        }
        else if target ==  self.settingsButton {
            //TODO handle settingsButtons
        }
        
        else if target == self.showAdButton {

            // Change button
            self.showAdButton.colorBlendFactor = target.defaultColorBlendFactor
            
           
        }
    }
   
    
    // Go to the initial state
    func adLoaded() {
        self.showAdButton.colorBlendFactor = 0
        
        self.adMessageLabel.isHidden = false
        self.loadingAdLabel.isHidden = true
        
    }
    
    func buttonPressed(target: SKButton) {
        
        target.colorBlendFactor = target.defaultColorBlendFactor
        
        if target == self.showAdButton {
             gameOptionsDelegate?.loadAd(loadedVideoFeedback: self.adLoaded)
            
            self.adMessageLabel.isHidden = true
            self.loadingAdLabel.isHidden = false
        }
    }
}
