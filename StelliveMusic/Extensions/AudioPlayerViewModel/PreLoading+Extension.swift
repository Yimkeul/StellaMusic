//
//  PreLoading+Extension.swift
//  StelliveMusic
//
//  Created by yimkeul on 9/26/24.
//

import Foundation
import AVFoundation

// MARK: PreLoading 모음
extension AudioPlayerViewModel {
    
     func preloadNextSong() {
        guard let currentSong = currentSong,
            let currentIndex = waitingSongs.firstIndex(of: currentSong) else { return }
        let nextIndex = (currentIndex + 1) % waitingSongs.count
        let nextSong = waitingSongs[nextIndex]

        guard let nextSongURL = URL(string: nextSong.songInfo.mp3Link) else { return }

        nextPlayerItem = AVPlayerItem(url: nextSongURL)
        nextPlayerItem?.preferredForwardBufferDuration = 1
        print("ready nextSong : \(nextSong.songInfo.title)")
    }
    
     func preloadPreviousSong() {
        guard let currentSong = currentSong,
            let currentIndex = waitingSongs.firstIndex(of: currentSong) else { return }
        let previousIndex = (currentIndex - 1 + waitingSongs.count) % waitingSongs.count
        let previousSong = waitingSongs[previousIndex]

        guard let previousSongURL = URL(string: previousSong.songInfo.mp3Link) else { return }

        // 이전 곡을 미리 로드하고 캐싱합니다.
        previousPlayerItem = AVPlayerItem(url: previousSongURL)
        previousPlayerItem?.preferredForwardBufferDuration = 1
        print("ready PrevSong : \(previousSong.songInfo.title)")
    }

     func replaceSong(for song: Song, at item: AVPlayerItem) {
        currentSong?.playerState = .paused
        removePeriodicTimeObserver()
        player?.replaceCurrentItem(with: item)
        currentSong = song
        currentSong?.playerState = .playing
        updateNowPlayingInfo()
        addPeriodicTimeObserver()
        preloadNextSong()
        preloadPreviousSong()
    }
}
