//
//  ArtistListView.swift
//  StelliveMusic
//
//  Created by yimkeul on 9/4/24.
//

import Foundation
import SwiftUI

struct ArtistListView: View {
    let items: [SADB] = SADB.db
    @Binding var stellaName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("스텔라")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: 18) {
                    ForEach(items, id: \.self) { item in
                        ArtistListItem(item: item, isSelected: stellaName == item.fullName)
                            .onTapGesture {
                            print(item.fullName)
                            stellaName = item.fullName
                        }
                    }
                }
            }
                .frame(height: 100)
        }
            .padding(.leading, 16)
            .padding(.top, 16)
    }


    @ViewBuilder
    private func ArtistListItem(item: SADB, isSelected: Bool) -> some View {
        VStack(alignment: .center, spacing: 0) {
            
            Image(item.thumbnail)
                .scaleEffect(isSelected ? 1 : 0.9)
                .padding(.bottom, 8)
                

            ForEach(item.name, id: \.self) { name in
                Text(name)
                    .font(isSelected ? .system(size: 12, weight: .bold) : .system(size: 11, weight: .bold))
                    .foregroundStyle(isSelected ? .red : .white)
            }
        }
    }
}
