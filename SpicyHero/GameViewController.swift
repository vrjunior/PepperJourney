//
//  GameViewController.swift
//  SpicyHero
//
//  Created by Valmir Junior on 03/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupScenes()
    }

    func setupScenes() {
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/level1.scn")!
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        if let overlay = SKScene(fileNamed: "art.scnassets/levels/overlay.sks") {
            // Set the scale mode to scale to fit the window
            overlay.scaleMode = .aspectFill
            
            //overlay.isUserInteractionEnabled = false
            
            scnView.overlaySKScene = overlay
        }
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = false
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
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
