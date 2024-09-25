//
//  HomeView.swift
//  StelliveMusic
//
//  Created by yimkeul on 9/4/24.
//

import SwiftUI
import SwiftUIIntrospect

struct HomeView: View {
    @EnvironmentObject var audioViewModel: AudioPlayerViewModel
    @State private var selectedSongType: SongType = .all
    @State private var stellaName: String = "스텔라이브"

    var body: some View {

        ScrollView(showsIndicators: false) {
            Title()
            ArtistListView(stellaName: $stellaName)
            TabsView(selectedSongType: $selectedSongType)
            PlayButtonArea()
            SongListView(selectedSongType: $selectedSongType, stellaName: $stellaName)
            Divider()
            Text("STELLA MUSIC은 스텔라이브 공식 앱이 아님을 밝히며, 팬이 제작한 앱입니다.\nSTELLIVE MUSIC에서 제공하는 모든 콘텐츠의 대한 저작권은 스텔라이브(STELLIVE) 및 강지(정도현)에게 귀속됩니다.\nSTELLA MUSIC은 어떠한 개인의 수익 창출을 하지 않음을 밝합니다.")
                .padding(.horizontal, 16)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.primary.opacity(0.5))
            
        }
            .padding(.top, 1)
            .padding(.bottom, 1)
            .onAppear {
            UIScrollView.appearance().bounces = false
        }
            .onDisappear {
            UIScrollView.appearance().bounces = true
        }
    }



    @ViewBuilder
    private func Title() -> some View {
        HStack(alignment: .center) {
//            Image("Logo")
//                .resizable()
//                .frame(width: 35, height: 35)
            Text("STELLA MUSIC")
                .font(.title)
                .fontWeight(.bold)
            Spacer()
        }.padding(.horizontal, 16)
    }

    @ViewBuilder
    private func PlayButtonArea() -> some View {
        HStack(spacing: 16) {
            Spacer()

            Button {
                audioViewModel.playAllAudio()
            } label: {
                PlayButton(.all)
            }

            Button {
                audioViewModel.playAllShuffleAudio()
            } label: {
                PlayButton(.random)
            }

            Spacer()
        }.padding(.vertical, 16)
    }

    enum PlayButtonType: String {
        case all = "재생"
        case random = "랜덤재생"
    }

    @Environment(\.colorScheme) var colorScheme
    @ViewBuilder
    private func PlayButton(_ type: PlayButtonType) -> some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .background(colorScheme == .dark ? Color.white : Color.black)
                .cornerRadius(10)

            HStack(spacing: 8) {
                Image(systemName: type == .all ? "play.fill" : "shuffle")
                Text(type.rawValue)
                    .font(.system(size: 14, weight: .semibold))
                    .padding(.vertical, 8)
                    .padding(.trailing, 4)
            }.foregroundColor(colorScheme == .dark ? Color.black : Color.white)
        }
            .environment(\.colorScheme, colorScheme)
    }
}
