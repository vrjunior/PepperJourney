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

class SoundController
{
    var areSoundEffectsMute: Bool
    var isBackgroundMusicMute: Bool
    var defaultSoudEffectVolume: Float = 1
    
    static let sharedInstance = SoundController()
    
    private var sounds: [String: SCNAudioSource] = [:]
    
    private init() {
        self.areSoundEffectsMute = false
        self.isBackgroundMusicMute = false
    }
    
    func updateSoundStatus()
    {
        // pega do sistema
        // verifica botoes internos
    }
    
    func loadSound (fileName: String, soundName: String, volume: Float) {
        // Avoid that add two audios with the same soundName
        
        guard self.sounds[soundName] == nil else
        {
            print("This sound Name yet exists")
            return
        }
        guard let audioSource = SCNAudioSource(fileNamed: fileName) else {
            fatalError("Error in find the sound \(fileName)")
        }
        
        // Volume default de reprodução
        audioSource.volume = volume
        
        // Varia com a posição
        audioSource.isPositional = true
        
        // Não vai precisar pq vai fazer pro-load na memória
        audioSource.shouldStream = false
        
        // Carrega o audio na memoria
        audioSource.load()
        
        // Adiciona o audioSource ao dicionário
        self.sounds[soundName] = audioSource
    }
    
    func loadSound(fileName: String, soundName: String) {
        self.loadSound(fileName: fileName, soundName: soundName, volume: self.defaultSoudEffectVolume)
    }
    
    
    
    func removeAudioSource(soundName: String)
    {
        self.sounds.removeValue(forKey: soundName)
    }
    private func playGenericSound(soundName: String, loops: Bool, node: SCNNode)
    {
        guard let sound = self.sounds[soundName] else
        {
            fatalError("Error at get the audio source \(soundName)")
            
        }
//        print("tocou: \(soundName)")
        sound.loops = loops
        node.runAction(SCNAction.playAudio(sound, waitForCompletion: false))
    }
    
    private func playGenericSound(soundName: String, loops: Bool, node: SCNNode, block: @escaping () -> ())
    {
        guard let sound = self.sounds[soundName] else
        {
            fatalError("Error at get the audio source \(soundName)")
            
        }
//        print("tocou: \(soundName)")
        sound.loops = loops
        
        let actionSequence = SCNAction.sequence([SCNAction.playAudio(sound, waitForCompletion: true),
//                                                 SCNAction.wait(duration: 2.0),
                                                 SCNAction.run({ (node) in
                                                    block()
                                                    
                                                 })])
        
        node.runAction(actionSequence)
    }
    
    func playSoundEffect(soundName: String, loops: Bool, node: SCNNode)
    {
        if !areSoundEffectsMute
        {
            playGenericSound(soundName: soundName, loops: loops, node: node)
        }
    }
    
    func playSoundEffect(soundName: String, loops: Bool, node: SCNNode, block: @escaping () -> ())
    {
        if !areSoundEffectsMute
        {
            playGenericSound(soundName: soundName, loops: loops, node: node, block: block)
        }
    }
    
    func playbackgroundMusic(soundName: String, loops: Bool, node: SCNNode)
    {
        if !isBackgroundMusicMute
        {
            self.playGenericSound(soundName: soundName, loops: loops, node: node)
        }
    }
    
    func stopSoundsFromNode(node: SCNNode)
    {
        node.removeAllAudioPlayers()
    }
    
    func removeSoundFromMemory(soundName: String)
    {
        self.sounds.removeValue(forKey: soundName)
    }
    
    //===================================================================================
    //    func muteSound() {
    //        var player: AVAudioNode
    //
    //        player = AVAudioPlayerNode()
    //        self.audioPlayer = SCNAudioPlayer(source: audioSource)
    //        self.audioPlayer.audioNode!.engine?.attach(player)
    //        self.audioPlayer.audioNode!.engine?.mainMixerNode.outputVolume = 0
    //    }
    //
    //    func unmuteSound()
    //    {
    //        self.audioSource.volume = self.volume
    //    }
    //
    //
    //    func stopSound()
    //    {
    //        self.node.removeAudioPlayer(self.audioPlayer)
    //    }
    
}

