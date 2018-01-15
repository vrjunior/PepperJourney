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
    private var loadingButton: SKButton!
    private var cancelAdButton: SKButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //setup nodes
        self.restartButton = self.childNode(withName: "buttonsNode/restartButton") as! SKButton
        self.restartButton.delegate = self
        
//        self.menuButton = self.childNode(withName: "menuButton") as! SKButton
//        self.menuButton.delegate = self

        // Video ad buttons
        self.showAdButton = self.childNode(withName: "buttonsNode/ad/showAdButton") as! SKButton
        self.showAdButton.delegate = self
        
        self.cancelAdButton = self.childNode(withName: "buttonsNode/ad/cancelAdButton") as! SKButton
        self.cancelAdButton.delegate = self
        
//        self.loadingButton = self.childNode(withName: "buttonsNode/ad/loading") as! SKButton
        
        self.showAdButtonEnable()
    }
    public func setupAds(enableAds: Bool) {
        self.enableAds = enableAds
        if enableAds {
            self.restartButton.position.x = 160
            self.showAdButtonEnable()
        }
        else {
            self.restartButton.position.x = 0
            self.showAdButton.isHidden = true
            self.cancelAdButton.isHidden = true
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
            self.cancelAdButtonEnable()
            
            gameOptionsDelegate?.loadAd(loadedVideoFeedback: self.adLoaded)
        }
    
        else if target == self.cancelAdButton {
            self.showAdButtonEnable()
            gameOptionsDelegate?.cancelAd()
        }
    }
    func cancelAdButtonEnable() {
        self.showAdButton.isHidden = true
        self.cancelAdButton.isHidden = false
//        self.loadingButton.isHidden = false
//        self.loadingButton.run(SKAction.repeatForever(SKAction.rotate(byAngle: -360, duration: 2)))
    }
    
    func showAdButtonEnable() {
        // Change button
        self.showAdButton.isHidden = false
        self.cancelAdButton.isHidden = true
//        self.loadingButton.isHidden = true
    }
    
    func adLoaded() {
        self.showAdButtonEnable()
    }
    
    func buttonPressed(target: SKButton) {
        
        target.colorBlendFactor = target.defaultColorBlendFactor
    }
}
