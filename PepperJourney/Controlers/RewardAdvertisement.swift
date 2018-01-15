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
    private var blockToRunAfter: ((Bool) -> Void)!
    private var loadedVideoFeedback: (() -> Void)!
    public  var isWaiting: Bool = false
    private var wonReward = false
    
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
    
    func showAdWhenReady(blockToRunAfter: @escaping (Bool) -> Void, loadedVideoFeedback:  @escaping () -> Void) {

        if self.isWaiting {
            return
        }
        self.isWaiting = true
        
        self.wonReward = false
        
        // save the function that will be called
        self.blockToRunAfter = blockToRunAfter
        self.loadedVideoFeedback = loadedVideoFeedback
        
        // load the ad video
        self.rewardAd.load(request, withAdUnitID: "ca-app-pub-5001378685265172/5465280027")
    }
    
    // Ganhou recompensa
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didRewardUserWith reward: GADAdReward) {
        self.wonReward = true
    }
    
    // deu erro
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didFailToLoadWithError error: Error) {
        self.loadedVideoFeedback()
        print("Error loading video ad!")
        print(error.localizedDescription)
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        // Restaura os indicadores de que o vídeo está carregando
        self.loadedVideoFeedback()
        
        if self.wonReward {
             self.blockToRunAfter(true)
        }
    }
    
    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        guard self.rewardAd.isReady else {
            print("Error! Video isn't ready")
            return
        }
        guard self.isWaiting else {
            print("Video load was cancel")
            return
        }
        
        self.isWaiting = false
        // Play the video
        self.rewardAd.present(fromRootViewController: self.gameViewController)
        
    }
}

