//
//  ContentView.swift
//  StelliveMusic
//
//  Created by yimkeul on 9/4/24.
//

import SwiftUI
import SwiftUIIntrospect

struct ContentView: View {
    @State private var selection = 0
    @State private var expandSheet: Bool = false
    @Namespace private var animation

    @StateObject private var stellaInfoViewModel: StellaInfoViewModel = StellaInfoViewModel()
    @StateObject private var songInfoViewModel: SongInfoViewModel = SongInfoViewModel()
    @StateObject private var audioPlayerViewModel: AudioPlayerViewModel = AudioPlayerViewModel()

    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .environmentObject(stellaInfoViewModel)
                .environmentObject(songInfoViewModel)
                .environmentObject(audioPlayerViewModel)
                .padding(.bottom, audioPlayerViewModel.currentSong != nil ? 70 : 0)
                .tabItem {
                Image(systemName: "music.note.house")
                Text("홈")
            }

                .tag(0)

            PlayListView()
                .environmentObject(audioPlayerViewModel)
                .padding(.bottom, audioPlayerViewModel.currentSong != nil ? 70 : 0)
                .tabItem {
                Image(systemName: "play.square.stack")
                Text("보관함") }
                .tag(1)
        }
            .tint(.indigo)

            .safeAreaInset(edge: .bottom, content: {
            audioPlayerViewModel.currentSong != nil ? CustomBottomSheet() : nil
        })
            .overlay {
            if expandSheet {
                ExpandedBottomSheet(expandSheet: $expandSheet, animation: animation)
                    .environmentObject(audioPlayerViewModel)
                    .transition(.asymmetric(insertion: .identity, removal: .offset(y: -5)))
            }
        }
            .onAppear {
            Task {
                await stellaInfoViewModel
                    .fetchData()
                await songInfoViewModel.fetchData()
            }

        }

    }


    @ViewBuilder
    func CustomBottomSheet() -> some View {
        ZStack {
            if expandSheet {
                Rectangle()
                    .fill(.clear)
            } else {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .overlay {
                    MusicPlayerView(expandSheet: $expandSheet, animation: animation)
                            .environmentObject(audioPlayerViewModel)
                }
                    .matchedGeometryEffect(id: "BGVIEW", in: animation)
            }
        }
            .frame(height: 70)
            .overlay(alignment: .bottom, content: {
            Rectangle()
                .fill(.gray.opacity(0.3))
                .frame(height: 1)
        })
            .offset(y: -49)
    }
}






#Preview {
    ContentView()
}
