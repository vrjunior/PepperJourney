//
//  MenuViewController.swift
//  PepperJourney
//
//  Created by Marcelo Martimiano Junior on 04/12/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import UIKit

class MenuViewController: UIViewController {
    
    @IBAction func fase1(_ sender: Any) {
        performSegue(withIdentifier: "menuSegue", sender: 1)
    }
    @IBAction func fase2(_ sender: Any) {
        performSegue(withIdentifier: "menuSegue", sender: 2)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let fase = sender as! Int
        let gameViewController = segue.destination as! GameViewController
    }
}
