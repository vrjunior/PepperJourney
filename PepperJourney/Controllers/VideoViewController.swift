//
//  VideoViewController.swift
//  PepperJourney
//
//  Created by Valmir Junior on 30/11/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import UIKit
import AVKit
import AVPlayerViewControllerSubtitles

class VideoViewController: AVPlayerViewController {
    
    public var cutScenePath: String = ""
    public var cutSceneSubtitlePath: String  = ""
    public var blockAfterVideo: (() -> Void)?


    override func viewDidLoad() {
        super.viewDidLoad()

        self.playCutScene()
        
    }
    override func viewDidDisappear(_ animated: Bool) {
         self.goBackToGame()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func playCutScene() {
        if let url = Bundle.main.url(forResource: self.cutScenePath, withExtension: nil) {
            
            self.player = AVPlayer(url: url)
            self.player?.actionAtItemEnd = .none

        
            if let subtitleUrl = Bundle.main.url(forResource: self.cutSceneSubtitlePath, withExtension: nil) {
                
                self.addSubtitles().open(file: subtitleUrl)
                
            }
            
            NotificationCenter.default.addObserver(self, selector: #selector(VideoViewController.videoDidEnd(notification:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
            
            self.player?.play()
        }
    }
   
    @objc func videoDidEnd(notification: Notification) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func goBackToGame() {
        self.blockAfterVideo!()
    }
    
    @IBAction func skipVideo(_ sender: UIButton) {
        self.goBackToGame()
    }
    
}
