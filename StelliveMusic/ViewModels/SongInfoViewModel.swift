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

    @Published var songInfoItems: [Songs] = []
    private var cancellables = Set<AnyCancellable>()

    let client = SupaClient.shared.setClient()
    
    func sortData(_ item: [Songs]) -> [Songs] {
        return item.sorted { $0.songInfo.id < $1.songInfo.id }
    }

    func fetchData() async {
        do {
            let datas: [SongInfo] = try await client
                .from("SongInfo")
                .select()
                .execute()
                .value

            Just(datas)
                .map { songInfos in
                return songInfos.map { Songs(songInfo: $0, isPlay: false) }
            }
                .receive(on: RunLoop.main)
                .sink {
                    self.songInfoItems = self.sortData($0)
            }.store(in: &cancellables)
        } catch {
            print(error)
        }
    }

}
