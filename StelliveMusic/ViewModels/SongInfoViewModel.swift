//
//  SongInfoViewModel.swift
//  StelliveMusic
//
//  Created by yimkeul on 9/6/24.
//

import Foundation
import Combine

class SongInfoViewModel: ObservableObject {
    static let shared = SongInfoViewModel()

    @Published var songInfoItems: [SongInfo] = []
    private var cancellables = Set<AnyCancellable>()

    let client = SupaClient.shared.setClient()


    func fetchData() async {
        do {
            let datas: [SongInfo] = try await client
                .from("SongInfo")
                .select()
                .execute()
                .value

            Just(datas)
                .receive(on: RunLoop.main)
                .sink {
                self.songInfoItems = $0
                print("SongInfo : \($0)")
            }.store(in: &cancellables)
        } catch {
            print(error)
        }
    }

}
