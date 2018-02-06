//
//  SubtitleController.swift
//  PepperJourney
//
//  Created by Marcelo Martimiano Junior on 13/12/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import GameplayKit

struct SubtitlePart {
    var subtitle: String
    var duration: TimeInterval!
}

struct Subtitle {
    var name: String
    var duration: TimeInterval!
    var text: [String]
}
class SubtitleController {
    let fadeInDuration: TimeInterval = 0
    let fadeOutDuration: TimeInterval = 0
    var subtitleIsVisible: Bool = false
    private var subtitles = [Subtitle]()
    var overlayDelegate: SubtitleProtocol?
    var subtitleQueue = [SubtitlePart]()
    static var sharedInstance = SubtitleController()
    var lastEndTime: TimeInterval = 0
    
    init() {
        self.subtitles.append(Subtitle(name: "F1_Pepper_1", duration: 2.66, text: ["I have to run!".localized,
                                                                                                       "Otherwise they’ll catch me".localized]))
        
        self.subtitles.append(Subtitle(name: "F1_Pepper_2", duration: 3.51, text: ["If I could I would make a".localized,
                                                                                                       "smashed potato of them".localized]))
        
        self.subtitles.append(Subtitle(name: "F1_Pepper_3", duration: 1.56, text: ["I’ll never let".localized,
                                                                                                       "you catch me!".localized]))
        
        self.subtitles.append(Subtitle(name: "F1_Potato_1", duration: 2.51, text: ["Don’t let her escape!".localized,
                                                                                    "She knows too much".localized]))
        
        self.subtitles.append(Subtitle(name: "F1_Potato_2", duration: 3.17, text: ["Sir, we got her!".localized,
                                                                                    "She'll never pass throw this islands".localized]))
        
        self.subtitles.append(Subtitle(name: "F1_Pepper_4", duration: 2.47, text: ["Hurry, help me jump".localized,
                                                                                    "throw those islands!".localized]))
        
        self.subtitles.append(Subtitle(name: "F1_Pepper_5", duration: 2.81, text: ["I know someone who can".localized,
                                                                                    "helps us, we’re almost there.".localized]))
        
        self.subtitles.append(Subtitle(name:  "Prisoner1Sound", duration: 7.2, text: ["Thank you so much for saving us!".localized,
                                                                                        "Pepper, there are other prisoners in".localized,
                                                                                        "the whole kingdom, please help them!".localized]))
        self.subtitles.append(Subtitle(name: "rumorsAboutBigBox", duration: 3.28, text: ["There are rumors about a".localized,
                                                                                        "big box across the ruge bridge!".localized]))
        
        self.subtitles.append(Subtitle(name: "WarriorAvocado", duration: 5.55, text: ["Thank you little Pepper, you have a big".localized,
                                                                                        "challenge ahead, I wish you good luck!".localized]))
        
        // Level 2
        self.subtitles.append(Subtitle(name: "F2_Pepper_1", duration: 2.09, text: ["Look, a box!"]))
        self.subtitles.append(Subtitle(name: "F2_Pepper_4", duration: 4.66, text: ["O my god! The Potato",
                                                                                   "Empire is worst than I thought"]))
        self.subtitles.append(Subtitle(name: "F2_Pepper_5", duration: 1.94, text: ["Ohhh… There is nothing here!"]))
        self.subtitles.append(Subtitle(name: "F2_Pepper_6", duration: 2.42, text: ["Ohhh… There is nothing here!"]))
        self.subtitles.append(Subtitle(name: "F2_Pepper_7", duration: 2.53, text: ["Ohhh… There is nothing here!"]))
        self.subtitles.append(Subtitle(name: "F2_Pepper_8", duration: 2.09, text: ["Aah I chose the wrong path"]))
        self.subtitles.append(Subtitle(name: "F2_Pepper_9", duration: 2.85, text: ["I chose the wrong path, again"]))
        self.subtitles.append(Subtitle(name: "F2_Pepper_10", duration: 1.22, text: ["I chose the wrong path"]))
        self.subtitles.append(Subtitle(name: "F2_Pepper_11", duration: 2.78, text: ["I chose the wrong path, again"]))
        self.subtitles.append(Subtitle(name: "F2_Pepper_12", duration: 2.56, text: ["Nooo, another dead end"]))
        self.subtitles.append(Subtitle(name: "F2_Pepper_13", duration: 3.24, text: ["Ohh… Nooo, another dead end!?"]))
        self.subtitles.append(Subtitle(name: "F2_Pepper_14", duration: 3.61, text: ["So many ways!",
                                                                                    "which one should I pick?"]))
        self.subtitles.append(Subtitle(name: "F2_Pepper_15", duration: 5.82, text: ["Now I can throw fire",
                                                                                    "Let's fry some potatoes!"]))
        self.subtitles.append(Subtitle(name: "F2_Potato_1", duration: 2.20, text: ["Stop her", "She is realizing  our prisioners"]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupSubtitle(subName: String)
    {
        var subtitleFound: Subtitle?
        for sub in self.subtitles {
            if sub.name == subName {
                subtitleFound = sub
                break
            }
        }
        guard let subtitle = subtitleFound else {
            print("Subtitle with name \(subName)not found ")
            return
        }
        
        for text in subtitle.text {
            // cria uma nova linha de legenda
            // com a duração dependendo da quantidade de linhas necessárias
            // quanto mais linhas menor o tempo que elas ficarão visíveis
            let subDuration = (subtitle.duration / TimeInterval(subtitle.text.count))
            
            let newSubtitle = SubtitlePart(subtitle: text, duration: subDuration)
            // Adiciona a fila de exibição de legendas
            self.subtitleQueue.append(newSubtitle)
        }
    }
    
    // Recebe o tempo do sistema
    func update(systemTime: TimeInterval) {
        // Verifica se já está no tempo de colocar ou retirar alguma legenda
        if  systemTime < self.lastEndTime {
            return
        }
        
        // Verifica se há alguma legenda para ser colocada e se houver verifica se já está no tempo de ser exibida
        if self.subtitleQueue.count > 0 {
            let subStruct = self.subtitleQueue[0]
            
            // obtém o texto da legenda
            let subtitle = subStruct.subtitle
            
            // Calcula o tempo de exibição da próxima legenda
            self.lastEndTime = systemTime + subStruct.duration + self.fadeInDuration + self.fadeOutDuration
            // atualiza a legenda
            self.overlayDelegate?.showSubtitle(text: subtitle, duration: subStruct.duration, fadeInDuration: self.fadeInDuration)
            
            // Remove da fila essa legenda
            self.subtitleQueue.remove(at: 0)
            
            // Atualiza flag
            self.subtitleIsVisible = true
        }
        else if subtitleIsVisible {
            // hide de subtitle
            self.overlayDelegate?.hideSubtitle(fadeOutDuration: self.fadeOutDuration)
            self.subtitleIsVisible = false
        }
    }
    
}
