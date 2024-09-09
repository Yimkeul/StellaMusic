//
//  ExpandedBottomSheet.swift
//  StelliveMusic
//
//  Created by yimkeul on 9/7/24.
//

import SwiftUI
import Kingfisher
import AVKit
import Combine

struct ExpandedBottomSheet: View {
    @EnvironmentObject var audioPlayerViewModel: AudioPlayerViewModel
    @Binding var expandSheet: Bool
    var animation: Namespace.ID

    @State private var animateContent: Bool = false
    @State private var offsetY: CGFloat = 0

    @State private var value: Double = 0
    @State private var maxValue: Double = 0

    var body: some View {
        if let currentSong = audioPlayerViewModel.currentSong {
            GeometryReader {
                let size = $0.size
                let safeArea = $0.safeAreaInsets
                ZStack {
                    RoundedRectangle(cornerRadius: animateContent ? deviceCornerRadius : 0, style: .continuous)
                        .fill(.ultraThickMaterial)
                        .overlay {
                        KFImage(URL(string: currentSong.songInfo.thumbnail))
                            .resizable()
                            .frame(width: size.width * 1.5, height: size.height * 1.5)
                            .scaledToFill()
                            .edgesIgnoringSafeArea(.all)
                            .blur(radius: 55) // 블러 효과 적용
                        .position(x: size.width / 2, y: size.height / 2)
                            .clipShape(RoundedRectangle(cornerRadius: animateContent ? deviceCornerRadius : 0, style: .continuous))
                            .opacity(animateContent ? 1 : 0)
                    }
                        .overlay(alignment: .top) {
                        MusicPlayerView(expandSheet: $expandSheet, animation: animation)
                            .environmentObject(audioPlayerViewModel)
                            .allowsHitTesting(false)
                            .opacity(animateContent ? 0 : 1)
                    }
                        .matchedGeometryEffect(id: "BGVIEW", in: animation)

                    VStack(spacing: 15) {
                        Capsule()
                            .fill(.gray)
                            .frame(width: 40, height: 5)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : size.height)
                      GeometryReader {
                            let size = $0.size
                            KFImage(URL(string: currentSong.songInfo.thumbnail))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: size.width, height: size.height)
                                .clipShape(RoundedRectangle(cornerRadius: animateContent ? 15 : 5, style: .continuous))

                        }
                            .matchedGeometryEffect(id: "ARTWORK", in: animation)
                            .frame(height: size.width - 50)
                            .padding(.vertical, size.height < 700 ? 10 : 30)

                        PlayerView(size)
                            .offset(y: animateContent ? 0 : size.height)

                    }
                        .padding(.top, safeArea.top + (safeArea.bottom == 0 ? 10 : 0))
                        .padding(.bottom, safeArea.bottom == 0 ? 10 : safeArea.bottom)
                        .padding(.horizontal, 25)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .clipped()
                }
                    .containerShape(Rectangle())
                    .offset(y: offsetY)
                    .gesture(
                    DragGesture()
                        .onChanged({ value in
                        let translationY = value.translation.height
                        offsetY = (translationY > 0 ? translationY : 0)
                    }).onEnded({ value in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            if offsetY > size.height * 0.4 {
                                expandSheet = false
                                animateContent = false
                            } else {
                                offsetY = .zero
                            }
                        }
                    })
                )
                    .ignoresSafeArea(.container, edges: .all)


            }
                .onAppear() {
                withAnimation(.easeInOut(duration: 0.35)) {
                    animateContent = true
                }
            }
        }
    }

    @ViewBuilder
    func PlayerView(_ mainSize: CGSize) -> some View {
        if let currentSong = audioPlayerViewModel.currentSong {
            GeometryReader {
                let size = $0.size
                let spacing = size.height * 0.04
                VStack(spacing: spacing) {
                    VStack(spacing: spacing) {
                        HStack(alignment: .center, spacing: 15) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(currentSong.songInfo.title)
                                    .font(.system(.title2, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                                    .lineLimit(nil) // 줄 수 제한 없음
                                    .multilineTextAlignment(.leading) // 왼쪽 정렬
                                    .fixedSize(horizontal: false, vertical: true)
                                let singer = audioPlayerViewModel.makeSinger(currentSong.songInfo.singer)
                                Text(singer)
                                    .font(.system(.title3, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.gray)
                            }
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Button {

                            } label: {
                                Image(systemName: "heart")
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background {
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .environment(\.colorScheme, .light)
                                }
                            }
                        }
                        // MARK: TimeLine
                        if maxValue != 0 {
                            MusicProgressSlider(value: $value, inRange: .constant(0...maxValue), activeFillColor: Color.white, fillColor: Color.indigo, emptyColor: Color.gray, height: 32) { edit in
                                if !edit {
                                    audioPlayerViewModel.seekToTime(value)
                                }

                            }
                        } else {
                            MusicEmptyProgressSlider(activeFillColor: Color.white, fillColor: Color.indigo, emptyColor: Color.gray, height: 32)
                        }
                    }
                        .frame(height: size.height / 2.5, alignment: .top)
                    HStack(spacing: size.width * 0.1) {

                        Button {

                        } label: {
                            Image(systemName: "shuffle")
                                .font(.title3)

                        }


                        Button {

                        } label: {
                            Image(systemName: "backward.fill")
                                .font(size.height < 300 ? .title3 : .title2)
                        }

                        Button {

                        } label: {
                            Image(systemName: "pause.fill")
                                .font(size.height < 300 ? .largeTitle : .system(size: 50))
                        }

                        Button {

                        } label: {
                            Image(systemName: "forward.fill")
                                .font(size.height < 300 ? .title3 : .title2)
                        }

                        Button {

                        } label: {
                            Image(systemName: "repeat") // toggle repeat.1
                            .font(.title3)

                        }

                    }
                        .foregroundColor(.indigo)
                        .frame(maxHeight: .infinity)
                }
            }

                .onAppear() {
                Publishers.CombineLatest(audioPlayerViewModel.$currentTime, audioPlayerViewModel.$duration)
                    .sink {
                    value = $0
                    maxValue = $1
                }
                    .store(in: &audioPlayerViewModel.cancellables)
            }
        }
    }
}


extension View {
    var deviceCornerRadius: CGFloat {
        let key = "_displayCornerRadius"
        if let screen = (UIApplication.shared.connectedScenes.first as?
            UIWindowScene)?.windows.first?.screen {
            if let conrnerRadius = screen.value(forKey: key) as? CGFloat {
                return conrnerRadius
            }
            return 0
        }
        return 0
    }
}