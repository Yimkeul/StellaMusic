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
            VStack {
                if selection == 0 {
                    HomeView()
                } else {
                    PlayListView()
                }
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {selection = 0}, label: {
                        Text("홈")
                    })
                    Spacer()
                    Divider().frame(height: 16)
                    Spacer()
                    Button(action: {selection = 1}, label: {
                        Text("보관함")
                    })
                    Spacer()
                }
                .padding(.vertical, 8)
            }
    }
}

#Preview {
    ContentView()
}
