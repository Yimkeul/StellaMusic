//
//  SongListView.swift
//  StelliveMusic
//
//  Created by yimkeul on 9/4/24.
//

import Foundation
import SwiftUI

struct SongListView: View {
    @Binding var selectedSongType: SongType
    @Binding var stellaName: String

    let songDB: [Song] = Song.db

    var filterDB: [Song] {
        let filteredSongs = stellaName == SADB.db.first!.fullName
            ? (
            selectedSongType == .all ? songDB:
                songDB.filter { $0.songType == selectedSongType.rawValue })
        : {
            let temp = songDB.filter { $0.Singer.contains(stellaName) }
            return selectedSongType == .all
                ? temp
            : temp.filter { $0.songType == selectedSongType.rawValue }
        }()

        return filteredSongs
    }
    
//    var filterDB: [Song] {
//        let filteredSongs: [Song]
//        if stellaName == SADB.db.first!.fullName {
//            filteredSongs = selectedSongType == .all ? songDB : songDB.filter { $0.songType == selectedSongType.rawValue }
//        } else {
//            let temp = songDB.filter { $0.Singer.contains(stellaName) }
//            filteredSongs = selectedSongType == .all ? temp : temp.filter { $0.songType == selectedSongType.rawValue }
//        }
//        return filteredSongs
//    }





    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 8) {
                if filterDB.isEmpty {
                    Text("노래 없음")
                } else {
                    ForEach(filterDB, id: \.self) { item in
                        let singer = makeSinger(item.Singer)
                        SongListItem(item: item, singer: singer)
                    }
                }
                
            }
        }
            .padding(16)
    }



    private func makeSinger(_ singers: [String]) -> String {
        return singers.joined(separator: " & ")
    }



    @ViewBuilder
    private func SongListItem(item: Song, singer: String) -> some View {
        VStack(spacing: 16) {
            HStack(alignment: .center) {
                Image(item.thumbnail)
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
//                                .foregroundColor(.white)

                            Text(singer)
                                .font(.system(size: 14, weight: .semibold))
//                                .foregroundColor(.white)
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
