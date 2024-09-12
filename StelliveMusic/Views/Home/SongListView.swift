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

    @Binding var selectedSongType: SongType
    @Binding var stellaName: String

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 8) {
                ForEach(audioPlayerViewModel.filteredSongs, id: \.self) { item in
                    let singer = audioPlayerViewModel.makeSinger(item.songInfo.singer)
                    SongListItem(item: item, singer: singer)
                        .onTapGesture {
                        audioPlayerViewModel.controlPlay(item)
                        songInfoviewModel.objectWillChange.send()
                    }
                }
            }
        }
            .padding(16)
            .onAppear {

            songInfoviewModel.$songInfoItems
                .receive(on: DispatchQueue.main)
                .sink { [weak audioPlayerViewModel] newSongs in
                audioPlayerViewModel?.filterSongs(songInfoItems: newSongs, selectedSongType: selectedSongType, stellaName: stellaName)
            }
                .store(in: &audioPlayerViewModel.cancellables)

        }
            .onChange(of: selectedSongType) { newType in
            audioPlayerViewModel.filterSongs(songInfoItems: songInfoviewModel.songInfoItems, selectedSongType: newType, stellaName: stellaName)
        }
            .onChange(of: stellaName) { newName in
            audioPlayerViewModel.filterSongs(songInfoItems: songInfoviewModel.songInfoItems, selectedSongType: selectedSongType, stellaName: newName)
        }
    }

    @ViewBuilder
    private func SongListItem(item: Songs, singer: String) -> some View {
        VStack(spacing: 16) {
            HStack(alignment: .center) {
                ZStack(alignment: .center) {
                    KFImage(URL(string: item.songInfo.thumbnail))
                        .resizable()
                        .frame(width: 70, height: 50)
                        .cornerRadius(4)
                        .scaledToFill()

                    if item == audioPlayerViewModel.currentSong {
                        Color.black.opacity(0.8)
                        PlayingAnimationBar()
                            .frame(width: 15, height: 15)
                    }
                }
                    .frame(width: 70, height: 50)
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
                            audioPlayerViewModel.controlPlay(item)
                        } label: {
                            Image(systemName: audioPlayerViewModel.getPlayerIcon(for: item))
                                .foregroundStyle(.indigo)
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
}
