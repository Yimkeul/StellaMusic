//
//  HomeView.swift
//  StelliveMusic
//
//  Created by yimkeul on 9/4/24.
//

import SwiftUI
import SwiftUIIntrospect

struct HomeView: View {
    @State private var selectedSongType: SongType = .all
    @State private var stellaName: String = "스텔라이브"

    var body: some View {

        ScrollView(showsIndicators: false) {
            Title()
            ArtistListView(stellaName: $stellaName)
            TabsView(selectedSongType: $selectedSongType)
            PlayButtonArea()
            SongListView(selectedSongType: $selectedSongType, stellaName: $stellaName)
        }
            .padding(.top, 1)
            .onAppear {
            UIScrollView.appearance().bounces = false
        }
            .onDisappear {
            UIScrollView.appearance().bounces = true
        }
    }



    @ViewBuilder
    private func Title() -> some View {
        HStack {
            Text("스텔라이브 뮤직")
                .font(.title)
                .fontWeight(.bold)
            Spacer()
        }.padding(.horizontal, 16)
    }

    @ViewBuilder
    private func PlayButtonArea() -> some View {
        HStack(spacing: 16) {
            Spacer()
            Button(action: { }
                   , label: {
                       PlayButton(.all)
                   })
            Button(action: { }
                   , label: {
                       PlayButton(.random)
                   })

            Spacer()
        }.padding(.vertical, 16)
    }

    enum PlayButtonType: String {
        case all = "전체재생"
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


#Preview {
    HomeView()
}
