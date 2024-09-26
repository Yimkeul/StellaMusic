//
//  TimeObserver+Extension.swift
//  StelliveMusic
//
//  Created by yimkeul on 9/26/24.
//

import Foundation
import AVFoundation

// MARK: - 시간 관찰자 관리
extension AudioPlayerViewModel {
     func addPeriodicTimeObserver() {
        // 중복 등록 방지
        guard timeObserver == nil else { return }

        let interval = CMTime(value: 1, timescale: 1)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            if self.isScrubbingInProgress || self.isSeekInProgress { return }

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

     func removePeriodicTimeObserver() {
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        currentTime = 0.0
        duration = 0.0
    }

    func seekToTime(_ time: TimeInterval) {
        guard let player = player else { return }
        let targetTime = CMTime(seconds: time, preferredTimescale: 600)

        // Seek 작업이 진행 중임을 표시
        isSeekInProgress = true

        player.seek(to: targetTime) { [weak self] completed in
            if completed {
                self?.isScrubbingInProgress = false // 슬라이더 드래그 중지
                self?.isSeekInProgress = false // seek 작업 완료
                self?.currentTime = time // seek 완료 후 실제 currentTime 반영
            }
        }
    }
}
