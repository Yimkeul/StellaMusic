//
//  StellaInfoViewModel.swift
//  StelliveMusic
//
//  Created by yimkeul on 9/5/24.
//

import Foundation
import Combine

class StellaInfoViewModel: ObservableObject {
    static let shared = StellaInfoViewModel()
    @Published var stellaInfoItems: [StellaInfo] = []
    private var cancellables = Set<AnyCancellable>()
    
    let client = SupaClient.shared.setClient()
    
    
    func sortData(_ item: [StellaInfo]) -> [StellaInfo] {
        return item.sorted { $0.id < $1.id}
    }
    
    func fetchData() async {
        do {
            let datas: [StellaInfo] = try await client
                .from("StellaInfo")
                .select()
                .execute()
                .value
            
            Just(datas)
                .receive(on: RunLoop.main)
                .sink {
                    self.stellaInfoItems = self.sortData($0)
                }
                .store(in: &cancellables)
        } catch {
            print(error)
        }
    }
}
