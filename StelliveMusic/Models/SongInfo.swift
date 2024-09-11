//
//  SongInfo.swift
//  StelliveMusic
//
//  Created by yimkeul on 9/6/24.
//

import Foundation

struct SongInfo: Codable, Hashable {
    var id: Int
    var thumbnail: String
    var title: String
    var singer: [String]
    var songType: String
    var registrationDate: String
    var lyrics: [String]?
    var youtubeLink: String
    var mp3Link: String
    
    enum CodingKeys: String, CodingKey {
     case id, thumbnail, title, singer, songType, registrationDate, lyrics, youtubeLink, mp3Link
    }
}
