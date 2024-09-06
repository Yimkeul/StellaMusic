//
//  ArtistListView.swift
//  StelliveMusic
//
//  Created by yimkeul on 9/4/24.
//

import Foundation
import SwiftUI
import Kingfisher

struct ArtistListView: View {
    let items: [SADB] = SADB.db
    @Binding var stellaName: String

    @EnvironmentObject var viewModel: StellaInfoViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {

        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 18) {
                ArtistListALLItem(isSelected: stellaName == "스텔라이브")
                    .onTapGesture {
                    stellaName = "스텔라이브"
                }
                ForEach(viewModel.stellaInfoItems, id: \.self.id) { item in
                    ArtistListItem(item: item, isSelected: stellaName == item.name)
                        .onTapGesture {
                        stellaName = item.name
                    }
                }
            }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
        }
            .padding(.top, 10)
    }
    
    @ViewBuilder
    private func ArtistListALLItem(isSelected: Bool) -> some View {
        VStack(alignment: .center, spacing: 8) {
            Image("Logo")
                .resizable()
                .scaledToFill()
                .frame(width: 65, height: 65)
                .scaleEffect(isSelected ? 1 : 0.9)
                .padding(2)
                .overlay {
                    (colorScheme == .dark && isSelected) ?
                    Circle().stroke(lineWidth: 2)
                        .foregroundColor(Color("\(0)", bundle: nil))
                    : nil
                }
                .shadow(
                color: isSelected ? Color("\(0)", bundle: nil) : Color.clear,
                radius: 3,
                x: 0,
                y: 0
            )
                .animation(.easeIn(duration: 0.2), value: isSelected)

            Text("스텔라이브")
                .font(isSelected ? .system(size: 12, weight: .bold) : .system(size: 11, weight: .bold))
        }
        .environment(\.colorScheme, colorScheme)
    }
    
    
    @ViewBuilder
    private func ArtistListItem(item: StellaInfo, isSelected: Bool) -> some View {
        VStack(alignment: .center, spacing: 8) {
            KFImage(URL(string: item.thumbnail))
                .fade(duration: 0.25)
                .startLoadingBeforeViewAppear(true)
                .resizable()
                .scaledToFill()
                .frame(width: 65, height: 65)
                .clipShape(Circle())
                .padding(2)
                .overlay {
                    (colorScheme == .dark && isSelected) ?
                    Circle().stroke(lineWidth: 2)
                        .foregroundColor(Color("\(item.id)", bundle: nil))
                    : nil
                }
                .shadow(
                color: isSelected ? Color("\(item.id)", bundle: nil) : Color.clear,
                radius: 3,
                x: 0,
                y: 0
            )
                .scaleEffect(isSelected ? 1 : 0.9)
                .animation(.easeIn(duration: 0.2), value: isSelected)

            Text(item.name)
                .font(isSelected ? .system(size: 12, weight: .bold) : .system(size: 11, weight: .bold))

        }
        .environment(\.colorScheme, colorScheme)
    }
}
