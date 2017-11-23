//
//  simpleSoundComponent.swift
//  SpicyHero
//
//  Created by Marcelo Martimiano Junior on 22/11/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import GameplayKit
import AVFoundation

class SoundComponent: GKComponent
{
    var volume: Float = 0
    var node: SCNNode!
    var audioPlayer: SCNAudioPlayer!
    var audioSource: SCNAudioSource!
    
    init(fileName: String, node: SCNNode, volume: Float) {
        super.init()
        
        self.node = node
        self.volume = volume
        
        guard let audioSource = SCNAudioSource(fileNamed: fileName) else {
            fatalError("Error in find the sound \(fileName)")
        }
        self.audioSource = audioSource
        self.audioSource.volume = volume
        self.audioSource.load()
        
        self.audioPlayer = SCNAudioPlayer(source: audioSource)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func muteComponent() {
        var player: AVAudioNode
        
        player = AVAudioPlayerNode()
        
        self.audioPlayer.audioNode!.engine?.attach(player)
        self.audioPlayer.audioNode!.engine?.mainMixerNode.outputVolume = 0
    }
    
    func unmuteComponent()
    {
        self.audioSource.volume = self.volume
    }
    
    func playSound(loops: Bool)
    {
        self.audioSource.loops = loops
        self.node.runAction(SCNAction.playAudio(self.audioSource, waitForCompletion: false))
    }
    
    func stopSound()
    {
        self.node.removeAudioPlayer(self.audioPlayer)
    }
    
}
