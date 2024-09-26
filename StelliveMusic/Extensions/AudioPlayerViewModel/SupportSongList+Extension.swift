//
//  SupportSongList+Extension.swift
//  StelliveMusic
//
//  Created by yimkeul on 9/26/24.
//

import Foundation

// MARK: SongList에 필요한 함수 (가수 이름 생성, 노래 리스트 필터)
extension AudioPlayerViewModel {

    func makeSinger(_ singers: [String]) -> String {
        return singers.joined(separator: " & ")
    }

    func filterSongs(songInfoItems: [Song], selectedSongType: SongType, stellaName: String) {
        let temp = stellaName == "스텔라이브" ? songInfoItems : songInfoItems.filter { $0.songInfo.singer.contains(stellaName) }
        filteredSongs = selectedSongType == .all ? temp.sorted { $0.songInfo.registrationDate > $1.songInfo.registrationDate }:
            temp.filter { $0.songInfo.songType == selectedSongType.rawValue }.sorted { $0.songInfo.registrationDate > $1.songInfo.registrationDate }
    }

    func getPlayerIcon(for item: Song) -> String {
        if currentSong == item {
            switch item.playerState {
            case .playing:
                return "pause.fill"
            case .paused, .stopped:
                return "play.fill"
            }
        }
        return "play.fill"
    }

    func getPlayerModeIcon() -> String {
        if playMode == .isDefaultMode {
            return "repeat.circle"
        } else if playMode == .isInfinityMode {
            return "repeat.circle.fill"
        } else {
            return "repeat.circle"
        }
    }

    func controlPlay(_ item: Song) {
        if item == currentSong {
            if item.playerState == .playing {
                pauseAudio()
            } else {
                playAudio(selectSong: item)
            }
        } else {
            playAudio(selectSong: item)
        }
    }
}
