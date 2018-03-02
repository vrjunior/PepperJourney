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
    let comicsOrder  = ["level1", "cutscene1", "cutscene2", "level2", "cutscene3"]
    private var comics = [SKButton]()
    private var settingsButton: SKButton!
    private var resetGameButton: SKButton!
    private var settings: SKNode!
    private var mask: SKButton!
    private let comicsNumber = 5
    
    override func sceneDidLoad() {
        self.resetGameButton = self.childNode(withName: "settings/resetGameButton") as! SKButton
        self.resetGameButton.delegate = self
        
        self.settingsButton = self.childNode(withName: "settingsButton") as! SKButton
        self.settingsButton.delegate = self
        
        self.settings = self.childNode(withName: "settings")
        self.settings.isHidden = true
        
        self.mask = self.childNode(withName: "settings/mask") as! SKButton
        self.mask.delegate = self
        
        let buttons = self.childNode(withName: "comicsNode")
        guard let comics = buttons?.children as? [SKButton] else {
            print("Error gettng level buttons")
            return
        }
        self.comics = comics
        self.updateComics()
    
    }
    func updateComics() {
        // PAY ATTENTION: The order of comics in sprite kit scene matter
        let comicReleased = UserDefaults.standard.integer(forKey: "comicReleased")
        
        
        for index in 0 ..< self.comics.count {
            self.comics[index].delegate = self
            if index < comicReleased {
                self.comics[index].alpha = 0.0001
            }
            else {
                self.comics[index].alpha = 1
            }
        }
    }
}

extension MenuOverlay : SKButtonDelegate {
    func buttonReleased(target: SKButton) {
        target.colorBlendFactor = 0
        if target == self.settingsButton {
            self.settings.isHidden = false
        }
        else if target == self.resetGameButton {
            self.gameOptionsDelegate?.resetGame()
            self.updateComics()
        }
        else if target == self.mask {
            self.settings.isHidden = true
        }
    }
    
    func buttonPressed(target: SKButton) {
        
        target.colorBlendFactor = target.defaultColorBlendFactor
        
        if target == self.settingsButton {
            return
        }
        guard let comicName = target.name else {
            return
        }
       
        let comicReleased = UserDefaults.standard.integer(forKey: "comicReleased")
        
        if let comicSelected = self.comics.index(of: target),
        comicSelected < comicReleased {
            self.gameOptionsDelegate?.goToComic(comic: comicName)
        }
    }
    
}

