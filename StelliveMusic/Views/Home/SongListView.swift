//
//  SongListView.swift
//  StelliveMusic
//
//  Created by yimkeul on 9/4/24.
//

import Foundation
import SwiftUI
import Kingfisher
import Combine

struct SongListView: View {
    @EnvironmentObject var viewModel: SongInfoViewModel
    @StateObject private var audioPlayerViewModel = AudioPlayerViewModel()

    @State var currentPlay: Songs? = nil
    @State private var isNotificationObserverSet = false
    @Binding var selectedSongType: SongType
    @Binding var stellaName: String

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 8) {
                ForEach(audioPlayerViewModel.filteredSongs, id: \.self) { item in
                    let singer = makeSinger(item.songInfo.singer)
                    SongListItem(item: item, singer: singer)
                        .onTapGesture {
                        controlPlay(currentPlay, item)
                        viewModel.objectWillChange.send()
                    }
                }
            }
        }
            .padding(16)
            .onAppear {
            audioPlayerViewModel.setupAudioPlayer()

            viewModel.$songInfoItems
                .receive(on: DispatchQueue.main) // 메인 스레드에서 처리
            .sink { [weak audioPlayerViewModel] newSongs in
                audioPlayerViewModel?.filterSongs(songInfoItems: newSongs, selectedSongType: selectedSongType, stellaName: stellaName)

            }
                .store(in: &audioPlayerViewModel.cancellables)
                
                if !isNotificationObserverSet {
                    // 음악 종료 시점을 감지하는 Notification 구독
                    NotificationCenter.default.addObserver(forName: Notification.Name("audioFinished"), object: nil, queue: .main) { _ in
                        // 음악이 끝나면 현재 재생 중인 노래를 멈춘 상태로 변경
                        if let currentPlay = currentPlay {
                            currentPlay.isPlay = false
                        }
                    }
                    isNotificationObserverSet = true
                }
            
        }
            .onChange(of: selectedSongType) { newType in
            audioPlayerViewModel.filterSongs(songInfoItems: viewModel.songInfoItems, selectedSongType: newType, stellaName: stellaName)
        }
            .onChange(of: stellaName) { newName in
            audioPlayerViewModel.filterSongs(songInfoItems: viewModel.songInfoItems, selectedSongType: selectedSongType, stellaName: newName)
        }
    }


    // 음악 재생/일시정지 제어 함수
    func controlPlay(_ current: Songs?, _ item: Songs) {
        if let current = currentPlay {
            if item == current {
                if item.isPlay {
                    item.isPlay = false
                    audioPlayerViewModel.pauseAudio()
                } else {
                    item.isPlay = true
                    audioPlayerViewModel.playAudio(url: URL(string: item.songInfo.mp3Link), song: item)
                }
            } else {
                current.isPlay = false
                currentPlay = item
                item.isPlay = true
                audioPlayerViewModel.playAudio(url: URL(string: item.songInfo.mp3Link), song: item)
            }
        } else {
            currentPlay = item
            item.isPlay = true
            audioPlayerViewModel.playAudio(url: URL(string: item.songInfo.mp3Link), song: item)
        }
    }

    private func makeSinger(_ singers: [String]) -> String {
        return singers.joined(separator: " & ")
    }

    @ViewBuilder
    private func SongListItem(item: Songs, singer: String) -> some View {
        VStack(spacing: 16) {
            HStack(alignment: .center) {
                KFImage(URL(string: item.songInfo.thumbnail))
                    .resizable()
                    .frame(width: 70, height: 50)
                    .cornerRadius(4)
                    .scaledToFill()
                    .padding(.trailing, 8)

                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(item.songInfo.title)
                                .font(.system(size: 18, weight: .bold))
                                .lineLimit(1)

                            Text(singer)
                                .font(.system(size: 14, weight: .semibold))
                        }

                        Spacer()
                        Button(action: { controlPlay(currentPlay, item) }, label: {
                            Image(systemName: item.isPlay ? "pause.fill" : "play.fill")

                        })
                            .padding(.trailing, 4)
                    }
                    Spacer()
                    Divider()
                }
            }
        }
            .contentShape(Rectangle())
    }
}
