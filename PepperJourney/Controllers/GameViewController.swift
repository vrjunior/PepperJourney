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

protocol GameViewControllerDelagate: NSObjectProtocol {
    func runNextComic()
    func setComic(named: String)
    func setMenu()
    func resetGame()
    
    // Ads
    func showAd(blockToRunAfter: @escaping (Bool) -> Void, loadedVideoFeedback:  @escaping () -> Void)
    func cancelAd()
    
    // video player
    func playCutScene(videoSender: VideoSender)
}

class GameViewController: UIViewController {
    
    private var rewardAd: RewardAdvertisement!
    private var comics: [Comic]!
    public private(set) var currentComic: Comic!
    
    var gameView: SCNView {
        return view as! SCNView
    }
    var gameController: GameController?
    var menu: MenuController?
    
    
    func setupComics() {
        let level1     = Comic(name: "level1", previousComic: nil, nextComic: "cutscene1", runComic: self.level1)
        
        let cutscene1 = Comic(name: "cutscene1", previousComic: "level1", nextComic: "cutscene2", runComic: self.cutscene1)
        
        let cutscene2 = Comic(name: "cutscene2", previousComic: "cutscene1", nextComic: "level2", runComic: self.cutscene2)
        
        let level2     = Comic(name: "level2", previousComic: "cutscene2", nextComic: "cutscene3", runComic: self.level2)
        
        let cutscene3 = Comic(name: "cutscene3", previousComic: "level2", nextComic: nil, runComic: self.cutscene3)
        
        self.comics = [level1, cutscene1, cutscene2, level2, cutscene3]
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupComics()
        
        self.setComic(named: "level1")
        
        // Ads objects
        self.rewardAd = RewardAdvertisement(gameViewController: self)
        
        // Configure the view
        gameView.backgroundColor = UIColor.black
        
        if UserDefaults.standard.integer(forKey: "comicReleased") == 0 {
            UserDefaults.standard.set(1, forKey: "comicReleased")
        }
        
    }
    func setComic(named: String) {
        for comic in self.comics {
            if comic.name == named {
                self.currentComic = comic
                self.currentComic.runComic()
                self.menu = nil
                return
            }
        }
    }
    
    func runNextComic() {
        self.setComic(named: currentComic.name)
    }
    func level1() {
        self.gameController = Fase1GameController(scnView: self.gameView, gameControllerDelegate: self)
        
    }
    func level2() {
        self.gameController = Fase2GameController(scnView: self.gameView, gameControllerDelegate: self)
        // Video delegates
        
        
    }
    
    func cutscene1() {
        
        let videoSender = VideoSender(blockAfterVideo: self.setMenu, cutScenePath: "cutscene1.mp4", cutSceneSubtitlePath: "cutscene1.srt".localized)
        
        self.playCutScene(videoSender: videoSender)
        
    }
    func cutscene2() {
        self.setMenu()
        let videoSender = VideoSender(blockAfterVideo: self.setMenu, cutScenePath: "cutscene2.mp4", cutSceneSubtitlePath: "cutscene2.srt".localized)
        
        self.playCutScene(videoSender: videoSender)
    }
    func cutscene3() {
        self.setMenu()
        let videoSender = VideoSender(blockAfterVideo: self.setMenu, cutScenePath: "cutscene3.mp4", cutSceneSubtitlePath: "cutscene3.srt".localized)
        
        self.playCutScene(videoSender: videoSender)
    }
    func setMenu() {
        self.menu = MenuController(scnView: self.gameView, gameControllerDelegate: self)
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

extension GameViewController: GameViewControllerDelagate {
    func resetGame() {
         UserDefaults.standard.set(1, forKey: "comicReleased")
    }
    
    
    func cancelAd() {
        self.rewardAd.isWaiting = false
    }
    
    func showAd(blockToRunAfter: @escaping (Bool) -> Void, loadedVideoFeedback:  @escaping () -> Void) {
        self.rewardAd.showAdWhenReady(blockToRunAfter: blockToRunAfter, loadedVideoFeedback: loadedVideoFeedback)
    }
    
    
    func playCutScene(videoSender: VideoSender) {
        self.performSegue(withIdentifier: "playVideo", sender: videoSender)
    }
}
