//
//  PlayerController+Extension.swift
//  StelliveMusic
//
//  Created by yimkeul on 9/26/24.
//

import Foundation
import AVFoundation

// MARK: MusicPlayer 전체 재생 관련
extension AudioPlayerViewModel {
    
    private func clearAVPlayer() {
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        removePeriodicTimeObserver()
        currentTime = 0.0
        duration = 0.0
    }

    private func stopPlayback() {
        clearAVPlayer()
        isPlaying = false
        currentSong?.playerState = .stopped
    }

    func pauseAudio() {
        player?.pause()
        isPlaying = false
        currentSong?.playerState = .paused
    }

    func playAudio(selectSong: Song) {
        guard let songURL = URL(string: selectSong.songInfo.mp3Link) else { return }
        if currentSong == selectSong && player?.currentItem?.status == .readyToPlay {
            player?.play()
            isPlaying = true
            currentSong?.playerState = .playing
            return
        }
        clearAVPlayer()

        let playerItem = AVPlayerItem(url: songURL)
        player = AVPlayer(playerItem: playerItem)
        player?.play()
        isPlaying = true
        currentSong = selectSong
        currentSong?.playerState = .playing
        updateNowPlayingInfo()
        addPeriodicTimeObserver()

        guard let selectedIndex = filteredSongs.firstIndex(of: selectSong) else { return }
        waitingSongs = isShuffleMode ? shuffleExceptIndex(array: filteredSongs, index: selectedIndex) : filteredSongs
        preloadNextSong()
        preloadPreviousSong()
    }

    func playNextAudio() {
        guard let currentSong = currentSong else { return }
        playNextAudio(for: currentSong)
    }

    func playNextAudio(for finishedSong: Song) {
        guard let currentIndex = waitingSongs.firstIndex(of: finishedSong) else { return }
        let nextIndex = (currentIndex + 1) % waitingSongs.count
        let nextSong = waitingSongs[nextIndex]
        switch playMode {
        case .isDefaultMode:
            if nextIndex == 0 {
                stopPlayback()
            } else {
                if let nextPlayerItem = nextPlayerItem {
                    replaceSong(for: nextSong, at: nextPlayerItem)
                } else {
                    playAudio(selectSong: nextSong)
                }
            }
        case .isInfinityMode:
            playAudio(selectSong: nextSong)
        case .isOneSongInfinityMode:
            // TODO: 업데이트 목록
            break
        }
    }

    func playPreviousAudio() {
        guard let currentSong = currentSong else { return }
        if currentTime > 2.0 {
            player?.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
        } else {
            guard let currentIndex = waitingSongs.firstIndex(of: currentSong) else { return }

            if isShuffleMode {
                if currentIndex == 0 {
                    stopPlayback()
                } else {
                    let previousSong = waitingSongs[currentIndex - 1]
                    if let previousPlayerItem = previousPlayerItem {
                        replaceSong(for: previousSong, at: previousPlayerItem)
                    } else {
                        playAudio(selectSong: previousSong)
                    }
                }
                return
            }
            switch playMode {
            case .isDefaultMode:
                if currentIndex == 0 {
                    stopPlayback()
                } else {
                    let previousSong = waitingSongs[currentIndex - 1]
                    if let previousPlayerItem = previousPlayerItem {
                        replaceSong(for: previousSong, at: previousPlayerItem)
                    } else {
                        playAudio(selectSong: previousSong)
                    }
                }

            case .isInfinityMode:
                let previousIndex = (currentIndex - 1 + waitingSongs.count) % waitingSongs.count
                let previousSong = waitingSongs[previousIndex]
                playAudio(selectSong: previousSong)
            case .isOneSongInfinityMode:
                // 나중에 구현할 내용
                break
            }
        }
    }

    func playAllAudio() {
        isShuffleMode = false
        waitingSongs = filteredSongs
        guard let song = waitingSongs.first else { return }
        playAudio(selectSong: song)
    }

    func playAllShuffleAudio() {
        isShuffleMode = true
        waitingSongs = filteredSongs.shuffled()
        guard let song = waitingSongs.first else { return }
        playAudio(selectSong: song)
    }
}
