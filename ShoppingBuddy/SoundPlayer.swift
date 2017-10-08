//
//  SounPlayer.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 02.10.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import Foundation
import AVFoundation

class SoundPlayer {
    static var audioPlayer:AVAudioPlayer!
    
    static func PlaySound(filename:String, filetype:String) -> Void {
        if let path = Bundle.main.path(forResource: filename, ofType: filetype){
            let url = URL(fileURLWithPath: path)
            audioPlayer = try? AVAudioPlayer(contentsOf: url, fileTypeHint: nil)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        }
    }
    
}
