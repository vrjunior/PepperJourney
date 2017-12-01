//
//  VideoViewController.swift
//  PepperJourney
//
//  Created by Valmir Junior on 30/11/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class VideoViewController: UIViewController {
    
    @IBOutlet weak var skView: SKView!
    public var cutScenePath: String = ""
    private var video: SKVideoNode!
    private var scene: SKScene!

    override func viewDidLoad() {
        super.viewDidLoad()

        scene = SKScene(size: CGSize(width: 1134, height: 750))
        scene.scaleMode = .aspectFill
        self.skView.presentScene(scene)
        self.playCutScene()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func playCutScene() {
        if let url = Bundle.main.url(forResource: self.cutScenePath, withExtension: nil) {
            
            let avPlayer = AVPlayer(url: url)
            avPlayer.actionAtItemEnd = .none
            
            video = SKVideoNode(avPlayer: avPlayer)
            
            video.anchorPoint = CGPoint(x: 0, y: 0)
            video.position = CGPoint(x: 0, y: 0)
            video.zPosition = 1
            video.size = self.scene.frame.size
            video.name = "video"
            
            self.skView.scene?.addChild(video)
            video.play()
            
            NotificationCenter.default.addObserver(self, selector: #selector(VideoViewController.videoDidEnd(notification:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem)
        }
    }
    
    @objc func videoDidEnd(notification: Notification) {
        self.goBackToGame()
    }
    
    func goBackToGame() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func skipVideo(_ sender: UIButton) {
        self.goBackToGame()
    }
    
}
