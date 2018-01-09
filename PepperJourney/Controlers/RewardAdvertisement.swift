//
//  AdViewController.swift
//  PepperJourney
//
//  Created by Marcelo Martimiano Junior on 05/01/18.
//  Copyright © 2018 Valmir Junior. All rights reserved.
//

import Foundation
import GoogleMobileAds

class RewardAdvertisement: NSObject, GADRewardBasedVideoAdDelegate {
    
    private var rewardAd: GADRewardBasedVideoAd!
    private var request = GADRequest()
    private var gameViewController: GameViewController!
    
    init(gameViewController: GameViewController) {
        super.init()
        
        self.gameViewController = gameViewController
        
        self.rewardAd = GADRewardBasedVideoAd.sharedInstance()
        self.rewardAd.delegate = self
        
        // Devices used for tests
        request.testDevices?.append("43694a890a76ccca2e40cfb2a0e393cf") // Marcelo
        request.testDevices?.append("b732b9940c5953aba4f5101a14424443") // Ju
        request.testDevices?.append("4d173bbf6661dc905c024b9d7b0b6af3") // DC
    }
    
    func showAdWhenReady() {

        // load the ad video
        self.rewardAd.load(request, withAdUnitID: "ca-app-pub-5001378685265172/5465280027")
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didRewardUserWith reward: GADAdReward) {
        print("vai fechar")
        
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didFailToLoadWithError error: Error) {
        print("Error loading video ad")
        print(error.localizedDescription)
    }
    
    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        
        if self.rewardAd.isReady {
            
            self.rewardAd.present(fromRootViewController: self.gameViewController)
            
        }
        else {
            print("Error! Video isn't ready")
        }
    }
}

