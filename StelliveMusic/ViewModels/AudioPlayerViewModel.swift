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
import Kingfisher

class AudioPlayerViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate {

    enum PlayMode {
        case isInfinityMode
        case isOneSongInfinityMode
        case isDefaultMode
    }

    @Published var filteredSongs: [Song] = []
    @Published var currentSong: Song?

    // 재생 시간 관련 프로퍼티
    @Published  var duration: TimeInterval = 0.0
    @Published  var currentTime: TimeInterval = 0.0
    @Published var isScrubbingInProgress: Bool = false // 슬라이더 드래그 중인지 여부
    @Published var isSeekInProgress: Bool = false // seek 작업이 진행 중인지 여부

    // 재생 모드 관련 (셔플, 무한 반복, 1곡 반복, 1회전)
    @Published var playMode: PlayMode = .isDefaultMode
    @Published var isShuffleMode: Bool = false

    var player: AVPlayer?
    var waitingSongs: [Song] = []
    var timeObserver: Any?

    var cancellables = Set<AnyCancellable>()
    var isPlaying = false

    var nextPlayerItem: AVPlayerItem?
    var previousPlayerItem: AVPlayerItem?


    override init() {
        super.init()
        setupNotificationObservers()
    }
    // MARK: Setup Notification Observers
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleSongDidFinishPlaying(_:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleAudioInterruption(_:)), name: AVAudioSession.interruptionNotification, object: nil)
    }

    @objc private func handleSongDidFinishPlaying(_ notification: Notification) {
        guard let currentSong = currentSong else { return }
        currentSong.playerState = .stopped
        playNextAudio(for: currentSong)
    }

    @objc private func handleAudioInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue), type == .began else {
            return
        }
        pauseAudio()
    }

    // array에서 index를 맨앞으로 하고 나머지는 shuffle :: legacy
    func shuffleExceptIndex<T>(array: [T], index: Int) -> [T] {
        let element = array[index]
        var remainingArray = array
        remainingArray.remove(at: index)
        remainingArray.shuffle()
        return [element] + remainingArray
    }
}
