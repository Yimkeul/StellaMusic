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
    var cancellables = Set<AnyCancellable>()
    private var currentItem: AVPlayerItem?

    @Published var isPlaying = false
    @Published var filteredSongs: [Songs] = []

    var currentSong: Songs? // 현재 재생 중인 곡 추적

    func filterSongs(songInfoItems: [Songs], selectedSongType: SongType, stellaName: String) {
        if stellaName == "스텔라이브" {
            filteredSongs = selectedSongType == .all ? songInfoItems : songInfoItems.filter {
                $0.songInfo.songType == selectedSongType.rawValue
            }
        } else {
            let temp = songInfoItems.filter { $0.songInfo.singer.contains(stellaName) }
            filteredSongs = selectedSongType == .all ? temp : temp.filter { $0.songInfo.songType == selectedSongType.rawValue }
        }
    }

    func setupAudioPlayer() {
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)
            .sink { [weak self] _ in
            self?.handleAudioFinished() // 곡이 끝나면 호출
        }
            .store(in: &cancellables)
    }

    // 음악 재생
    func playAudio(url: URL?, song: Songs?) {
        guard let url = url, let song = song else { return }
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        // AVQueuePlayer가 없으면 새로 생성
        if player == nil {
            player = AVQueuePlayer()
        }

        currentItem = AVPlayerItem(url: url) // 현재 재생할 AVPlayerItem 준비
        currentSong = song // 현재 곡 설정

        if let currentItem = currentItem {
            player?.removeAllItems() // 기존 재생 목록을 모두 비웁니다.
            player?.insert(currentItem, after: nil) // 현재 곡을 재생 목록에 추가
            player?.play()
            isPlaying = true
            song.isPlay = true // 재생 중인 곡의 isPlay를 true로 설정

            // 다음 곡을 미리 큐에 추가
            if let nextSong = getNextSong(for: song) {
                preloadNextAudio(url: URL(string: nextSong.songInfo.mp3Link))
            }
        }
    }

    // 다음 곡 미리 로드 (AVQueuePlayer에 추가)
    func preloadNextAudio(url: URL?) {
        guard let url = url else { return }

        let preloadItem = AVPlayerItem(url: url) // 다음 곡을 위한 AVPlayerItem 준비

        // 다음 곡을 AVQueuePlayer의 재생 목록에 추가
        player?.insert(preloadItem, after: currentItem)
    }

    // 현재 곡의 다음 곡을 찾는 함수
    private func getNextSong(for song: Songs) -> Songs? {
        guard let currentIndex = filteredSongs.firstIndex(of: song) else {
            return nil
        }

        // 다음 곡의 인덱스를 계산 (마지막 곡이면 첫 번째 곡으로)
        let nextIndex = (currentIndex + 1) % filteredSongs.count
        return filteredSongs[nextIndex]
    }

    // 음악 종료 처리 (다음 곡 자동 재생)
    private func handleAudioFinished() {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.currentSong?.isPlay = false // 현재 곡 재생 상태 변경

            // 현재 곡이 끝난 후 다음 곡을 재생
            if let nextSong = self.getNextSong(for: self.currentSong!) {
                self.playAudio(url: URL(string: nextSong.songInfo.mp3Link), song: nextSong)
            }
        }
    }

    // 음악 일시정지
    func pauseAudio() {
        player?.pause()
        isPlaying = false
        currentSong?.isPlay = false // 일시정지 시 isPlay를 false로 설정
    }
}


//class AudioPlayerViewModel: ObservableObject {
//    private var player: AVQueuePlayer? // AVQueuePlayer 사용
//    var cancellables = Set<AnyCancellable>()
//    private var currentItem: AVPlayerItem?
//
//    @Published var isPlaying = false
//    @Published var filteredSongs: [Songs] = []
//
//    var currentSong: Songs? // 현재 재생 중인 곡 추적
//
//    func filterSongs(songInfoItems: [Songs], selectedSongType: SongType, stellaName: String) {
//        if stellaName == "스텔라이브" {
//            filteredSongs = selectedSongType == .all ? songInfoItems : songInfoItems.filter {
//                $0.songInfo.songType == selectedSongType.rawValue
//            }
//        } else {
//            let temp = songInfoItems.filter { $0.songInfo.singer.contains(stellaName) }
//            filteredSongs = selectedSongType == .all ? temp : temp.filter { $0.songInfo.songType == selectedSongType.rawValue }
//        }
//    }
//
//
//
//
//    func setupAudioPlayer() {
//        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)
//            .sink { [weak self] _ in
//            self?.handleAudioFinished() // 곡이 끝나면 호출
//        }
//            .store(in: &cancellables)
//    }
//
//    // 음악 재생
//    func playAudio(url: URL?, song: Songs?) {
//        guard let url = url, let song = song else { return }
//
//        // AVQueuePlayer가 없으면 새로 생성
//        if player == nil {
//            player = AVQueuePlayer()
//        }
//
//        currentItem = AVPlayerItem(url: url) // 현재 재생할 AVPlayerItem 준비
//        currentSong = song // 현재 곡 설정
//
//        if let currentItem = currentItem {
//            player?.removeAllItems() // 기존 재생 목록을 모두 비웁니다.
//            player?.insert(currentItem, after: nil) // 현재 곡을 재생 목록에 추가
//            player?.play()
//            isPlaying = true
//            song.isPlay = true // 재생 중인 곡의 isPlay를 true로 설정
//
//            // 다음 곡을 미리 큐에 추가
//            preloadNextAudio(url: URL(string: "https://drive.google.com/uc?export=download&id=1JryiPMB8rUac0M1uNFtjAUlWqjs81pGb"))
//        }
//    }
//
//    // 다음 곡 미리 로드 (AVQueuePlayer에 추가)
//    func preloadNextAudio(url: URL?) {
//        guard let url = url else { return }
//
//        let preloadItem = AVPlayerItem(url: url) // 다음 곡을 위한 AVPlayerItem 준비
//
//        // 다음 곡을 AVQueuePlayer의 재생 목록에 추가
//        player?.insert(preloadItem, after: currentItem)
//    }
//
//    // 음악 종료 처리 (다음 곡 자동 재생)
//    private func handleAudioFinished() {
//        DispatchQueue.main.async {
//            self.isPlaying = false
//            self.currentSong?.isPlay = false // 현재 곡 재생 상태 변경
//
//            // 다음 곡이 자동 재생되므로, 여기서는 다음 곡을 다시 미리 로드하는 작업을 진행
//            self.preloadNextAudio(url: URL(string: "https://drive.google.com/uc?export=download&id=NEXT_SONG_ID"))
//        }
//    }
//
//    // 음악 일시정지
//    func pauseAudio() {
//        player?.pause()
//        isPlaying = false
//        currentSong?.isPlay = false // 일시정지 시 isPlay를 false로 설정
//    }
//}



