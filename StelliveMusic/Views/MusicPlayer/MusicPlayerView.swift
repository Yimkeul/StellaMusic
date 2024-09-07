//
//  MusicPlayerView.swift
//  StelliveMusic
//
//  Created by yimkeul on 9/7/24.
//

import SwiftUI

struct MusicPlayerView: View {
    @Binding var expandSheet: Bool
    var animation: Namespace.ID

    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                if !expandSheet {
                    GeometryReader {
                        let size = $0.size
                        Image("Musicthubnail")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipShape(RoundedRectangle(cornerRadius: expandSheet ? 15 : 5, style: .continuous))

                    }
                        .matchedGeometryEffect(id: "ARTWORK", in: animation)
                }
            }.frame(width: 45, height: 45)

            Text("푸른 산호초")
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .padding(.horizontal, 15)
            Spacer(minLength: 0)


            Button {

            } label: {
                Image(systemName: "pause.fill")
                    .font(.title2)
            }
                .foregroundColor(.indigo)

            Button {

            } label: {
                Image(systemName: "forward.fill")
                    .font(.title2)
            }.padding(.leading, 25)
                .foregroundColor(.indigo)
        }
            .padding(.horizontal)
            .padding(.bottom, 5)
            .frame(height: 70)
            .containerShape(Rectangle())
            .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                expandSheet = true
            }
        }
    }
}
