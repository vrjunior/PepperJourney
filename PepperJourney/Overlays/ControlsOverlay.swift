//
//  Overlay.swift
//  SpicyHero
//
//  Created by Valmir Junior on 06/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

protocol SubtitleProtocol {
    func showSubtitle(text: String, duration: TimeInterval, fadeInDuration: TimeInterval)
    func hideSubtitle(fadeOutDuration: TimeInterval)
}
protocol UpdateIndicators {
    func updateLifeIndicator(percentage: Float)
    func updateAttackIndicator(percentage: Float)
    func resetLifeIndicator()
}

class ControlsOverlay: SKScene {

    public var controlsDelegate: Controls? {
        didSet {
            self.padOverlay.delegate = controlsDelegate
            self.cameraControl.delegate = controlsDelegate
            self.attackButton.delegate = controlsDelegate
            self.jumpButton.delegate = controlsDelegate
        }
    }

    public var gameOptionsDelegate: GameOptions?
    public var isLifeIndicatorHidden = false {
        didSet {
            self.lifeIndicator.isHidden = self.isLifeIndicatorHidden
        }
    }
    public var isAttackHidden = false {
        didSet {
            self.attackButton.isHidden = self.isAttackHidden
            self.attackIndicator.isHidden = self.isAttackHidden
            
        }
    }
    private var damageIndicator: SKSpriteNode!
    private var subtitleLabel: SKLabelNode!
    private var jumpButton: JumpButton!
    private var attackButton: AttackButton!
    private var padOverlay: PadOverlay!
    private var pauseButton: SKButton!
    private var cameraControl: CameraControl!
    
    public var missionCounterLabel: SKLabelNode!

    private var lifeIndicatorFullWidth: CGFloat!
    private var lifeIndicator: SKSpriteNode!

    private var attackIndicatorFullWidth: CGFloat!
    private var attackIndicator: SKSpriteNode!
    public var tutorialEnded = false

    public func setupAttackButton(hiden: Bool) {
        
        self.attackButton.isHidden = hiden
    }
    
    public var isPausedControl:Bool = false {
        didSet {
            self.padOverlay.isPausedControl = self.isPausedControl
            self.jumpButton.isPausedControls = self.isPausedControl
            self.attackButton.isPausedControls = self.isPausedControl
            self.cameraControl.isPausedControl = self.isPausedControl
			self.pauseButton.isPausedControls = self.isPausedControl
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.scaleMode = .aspectFill
    
        self.subtitleLabel = self.childNode(withName: "subtitleLabel") as! SKLabelNode
        self.subtitleLabel.colorBlendFactor = 1
        
        self.missionCounterLabel = self.childNode(withName: "missionCounterLabel") as! SKLabelNode
        self.missionCounterLabel.isHidden = true

        self.padOverlay = self.childNode(withName: "padOverlay") as! PadOverlay
        self.jumpButton = self.childNode(withName: "jumpButton") as! JumpButton
        self.attackButton = self.childNode(withName: "attackButton") as! AttackButton
        self.cameraControl = self.childNode(withName: "cameraControl") as! CameraControl
        self.damageIndicator = self.childNode(withName: "damageIndicator") as! SKSpriteNode
        self.damageIndicator.alpha = 0

        self.pauseButton = self.childNode(withName: "pauseButton") as! SKButton
        self.pauseButton.delegate = self

        self.lifeIndicator = self.childNode(withName: "lifeIndicator") as! SKSpriteNode
        self.lifeIndicatorFullWidth = lifeIndicator.size.width

        self.attackIndicator = self.childNode(withName: "attackIndicator") as! SKSpriteNode
        self.attackIndicatorFullWidth = attackIndicator.size.width

        // disable interation in scenekit
        self.isUserInteractionEnabled = false
        
    }
    
    public func setDamageIndicator(alpha: CGFloat) {
    
        self.damageIndicator.alpha = alpha
    }
    
    func updateMissionCounter(label: String) {
        self.missionCounterLabel.text = label
    }
    
    func setMissionCouterVisibility(isHidden: Bool) {
        self.missionCounterLabel.isHidden = isHidden
    }
}

extension ControlsOverlay: UpdateIndicators {
    func updateLifeIndicator(percentage: Float) {
        self.lifeIndicator.size.width = CGFloat(percentage) * self.lifeIndicatorFullWidth
    }
    func updateAttackIndicator(percentage: Float) {
        self.attackIndicator.size.width = CGFloat(percentage) * self.attackIndicatorFullWidth
    }
    func resetLifeIndicator() {
        self.lifeIndicator.size.width = self.lifeIndicatorFullWidth
    }
}

extension ControlsOverlay: SubtitleProtocol {
    func showSubtitle(text: String, duration: TimeInterval, fadeInDuration: TimeInterval) {

        self.subtitleLabel.text = text
        self.subtitleLabel.isHidden = false
//        self.subtitleLabel.run(SKAction.fadeIn(withDuration: fadeInDuration))

    }



    func hideSubtitle(fadeOutDuration: TimeInterval) {

//        self.subtitleLabel.run(SKAction.fadeOut(withDuration: fadeOutDuration))
        self.subtitleLabel.isHidden = true
    }

}



extension ControlsOverlay : SKButtonDelegate {
    func buttonReleased(target: SKButton) {
        if target == pauseButton {
            self.gameOptionsDelegate?.pause()

        }
        
    }
    

    func buttonPressed(target: SKButton) {
    }

}
