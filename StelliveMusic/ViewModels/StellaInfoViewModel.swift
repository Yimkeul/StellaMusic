//
//  StellaInfoViewModel.swift
//  StelliveMusic
//
//  Created by yimkeul on 9/5/24.
//

import Foundation

class StellaInfoViewModel: ObservableObject {
    static let shared = StellaInfoViewModel()
    @Published var stellaInfoItems: [StellaInfo] = []
    
    let client = SupaClient.shared.setClient()

    
    func fetchData() async  {
        do {
            let datas: [StellaInfo] = try await client
                .from("StellaInfo")
                .select()
                .execute()
                .value
            DispatchQueue.main.async {
                self.stellaInfoItems = datas
            }
        } catch {
            print(error)
        }
    }
    
//    func getData() async -> [StellaInfo] {
//        do {
//            let datas: [StellaInfo] = try await client
//                .from("StellaInfo")
//                .select()
//                .execute()
//                .value
//            return datas
//        } catch {
//            print(error)
//            return []
//        }
//    }
}
