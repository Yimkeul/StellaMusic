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

class AudioPlayerViewModel: ObservableObject {
    // TODO: 업데이트 하기
    enum PlayMode {
//        case isShuffledMode
        case isInfinityMode
        case isOneSongInfinityMode
        case isDefaultMode
    }

    private var player: AVQueuePlayer?
    var cancellables = Set<AnyCancellable>()

    var isPlaying = false

    @Published var filteredSongs: [Songs] = []
    @Published var currentSong: Songs?

    private var waitingSongs: [Songs] = []

    // 재생 시간 관련 프로퍼티
    @Published private(set) var duration: TimeInterval = 0.0
    @Published private(set) var currentTime: TimeInterval = 0.0

    // 재생 모드 관련 (셔플, 무한 반복, 1곡 반복, 1회전)
    @Published var playMode: PlayMode = .isDefaultMode
    @Published var isShuffleMode: Bool = false
    private var timeObserver: Any?

    init() {
        // 재생이 끝날 때 이벤트 감지
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { [weak self] notification in
            guard let self = self else { return }
            self.SongListDidFinishPlaying(notification, self.waitingSongs)
        }
    }
    // 전체 선택 노래 종료후 함수
    private func SongListDidFinishPlaying(_ notification: Notification, _ playList: [Songs]) {
        print("check is Finish Play")

        guard let finishedSong = currentSong else {
            print("in allSongListDidFinishPlaying error")
            return
        }
        finishedSong.playerState = .stopped
        print("Check Finished PlayedSong :\(finishedSong.songInfo.title), \(finishedSong.playerState)")

        // 현재 곡이 끝나면 타임 옵저버 제거
        removePeriodicTimeObserver()

        switch playMode {
        case .isDefaultMode:
            if isShuffleMode {
                player?.removeAllItems()
                if let selectSongIndex = self.waitingSongs.firstIndex(of: finishedSong) {
                    let temp = shuffleExceptIndex(array: self.waitingSongs, index: selectSongIndex)
                    guard let nextSong = getNextSong(for: finishedSong, playList: temp) else { return }
                    player?.insert(AVPlayerItem(url: URL(string:nextSong.songInfo.mp3Link)!), after: nil)
                    currentSong = nextSong
                    player?.play()
                    addPeriodicTimeObserver()
                    isPlaying = true
                    currentSong?.playerState = .playing
                    updateNowPlayingInfo()
                }
            } else {
                guard let nextSong = getNextSong(for: finishedSong, playList: playList) else { return
                }
                if nextSong != playList.first {
                    player?.insert(AVPlayerItem(url: URL(string:nextSong.songInfo.mp3Link)!), after: nil)
                    currentSong = nextSong
                    player?.play()
                    addPeriodicTimeObserver()
                    isPlaying = true
                    currentSong?.playerState = .playing
                    updateNowPlayingInfo()
                }
            }
            
        case .isInfinityMode:
            guard let nextSong = getNextSong(for: finishedSong, playList: playList) else { return
            }
            if nextSong == playList.first {
                //한바퀴 재생 완료
                playAllAudio()
            } else {
                currentSong = nextSong
                currentSong?.playerState = .playing
                updateNowPlayingInfo()
                addPeriodicTimeObserver()
            }
            // TODO: 한곡 반복재생이랑 셔플모드 구현하기
        case .isOneSongInfinityMode:
            return
        }
    }

    func shuffleModeToggle() {
        isShuffleMode.toggle()
    }

    func checkCurrentSong() {
        self.$currentSong
            .receive(on: DispatchQueue.main)
            .sink {
            print("Check: \($0?.songInfo.title), \($0?.playerState)")
        }
            .store(in: &cancellables)
    }

    func controlPlay(_ item: Songs) {
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

    func clearAVPlayer() {
        removePeriodicTimeObserver() // 초단위 초기화
        player?.pause() // 플레이어 정지
        player?.removeAllItems() // 플레이어 초기화
    }

    func getNextSong(for song: Songs, playList: [Songs]) -> Songs? {
        guard let currentIndex = playList.firstIndex(of: song) else { return nil }
        let nextIndex = (currentIndex + 1) % playList.count
        print("Next Song in 전체 선택 : \(playList[nextIndex].songInfo.title)")
        return playList[nextIndex]
    }

    func shuffleExceptIndex<T>(array: [T], index: Int) -> [T] {
        let element = array[index]
        var remainingArray = array
        remainingArray.remove(at: index)
        remainingArray.shuffle()
        return [element] + remainingArray
    }
}

// MARK: MusicPlayer 전체 재생 관련
extension AudioPlayerViewModel {
    // 전체 곡 재생
    func playAllAudio() {
        if player == nil {
            player = AVQueuePlayer()
        }

        clearAVPlayer()

        if isShuffleMode {
            self.waitingSongs = filteredSongs.shuffled()
        } else {
            self.waitingSongs = filteredSongs
        }

        guard !self.waitingSongs.isEmpty else { return }

        let items = self.waitingSongs.map { AVPlayerItem(url: URL(string: $0.songInfo.mp3Link)!) }

        player = AVQueuePlayer(items: items)
        player?.play()


        currentSong = waitingSongs.first
        currentSong?.playerState = .playing
        addPeriodicTimeObserver()
        isPlaying = true
        updateNowPlayingInfo()
    }



    // 선택 곡 재생
    func playAudio(selectSong: Songs) {
        if player == nil {
            player = AVQueuePlayer()
        }

        self.waitingSongs = filteredSongs

        if currentSong == selectSong && player?.currentItem?.status == .readyToPlay {
            player?.play()
            isPlaying = true
            currentSong?.playerState = .playing
        } else {
            if let selectSongIndex = self.waitingSongs.firstIndex(of: selectSong) {
                clearAVPlayer()
                // 선택한 노래부터 추가
                player?.insert(AVPlayerItem(url: URL(string: self.waitingSongs[selectSongIndex].songInfo.mp3Link)!), after: nil)
                // 선택한 노래 뒤 추가
                for index in selectSongIndex + 1 ..< self.waitingSongs.count {
                    let item = AVPlayerItem(url: URL(string: self.waitingSongs[index].songInfo.mp3Link)!)
                    player?.insert(item, after: nil)
                }
                currentSong = selectSong
                player?.play()
                isPlaying = true
                currentSong?.playerState = .playing
                addPeriodicTimeObserver()
            }
        }

        updateNowPlayingInfo()
    }

    func playShuffleAudio() {
        isShuffleMode = true
        playAllAudio()
    }

    // 이전 곡 재생
    func playPreviousAudio() {
        guard let currentSong = currentSong else {
            print("현재 재생 중인 곡이 없습니다.")
            return
        }

        guard let currentIndex = self.waitingSongs.firstIndex(of: currentSong) else {
            print("현재 곡이 waitingSongs에 없습니다.")
            return
        }

        let previousIndex = (currentIndex - 1 + waitingSongs.count) % waitingSongs.count
        let previousSong = waitingSongs[previousIndex]


        playAudio(selectSong: previousSong)
    }

    // 다음 곡 재생
    func playNextAudio() {
        if isShuffleMode {
            if let selectSongIndex = self.waitingSongs.firstIndex(of: currentSong!) {
                let temp = shuffleExceptIndex(array: self.waitingSongs, index: selectSongIndex)
                playAudio(selectSong: getNextSong(for: currentSong!, playList: temp)!)
            }
        } else {
            playAudio(selectSong: getNextSong(for: currentSong!, playList: self.waitingSongs)!)
        }

    }

    // 곡 일시정지
    func pauseAudio() {
        player?.pause()
        isPlaying = false
        currentSong?.playerState = .paused
    }

}

// MARK: - 시간 관찰자 관리
extension AudioPlayerViewModel {
    // 시간 관찰자 추가
    private func addPeriodicTimeObserver() {
        // 중복 등록 방지
        guard timeObserver == nil else { return }

        let interval = CMTime(value: 1, timescale: 1)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }

            let newCurrentTime = time.seconds
            let newDuration = self.player?.currentItem?.duration.seconds ?? 0.0

            if newCurrentTime.isFinite && !newCurrentTime.isNaN {
                self.currentTime = newCurrentTime
            }

            if newDuration.isFinite && !newDuration.isNaN {
                self.duration = newDuration
            }

            self.updateNowPlayingInfo()
        }

    }

    // 시간 관찰자 삭제
    private func removePeriodicTimeObserver() {
        // 옵저버가 없으면 아무 것도 하지 않음
        guard let timeObserver = timeObserver else { return }

        // 옵저버 해제
        player?.removeTimeObserver(timeObserver)
        self.timeObserver = nil
        self.currentTime = 0.0
        self.duration = 0.0
    }

    // 현재 시간 설정
    func setCurrentTime(_ time: TimeInterval) {
        guard time.isFinite && !time.isNaN else { return }
        self.currentTime = time

        if let player = player {
            let newTime = CMTime(seconds: time, preferredTimescale: 600) // Timescale을 더 세밀하게 조정
            player.seek(to: newTime)
        }
    }

    // 설정한 구간부터 음악 재생
    func seekToTime(_ time: TimeInterval) {
        guard let player = player else { return }
        let targetTime = CMTime(seconds: time, preferredTimescale: 600)
        player.seek(to: targetTime) { [weak self] _ in
            self?.currentTime = time
        }
    }
}

// MARK: 1. SongList에 필요한 함수 (가수 이름 생성, 노래 리스트 필터)
extension AudioPlayerViewModel {
    func makeSinger(_ singers: [String]) -> String {
        return singers.joined(separator: " & ")
    }

    func filterSongs(songInfoItems: [Songs], selectedSongType: SongType, stellaName: String) {
        let temp = stellaName == "스텔라이브" ? songInfoItems : songInfoItems.filter { $0.songInfo.singer.contains(stellaName) }
        filteredSongs = selectedSongType == .all ? temp : temp.filter { $0.songInfo.songType == selectedSongType.rawValue }
    }
    func getPlayerIcon(for item: Songs) -> String {
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
}


// MARK: 제어센터 관련
extension AudioPlayerViewModel {

    func MPNowPlayingInfoCenterSetting() {
        UIApplication.shared.beginReceivingRemoteControlEvents()

        let center = MPRemoteCommandCenter.shared()

        // 재생, 일시정지 버튼 활성화
        center.playCommand.addTarget { [weak self] _ in
            guard let self = self, let song = self.currentSong else { return .commandFailed }
            self.playAudio(selectSong: song) // 선택된 곡 재생
            return .success
        }

        center.pauseCommand.addTarget { [weak self] _ in
            self?.pauseAudio() // 일시정지
            return .success
        }

        // 다음 곡으로 넘어가는 스킵 기능
        center.nextTrackCommand.addTarget { [weak self] _ in
            self?.playNextAudio() // 다음 곡 재생
            return .success
        }

        // 이전 곡으로 돌아가는 스킵 기능
        center.previousTrackCommand.addTarget { [weak self] _ in
            self?.playPreviousAudio() // 이전 곡 재생
            return .success
        }

        // 커맨드 활성화
        center.skipForwardCommand.isEnabled = true
        center.skipBackwardCommand.isEnabled = true
    }

    // Now Playing 정보 업데이트
    private func updateNowPlayingInfo() {
        guard let currentSong = currentSong else {
            return
        }

        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = [String: Any]()
        let singerName = makeSinger(currentSong.songInfo.singer)

        nowPlayingInfo[MPMediaItemPropertyTitle] = currentSong.songInfo.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = singerName

        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player?.currentTime().seconds

        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player?.currentItem?.duration.seconds

        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0 // 재생 중이면 1.0, 일시 정지 상태면 0.0

        if let artworkURL = URL(string: currentSong.songInfo.thumbnail) {
            KingfisherManager.shared.retrieveImage(with: artworkURL) { result in
                switch result {
                case .success(let value):
                    let artworkImage = value.image
                    let artwork = MPMediaItemArtwork(boundsSize: artworkImage.size) { _ in
                        return artworkImage
                    }
                    nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork

                case .failure(let error):
                    print("Failed to download image: \(error.localizedDescription)")
                }

                // 업데이트 완료 후 NowPlayingInfo 설정
                nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
            }
        } else {
            // URL이 없으면 NowPlayingInfo 바로 업데이트
            nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo

        }
    }
}


