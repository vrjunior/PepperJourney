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
    func showAd(blockToRunAfter: @escaping (Bool) -> Void, loadedVideoFeedback:  @escaping () -> Void)
    func cancelAd()
}

struct VideoSender {
    var blockAfterVideo: () -> Void
    var cutScenePath: String
    var cutSceneSubtitlePath: String
}

struct Comic {
    var name: String
    var previousComic: String?
    var nextComic: String?
    var runComic: (() -> Void)
}

class GameViewController: UIViewController {
    
    public var fase: Int = 1
    private var rewardAd: RewardAdvertisement!
    private var comics: [Comic]!
    public private(set) var currentComic: Comic!
    
    var gameView: SCNView {
        return view as! SCNView
    }
    func setupComics() {
        let level1     = Comic(name: "level1", previousComic: nil, nextComic: "cutscene1", runComic: self.level1)
        
        let cutscene1 = Comic(name: "cutscene1", previousComic: "level1", nextComic: "cutscene2", runComic: self.cutscene1)
        
        let cutscene2 = Comic(name: "cutscene2", previousComic: "cutscene1", nextComic: "level2", runComic: self.cutscene2)
        
        let level2     = Comic(name: "level2", previousComic: "cutscene2", nextComic: "cutscene3", runComic: self.level2)
        
        let cutscene3 = Comic(name: "cutscene3", previousComic: "level2", nextComic: nil, runComic: self.cutscene3)
        
        self.comics = [level1, cutscene1, cutscene2, level2, cutscene3]
        
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
    func setComic(named: String) {
        for comic in self.comics {
            if comic.name == named {
                self.currentComic = comic
                self.currentComic.runComic()
                return
            }
        }
    }
    
    func runNextComic() {
        self.setComic(named: currentComic.name)
    }
    func level1() {
        
    }
    func level2() {
        
    }
    func cutscene1() {
        
    }
    func cutscene2() {
        
    }
    func cutscene3() {
        
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

    func changeLevel(controller: GameController) {
        // roda cutscene
        gameController = controller
    }
}

extension GameViewController: AdvertisingDelegate {
    func cancelAd() {
        self.rewardAd.isWaiting = false
    }
    
    func showAd(blockToRunAfter: @escaping (Bool) -> Void, loadedVideoFeedback:  @escaping () -> Void) {
        self.rewardAd.showAdWhenReady(blockToRunAfter: blockToRunAfter, loadedVideoFeedback: loadedVideoFeedback)
    }
}

extension GameViewController: CutSceneDelegate {
    
    func playCutScene(videoSender: VideoSender) {
        self.performSegue(withIdentifier: "playVideo", sender: videoSender)
    }
}