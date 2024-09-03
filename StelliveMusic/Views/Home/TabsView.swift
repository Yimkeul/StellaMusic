//
//  TabsView.swift
//  StelliveMusic
//
//  Created by yimkeul on 9/4/24.
//

import SwiftUI


struct TabsView: View {
    @Binding var selectedSongType: SongType

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .top, spacing: 10) {
                ForEach(SongType.allCases) { type in
                    TabButton(type: type, isSelected: selectedSongType == type)
                        .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedSongType = type
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }

    @ViewBuilder
    private func TabButton(type: SongType, isSelected: Bool) -> some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .background(
                isSelected ? Color.white:
                    Color(red: 0.12, green: 0.12, blue: 0.12))
                .cornerRadius(10)
            
            Text(type.rawValue)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isSelected ? Color.black : Color.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
        }
    }
}
