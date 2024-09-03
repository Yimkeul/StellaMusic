//
//  ArtistList.swift
//  StelliveMusic
//
//  Created by yimkeul on 9/4/24.
//

import Foundation

struct SADB: Hashable {
    let thumbnail: String
    let name: [String]
    let group: String
    var fullName: String

    init(thumbnail: String, name: [String], group: String = "") {
        self.thumbnail = thumbnail
        self.name = name
        self.group = group
        self.fullName = name.joined(separator: " ")
    }
}



extension SADB {
    static let db: [SADB] = [
        SADB(thumbnail: "Logo", name: ["스텔라이브"]),
        SADB(thumbnail: "Logo", name: ["아이리 칸나"]),
        SADB(thumbnail: "Logo", name: ["아야츠노 유니"]),
        SADB(thumbnail: "Logo", name: ["AYATSUNO", "YUNI"]),
        SADB(thumbnail: "Logo", name: ["시라유키 히나"]),
        SADB(thumbnail: "Logo", name: ["네네코 마시로"]),
        SADB(thumbnail: "Logo", name: ["아카네 리제"]),
        SADB(thumbnail: "Logo", name: ["아라하시 타비"]),
        SADB(thumbnail: "Logo", name: ["텐코 시부키"]),
        SADB(thumbnail: "Logo", name: ["아오쿠모 린"]),
        SADB(thumbnail: "Logo", name: ["하나코 나나"]),
        SADB(thumbnail: "Logo", name: ["유즈하 리코"])
    ]
}
