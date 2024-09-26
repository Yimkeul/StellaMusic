//
//  DeBugTest+Extension.swift
//  StelliveMusic
//
//  Created by yimkeul on 9/26/24.
//

import Foundation
import AVFoundation

// MARK: 테스트 코드
extension AudioPlayerViewModel {

//    func checkQueueItems() {
//        if let currentItem = self.player?.currentItem {
//            let title = checkTitle(item: currentItem)
//            print("현재 재생 중인 곡: \(title)")
//        }
//
//        if let remainingItems = self.player?.items() {
//            print("Queue Count : \(remainingItems.count)")
//            for item in remainingItems {
//                let title = checkTitle(item: item)
//                print("\(title)", terminator: " / ")
//            }
//        }
//        print()
//        if !waitingSongs.isEmpty {
//            print("waitingSong : \(waitingSongs.count)")
//            for item in waitingSongs {
//                print("\(item.songInfo.title)", terminator: " - ")
//            }
//        }
//    }

    func checkTitle(item: AVPlayerItem) -> String {
        if let target = item.asset as? AVURLAsset {
            guard let item = self.waitingSongs.first(where: {
                $0.songInfo.mp3Link == target.url.absoluteString
            }) else { return "" }
            return item.songInfo.title
        } else {
            return ""
        }
    }
}
