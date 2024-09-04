//
//  ContentView.swift
//  StelliveMusic
//
//  Created by yimkeul on 9/4/24.
//

import SwiftUI
import SwiftUIIntrospect

struct ContentView: View {
    @State private var selection = 0

    var body: some View {
        
        
        TabView(selection: $selection) {
            HomeView()
                .tabItem {
                    Image(systemName: "music.note.house")
                    Text("홈")
                }
                .tag(0)
            
            PlayListView()
                .tabItem {
                    Image(systemName: "play.square.stack")
                    Text("보관함") }
                .tag(1)
        }.tint(.indigo)


    }
}

#Preview {
    ContentView()
}
