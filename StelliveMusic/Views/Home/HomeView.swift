//
//  HomeView.swift
//  StelliveMusic
//
//  Created by yimkeul on 9/4/24.
//

import SwiftUI
import SwiftUIIntrospect

struct HomeView: View {
    @State private var selectedSongType: SongType = .all
    @State private var stellaName: String = SADB.db.first!.fullName

    var body: some View {

        ScrollView(showsIndicators: false) {
            Title()
            ArtistListView(stellaName: $stellaName)
            TabsView(selectedSongType: $selectedSongType)
            SongListView(selectedSongType: $selectedSongType, stellaName: $stellaName)
        }
        .background(Color.teal)
        .onAppear {
        UIScrollView.appearance().bounces = false
    }
        .onDisappear {
        UIScrollView.appearance().bounces = true
    }
}



@ViewBuilder
private func Title() -> some View {
    HStack {
        Text("스텔라이브 뮤직")
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(.white)
        Spacer()
    }.padding(.horizontal, 16)
}

}


#Preview {
    HomeView()
}
