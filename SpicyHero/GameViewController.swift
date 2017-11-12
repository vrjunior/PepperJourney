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

class GameViewController: UIViewController {
	
    var gameView: SCNView {
        return view as! SCNView
    }
    
    var gameController: GameController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1.3x on iPads
       /* if UIDevice.current.userInterfaceIdiom == .pad {
            self.gameView.contentScaleFactor = min(1.3, self.gameView.contentScaleFactor)
            self.gameView.preferredFramesPerSecond = 60
        } */
        gameView.showsStatistics = true
        gameController = GameController(scnView: gameView)
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

}
