//
//  FinishOverlay.swift
//  PepperJourney
//
//  Created by Valmir Junior on 28/11/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import SpriteKit
import UIKit.UIGestureRecognizer
import AVFoundation
import UIKit

class FinishOverlay: SKScene {
    
    public var gameOptionsDelegate: GameOptions?
    public var finalCutSceneVideo: String = "" {
        didSet {
            let videoView = VideoViewController()
            videoView.cutScenePath = finalCutSceneVideo
            
           // videoView.present(videoView, animated: true, completion: nil)
        }
    }
    
    private var restartButton: SKSpriteNode!
    private var menuButton: SKSpriteNode!
    private var fowardButton: SKSpriteNode!
    
    private var video: SKVideoNode!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setupNodes()
    }
    
    func setupNodes() {
        self.menuButton = self.childNode(withName: "menuButton") as! SKSpriteNode
        self.restartButton = self.childNode(withName: "restartButton") as! SKSpriteNode
        self.fowardButton = self.childNode(withName: "fowardButton") as! SKSpriteNode
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
