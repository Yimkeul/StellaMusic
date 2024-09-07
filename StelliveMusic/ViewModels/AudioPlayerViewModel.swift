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
    private var player: AVPlayer?
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isPlaying = false
    var currentSong: Songs?  // 현재 재생 중인 곡을 추적
    
    func setupAudioPlayer() {
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)
            .sink { [weak self] _ in
                self?.handleAudioFinished()
            }
            .store(in: &cancellables)
    }
    
    // 음악 재생
    func playAudio(url: URL?, song: Songs?) {
        guard let url = url, let song = song else { return }
        
        currentSong = song  // 현재 곡을 설정
        player = AVPlayer(url: url)
        player?.play()
        isPlaying = true
        song.isPlay = true   // 재생 중인 곡의 isPlay를 true로 설정
    }
    
    // 음악 일시정지
    func pauseAudio() {
        player?.pause()
        isPlaying = false
        currentSong?.isPlay = false  // 일시정지 시 isPlay를 false로 설정
    }
    
    // 음악 종료 처리
    private func handleAudioFinished() {
        DispatchQueue.main.async {
            self.isPlaying = false
            
            // 현재 재생 중인 곡의 상태를 변경
            self.currentSong?.isPlay = false
            
            NotificationCenter.default.post(name: Notification.Name("audioFinished"), object: nil)
            print("APVM:\(self.isPlaying)")
        }
    }
}
