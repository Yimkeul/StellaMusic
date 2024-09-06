//
//  SongType.swift
//  StelliveMusic
//
//  Created by yimkeul on 9/4/24.
//

import Foundation

enum SongType: String, Hashable, CaseIterable {
    case all = "ALL"
    case album = "ALBUM"
    case single = "SINGLE"
    case cover = "COVER"
    case others = "OTHERS"
}

extension SongType: Identifiable {
    var id: Self { self }
}

