//
//  SupaClient.swift
//  StelliveMusic
//
//  Created by yimkeul on 9/5/24.
//

import Foundation
import Supabase

class SupaClient: ObservableObject {

    static var shared = SupaClient()

    func getKey() -> String {
        guard let key = Bundle.main.supaApiKey else {
            print("Supabase Key 로드 실패")
            return ""
        }
        return key
    }

    func getUrl() -> String {
        guard let region = Bundle.main.supaURL else {
            print("Supabase Region 로드 실패")
            return ""
        }
        return region
    }

    func setClient() -> SupabaseClient {
        let url = URL(string:getUrl())!
        let key = getKey()
        let client = SupabaseClient(supabaseURL: url, supabaseKey: key)
        return client
    }
}


extension Bundle {
    var supaApiKey: String? {
        guard let file = self.path(forResource: "SupabaseInfo", ofType: "plist") else { return nil}
        guard let resource = NSDictionary(contentsOfFile: file) else { return nil }
        guard let key = resource["API_KEY"] as? String else { fatalError("SupabaseInfo.plist에 API_KEY 설정을 해주세요.")}
        return key
    }

    var supaURL: String? {
        guard let file = self.path(forResource: "SupabaseInfo", ofType: "plist") else { return nil}

        guard let resource = NSDictionary(contentsOfFile: file) else { return nil }
        guard let key = resource["URL"] as? String else { fatalError("SupabaseInfo.plist에 URL 설정을 해주세요.")}
        return key
    }
}
