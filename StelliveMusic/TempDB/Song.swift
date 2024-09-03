//
//  Song.swift
//  StelliveMusic
//
//  Created by yimkeul on 9/4/24.
//

import Foundation

struct Song: Hashable {
    let thumbnail: String
    let title: String
    let Singer: [String]
    let songType: String
}

extension Song {
    static let db: [Song] = [
        Song(thumbnail: "Musicthubnail", title: "푸른산호초", Singer: ["아이리 칸나"], songType: "COVER"),
        Song(thumbnail: "Musicthubnail", title: "푸른산호초2", Singer: ["하나코 나나", "아카네 리제"], songType: "COVER"),
        Song(thumbnail: "Musicthubnail", title: "푸른산호초3", Singer: ["아이리 칸나", "하나코 나나"], songType: "SINGLE"),
        Song(thumbnail: "Musicthubnail", title: "푸른산호초4", Singer: ["하나코 나나"], songType: "SINGLE"),
        Song(thumbnail: "Musicthubnail", title: "푸른산호초5", Singer: ["하나코 나나"], songType: "OTHERS"),
        Song(thumbnail: "Musicthubnail", title: "푸른산호초6", Singer: ["하나코 나나"], songType: "OTHERS"),
        Song(thumbnail: "Musicthubnail", title: "푸른산호초7", Singer: ["하나코 나나"], songType: "COVER"),
        Song(thumbnail: "Musicthubnail", title: "푸른산호초8", Singer: ["하나코 나나"], songType: "COVER"),
        Song(thumbnail: "Musicthubnail", title: "푸른산호초9", Singer: ["하나코 나나"], songType: "COVER"),
        Song(thumbnail: "Musicthubnail", title: "푸른산호초10", Singer: ["하나코 나나"], songType: "COVER"),
        Song(thumbnail: "Musicthubnail", title: "푸른산호초11", Singer: ["하나코 나나"], songType: "COVER"),
        Song(thumbnail: "Musicthubnail", title: "푸른산호초12", Singer: ["하나코 나나"], songType: "COVER"),
        
    ]
}



enum SongType: String, Hashable, CaseIterable {
    case all = "ALL"
    case single = "SINGLE"
    case cover = "COVER"
    case others = "OTHERS"
}

extension SongType: Identifiable {
    var id: Self { self }
}
