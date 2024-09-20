//
//  MusicPlayerView.swift
//  StelliveMusic
//
//  Created by yimkeul on 9/7/24.
//

import SwiftUI
import Kingfisher
import Combine

struct MusicPlayerView: View {
    @EnvironmentObject var audioPlayerViewModel: AudioPlayerViewModel
    @Binding var expandSheet: Bool
    var animation: Namespace.ID
    @State private var isLoadingSong: Bool = false

    var body: some View {
        if let currentSong = audioPlayerViewModel.currentSong {
            HStack(spacing: 0) {
                ZStack {
                    if !expandSheet {
                        GeometryReader {
                            let size = $0.size
                            KFImage(URL(string: currentSong.songInfo.thumbnail))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: size.width, height: size.height)
                                .clipShape(RoundedRectangle(cornerRadius: expandSheet ? 15 : 5, style: .continuous))
                        }
                            .matchedGeometryEffect(id: "ARTWORK", in: animation)
                    }
                }.frame(width: 45, height: 45)
                    .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        expandSheet = true
                    }
                }

                HStack(spacing: 0) {
                    Text(currentSong.songInfo.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .padding(.horizontal, 15)
                    Spacer(minLength: 0)
                }
                    .contentShape(Rectangle())
                    .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        expandSheet = true
                    }
                }

                if isLoadingSong {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else {
                    Button {
                        audioPlayerViewModel.controlPlay(currentSong)
                    } label: {
                        Image(systemName: audioPlayerViewModel.getPlayerIcon(for: currentSong))
                            .font(.title2)
                    }
                        .foregroundColor(.indigo)
                        .padding(.leading, 16)

                    Button {
                        audioPlayerViewModel.playNextAudio()
                    } label: {
                        Image(systemName: "forward.fill")
                            .font(.title2)
                    }.padding(.leading, 25)
                        .foregroundColor(.indigo)
                }
            }
                .padding(.horizontal)
                .padding(.bottom, 5)
                .frame(height: 70)
                .onAppear() {
                Publishers.CombineLatest(audioPlayerViewModel.$duration, audioPlayerViewModel.$currentSong)
                    .receive(on: DispatchQueue.main)
                    .sink { (duration, playerState) in
                    if duration == 0 && playerState?.playerState == .playing {
                        isLoadingSong = true
                    } else {
                        isLoadingSong = false
                    }
                }
                    .store(in: &audioPlayerViewModel.cancellables)
            }
        }
    }
}
