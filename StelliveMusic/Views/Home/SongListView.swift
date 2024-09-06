//
//  SongListView.swift
//  StelliveMusic
//
//  Created by yimkeul on 9/4/24.
//

import Foundation
import SwiftUI
import Kingfisher

struct SongListView: View {
    @EnvironmentObject var viewModel: SongInfoViewModel

    @Binding var selectedSongType: SongType
    @Binding var stellaName: String

    var filterDB: [SongInfo] {
        var filteredSongs: [SongInfo]

        if stellaName == "스텔라이브" {
            filteredSongs = selectedSongType == .all ? viewModel.songInfoItems : viewModel.songInfoItems.filter {
                $0.songType == selectedSongType.rawValue
            }
        } else {
            let temp = viewModel.songInfoItems.filter { $0.singer.contains(stellaName) }
            return selectedSongType == .all ? temp : temp.filter { $0.songType == selectedSongType.rawValue }

        }
        return filteredSongs
    }


    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 8) {
                ForEach(filterDB, id: \.self) { item in
                    let singer = makeSinger(item.singer)
                    SongListItem(item: item, singer: singer)
                }
            }
        }
            .padding(16)
    }



    private func makeSinger(_ singers: [String]) -> String {
        return singers.joined(separator: " & ")
    }



    @ViewBuilder
    private func SongListItem(item: SongInfo, singer: String) -> some View {
        VStack(spacing: 16) {
            HStack(alignment: .center) {
                KFImage(URL(string: item.thumbnail))
                    .resizable()
                    .frame(width: 70, height: 50)
                    .cornerRadius(4)
                    .scaledToFill()
                    .padding(.trailing, 8)

                VStack {
                    HStack {
                        VStack (alignment: .leading, spacing: 8) {
                            Text(item.title)
                                .font(.system(size: 18, weight: .bold))

                            Text(singer)
                                .font(.system(size: 14, weight: .semibold))
                        }

                        Spacer()
                        Button(action: /*@START_MENU_TOKEN@*/ { }/*@END_MENU_TOKEN@*/, label: {
                            Image(systemName: "heart.fill")
                        })
                    }
                    Spacer()
                    Divider()
                }
            }

        }
    }
}
