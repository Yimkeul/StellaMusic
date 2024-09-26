//
//  PlayMode+Extension.swift
//  StelliveMusic
//
//  Created by yimkeul on 9/26/24.
//

import Foundation


// MARK: PlayMode 상태 모음

extension AudioPlayerViewModel {
    func repeatModeToggle() {
        if playMode == .isDefaultMode {
            playMode = .isInfinityMode
        } else if playMode == .isInfinityMode {
            playMode = .isDefaultMode
        } else {
            playMode = .isDefaultMode
        }
    }
    
    func shuffleModeToggle() {
        isShuffleMode.toggle()
        guard let currentSong = currentSong else { return }

        waitingSongs = isShuffleMode ? shuffleExceptIndex(array: filteredSongs, index: filteredSongs.firstIndex(of: currentSong)!) : filteredSongs
    }
}
