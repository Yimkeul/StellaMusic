//
//  AudioPlayerViewModel.swift
//  StelliveMusic
//
//  Created by yimkeul on 9/7/24.
//

import Foundation
import AVFoundation
import Combine
import MediaPlayer

class AudioPlayerViewModel: ObservableObject {
    private var player: AVQueuePlayer?
    private var currentItem: AVPlayerItem?
    var cancellables = Set<AnyCancellable>()

    @Published var filteredSongs: [Songs] = []
    @Published var currentSong: Songs?
    
    // 재생 시간 관련 프로퍼티
    @Published private(set) var duration: TimeInterval = 0.0
    @Published private(set) var currentTime: TimeInterval = 0.0
    private var timeObserver: Any?

    func makeSinger(_ singers: [String]) -> String {
        return singers.joined(separator: " & ")
    }

    func filterSongs(songInfoItems: [Songs], selectedSongType: SongType, stellaName: String) {
        let temp = stellaName == "스텔라이브" ? songInfoItems : songInfoItems.filter { $0.songInfo.singer.contains(stellaName) }
        filteredSongs = selectedSongType == .all ? temp : temp.filter { $0.songInfo.songType == selectedSongType.rawValue }
    }

    func setupAudioPlayer() {
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)
            .compactMap { _ in self }
            .sink { viewModel in
            viewModel.handleAudioFinished() // 곡이 끝나면 호출
        }
            .store(in: &cancellables)
    }


    func playAudio(url: URL?, song: Songs?) {
        guard let url = url, let song = song else { return }

        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)

        if player == nil {
            player = AVQueuePlayer()
        }

        if currentSong == song && currentItem?.status == .readyToPlay {
            player?.play()
            song.playerState = .playing
        } else {
            removePeriodicTimeObserver()
            currentItem = AVPlayerItem(url: url)
            currentSong = song

            if let currentItem = currentItem {
                player?.removeAllItems()
                player?.insert(currentItem, after: nil)
                player?.play()
                song.playerState = .playing
                addPeriodicTimeObserver()

                if let nextSong = getNextSong(for: song) {
                    preloadNextAudio(url: URL(string: nextSong.songInfo.mp3Link))
                }
            }
        }
    }


    // 다음 곡 미리 로드 (AVQueuePlayer에 추가)
    func preloadNextAudio(url: URL?) {
        guard let url = url else { return }
        let preloadItem = AVPlayerItem(url: url)
        player?.insert(preloadItem, after: currentItem)
    }

    // 현재 곡의 다음 곡을 찾는 함수
    private func getNextSong(for song: Songs) -> Songs? {
        guard let currentIndex = filteredSongs.firstIndex(of: song) else { return nil }
        let nextIndex = (currentIndex + 1) % filteredSongs.count
        return filteredSongs[nextIndex]
    }

    // 음악 종료 처리 (다음 곡 자동 재생)
    private func handleAudioFinished() {
        DispatchQueue.main.async {
            self.currentSong?.playerState = .stopped
            self.removePeriodicTimeObserver() // 곡 종료 시 타이머 제거
            if let nextSong = self.getNextSong(for: self.currentSong!) {
                self.playAudio(url: URL(string: nextSong.songInfo.mp3Link), song: nextSong)
            }
        }
    }

    // 음악 일시정지
    func pauseAudio() {
        player?.pause()
        currentSong?.playerState = .paused
        // 일시정지 시 타이머는 그대로 유지하여 현재 시간을 업데이트
    }

    // MARK: - 시간 관찰자 관리

    private func addPeriodicTimeObserver() {
        removePeriodicTimeObserver() // 기존 타이머가 있으면 제거
        let interval = CMTime(value: 1, timescale: 1)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            // 재생 시간 유효성 체크
            let newCurrentTime = time.seconds
            let newDuration = self.player?.currentItem?.duration.seconds ?? 0.0

            if newCurrentTime.isFinite && !newCurrentTime.isNaN {
                self.currentTime = newCurrentTime
            } else {
                self.currentTime = 0.0 // 기본값 설정
            }

            if newDuration.isFinite && !newDuration.isNaN {
                self.duration = newDuration
            } else {
                self.duration = 0.0 // 기본값 설정
            }
        }
    }


    private func removePeriodicTimeObserver() {
        guard let timeObserver = timeObserver else { return }
        player?.removeTimeObserver(timeObserver)
        self.timeObserver = nil
        self.currentTime = 0.0
        self.duration = 0.0
    }

    func setCurrentTime(_ time: TimeInterval) {
        guard time.isFinite && !time.isNaN else { return }
        self.currentTime = time
        if let player = player {
            let newTime = CMTime(seconds: time, preferredTimescale: 1)
            player.seek(to: newTime)
        }
    }

    func seekToTime(_ time: TimeInterval) {
        guard let player = player else { return }
        let targetTime = CMTime(seconds: time, preferredTimescale: 1)
        player.seek(to: targetTime) { _ in
            self.currentTime = time
        }
    }
    

    func timeString(_ time: TimeInterval) -> String {
        let minute = Int(time) / 60
        let second = Int(time) % 60
        return String(format: "%02d:%02d", minute, second)
    }

}
