//
//  StellaInfo.swift
//  StelliveMusic
//
//  Created by yimkeul on 9/5/24.
//

import Foundation
import Supabase


struct StellaInfo: Codable, Hashable {
    var id: Int
    var thumbnail: String
    var name: String
    var group: String
    enum CodingKeys: String, CodingKey {
        case id, thumbnail, name, group
    }
}

