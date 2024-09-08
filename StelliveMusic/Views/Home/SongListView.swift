//
//  SongListView.swift
//  StelliveMusic
//
//  Created by yimkeul on 9/4/24.
//

import SwiftUI
import Kingfisher
import Combine

struct SongListView: View {
    @EnvironmentObject var songInfoviewModel: SongInfoViewModel
    @EnvironmentObject var audioPlayerViewModel: AudioPlayerViewModel

    @State private var isNotificationObserverSet = false
    @Binding var selectedSongType: SongType
    @Binding var stellaName: String

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 8) {
                ForEach(audioPlayerViewModel.filteredSongs, id: \.self) { item in
                    let singer = audioPlayerViewModel.makeSinger(item.songInfo.singer)
                    SongListItem(item: item, singer: singer)
                        .onTapGesture {
                        controlPlay(item)
                        songInfoviewModel.objectWillChange.send()
                    }
                }
            }
        }
            .padding(16)
            .onAppear {

            audioPlayerViewModel.setupAudioPlayer()

            songInfoviewModel.$songInfoItems
                .receive(on: DispatchQueue.main)
                .sink { [weak audioPlayerViewModel] newSongs in
                audioPlayerViewModel?.filterSongs(songInfoItems: newSongs, selectedSongType: selectedSongType, stellaName: stellaName)
            }
                .store(in: &audioPlayerViewModel.cancellables)

            if !isNotificationObserverSet {
                // 음악 종료 시점을 감지하는 Notification 구독
                NotificationCenter.default.addObserver(forName: Notification.Name("audioFinished"), object: nil, queue: .main) { _ in
                    audioPlayerViewModel.currentSong?.playerState = .stopped
                }
                isNotificationObserverSet = true
            }
        }
            .onChange(of: selectedSongType) { newType in
            audioPlayerViewModel.filterSongs(songInfoItems: songInfoviewModel.songInfoItems, selectedSongType: newType, stellaName: stellaName)
        }
            .onChange(of: stellaName) { newName in
            audioPlayerViewModel.filterSongs(songInfoItems: songInfoviewModel.songInfoItems, selectedSongType: selectedSongType, stellaName: newName)
        }
    }

    // 음악 재생/일시정지 제어 함수
    func controlPlay(_ item: Songs) {
        if item == audioPlayerViewModel.currentSong {
            if item.playerState == .playing {
                audioPlayerViewModel.pauseAudio()
            } else {
                audioPlayerViewModel.playAudio(url: URL(string: item.songInfo.mp3Link), song: item)
            }
        } else {
            audioPlayerViewModel.playAudio(url: URL(string: item.songInfo.mp3Link), song: item)
        }
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

                        Button {
                            controlPlay(item)
                        } label: {
                            Image(systemName: getPlayerIcon(for: item))

                        }.padding(.trailing, 4)
                            .onReceive(item.$playerState) { _ in
                            songInfoviewModel.objectWillChange.send()
                        }

                    }
                    Spacer()
                    Divider()
                }
            }
        }
            .contentShape(Rectangle())
    }

    private func getPlayerIcon(for item: Songs) -> String {
        if audioPlayerViewModel.currentSong == item {
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
