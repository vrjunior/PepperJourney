//
//  GameViewController.swift
//  SpicyHero
//
//  Created by Valmi//.././r Junior on 03/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import SpriteKit
import GoogleMobileAds


protocol CutSceneDelegate : NSObjectProtocol {
    func playCutScene(videoSender: VideoSender)
}

protocol AdvertisingDelegate: NSObjectProtocol {
    func showAd()
}

struct VideoSender {
    var blockAfterVideo: () -> Void
    var cutScenePath: String
    var cutSceneSubtitlePath: String
}

class GameViewController: UIViewController {
    
    public var fase: Int = 1
    private var rewardAd: RewardAdvertisement!
    
    var gameView: SCNView {
        return view as! SCNView
    }
    
    var gameController: GameController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.fase == 1
        {
           gameController = Fase1GameController(scnView: gameView)
        }
        else if self.fase == 2
        {
            gameController = Fase2GameController(scnView: gameView)
        }
        
        // Video delegates
        gameController?.cutSceneDelegate = self
        gameController?.adVideoDelegate = self
        
        // Ads objects
        self.rewardAd = RewardAdvertisement(gameViewController: self)
        
        // Configure the view
        gameView.backgroundColor = UIColor.black
        
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "playVideo" {
            guard let videoSender = sender as? VideoSender else {
                print("Error getting videoSender")
                return
            }
            
            let videoStoryboard = segue.destination as! VideoViewController
            videoStoryboard.cutScenePath = videoSender.cutScenePath
            videoStoryboard.cutSceneSubtitlePath = videoSender.cutSceneSubtitlePath
            videoStoryboard.blockAfterVideo = videoSender.blockAfterVideo
        }
    }

}

extension GameViewController: AdvertisingDelegate {
    func showAd() {
        //self.rewardAd.showAdWhenReady()
    }
}

extension GameViewController: CutSceneDelegate {
    
    func playCutScene(videoSender: VideoSender) {
        self.performSegue(withIdentifier: "playVideo", sender: videoSender)
    }
}
