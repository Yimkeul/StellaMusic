//
//  Songs.swift
//  StelliveMusic
//
//  Created by yimkeul on 9/7/24.
//

import Foundation
import Combine

class Songs: ObservableObject {

    @Published var songInfo: SongInfo
    @Published var isPlay: Bool = false

    init(songInfo: SongInfo, isPlay: Bool = false) {
        self.songInfo = songInfo
        self.isPlay = isPlay
    }
}

extension Songs: Hashable {
    static func == (lhs: Songs, rhs: Songs) -> Bool {
        return lhs.songInfo == rhs.songInfo
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(songInfo)
    }
}
