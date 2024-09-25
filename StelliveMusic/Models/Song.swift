//
//  Song.swift
//  StelliveMusic
//
//  Created by yimkeul on 9/7/24.
//

import Foundation
import Combine

class Song: ObservableObject {

    @Published var songInfo: SongInfo
    @Published var playerState: PlayerState = .stopped

    init(songInfo: SongInfo, playerState: PlayerState = .stopped) {
        self.songInfo = songInfo
        self.playerState = playerState
    }
}

extension Song: Hashable {
    static func == (lhs: Song, rhs: Song) -> Bool {
        return lhs.songInfo == rhs.songInfo
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(songInfo)
    }
}
