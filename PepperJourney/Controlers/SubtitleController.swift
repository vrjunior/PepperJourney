//
//  SubtitleController.swift
//  PepperJourney
//
//  Created by Marcelo Martimiano Junior on 13/12/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import GameplayKit

struct SubtitleStruct {
    var subtitle: String
    var duration: TimeInterval!
}
class SubtitleController {
    let fadeInDuration: TimeInterval = 0
    let fadeOutDuration: TimeInterval = 0
    var subtitleIsVisible: Bool = false
    private var subtitles: [String: [String]]!
    var overlayDelegate: SubtitleProtocol?
    var subtitleQueue = [SubtitleStruct]()
    static var sharedInstance = SubtitleController()
    var lastEndTime: TimeInterval = 0
    
    init() {
        self.subtitles = [
            "F1_Pepper_1": ["I have to run!".localized,
                            "Otherwise they’ll catch me".localized],
            
            "F1_Pepper_2": ["If I could I would make a".localized,
                            "smashed potato of them".localized],
            
            "F1_Pepper_3": ["I’ll never let".localized,
                            "you catch me!".localized],
            
            "F1_Potato_1": ["Don’t let her escape!".localized,
                            "She knows too much".localized],
            
            "F1_Potato_2": ["Sir, we got her!".localized,
                            "She'll never pass throw this islands".localized],
            
            "F1_Pepper_4": ["Hurry, help me jump".localized,
                            "throw those islands!".localized],
            
            "F1_Pepper_5": ["I know someone who can".localized,
                            "helps us, we’re almost there.".localized]
        ]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupSubtitle(subName: String, audioDuration: TimeInterval)
    {
        guard let subtitle = self.subtitles[subName] else {
            print("Subtitle with name \(subName)not found ")
            return
        }
        for text in subtitle {
            // cria uma nova linha de legenda
            // com a duração dependendo da quantidade de linhas necessárias
            // quanto mais linhas menor o tempo que elas ficarão visíveis
            let subDuration = (audioDuration / TimeInterval(subtitle.count))
            
            let newSubtitle = SubtitleStruct(subtitle: text, duration: subDuration)
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
