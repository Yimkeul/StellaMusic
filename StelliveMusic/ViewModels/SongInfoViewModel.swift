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

    @Published var songInfoItems: [Song] = []
    private var cancellables = Set<AnyCancellable>()

    let client = SupaClient.shared.setClient()
    
    func sortData(_ item: [Song]) -> [Song] {
        return item.sorted {
            if $0.songInfo.registrationDate == $1.songInfo.registrationDate {
                return $0.songInfo.id > $1.songInfo.id
            }
            return $0.songInfo.registrationDate > $1.songInfo.registrationDate
        }
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
                    return songInfos.map { Song(songInfo: $0, playerState: PlayerState.stopped) }
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
