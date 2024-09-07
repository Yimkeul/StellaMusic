//
//  ExpandedBottomSheet.swift
//  StelliveMusic
//
//  Created by yimkeul on 9/7/24.
//

import SwiftUI

struct ExpandedBottomSheet: View {
    @Binding var expandSheet: Bool
    var animation: Namespace.ID

    @State private var animateContent: Bool = false
    @State private var offsetY: CGFloat = 0
    var body: some View {
        GeometryReader {
            let size = $0.size
            let safeArea = $0.safeAreaInsets
            ZStack {
                RoundedRectangle(cornerRadius: animateContent ? deviceCornerRadius : 0, style: .continuous)
                    .fill(.ultraThickMaterial)
                    .overlay {
                    Image("Musicthubnail")
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.width * 1.6, height: size.height * 1.6)
                        .edgesIgnoringSafeArea(.all) // 전체 화면 배경 적용
                    .blur(radius: 200) // 블러 효과 적용
                    .position(x: size.width * 0.8, y: size.height * 0.8)
                        .clipShape(RoundedRectangle(cornerRadius: animateContent ? deviceCornerRadius : 0, style: .continuous))
                        .opacity(animateContent ? 1 : 0)
                }
                    .overlay(alignment: .top) {
                    MusicPlayerView(expandSheet: $expandSheet, animation: animation)
                        .allowsHitTesting(false)
                        .opacity(animateContent ? 0 : 1)
                }
                    .matchedGeometryEffect(id: "BGVIEW", in: animation)


                VStack(spacing: 15) {
                    Capsule()
                        .fill(.gray)
                        .frame(width: 40, height: 5)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : size.height)

                    GeometryReader {
                        let size = $0.size

                        Image("Musicthubnail")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipShape(RoundedRectangle(cornerRadius: animateContent ? 15 : 5, style: .continuous))

                    }
                        .matchedGeometryEffect(id: "ARTWORK", in: animation)
                        .frame(height: size.width - 50)
                        .padding(.vertical, size.height < 700 ? 10 : 30)

                    PlayerView(size)
                        .offset(y: animateContent ? 0 : size.height)

                }
                    .padding(.top, safeArea.top + (safeArea.bottom == 0 ? 10 : 0))
                    .padding(.bottom, safeArea.bottom == 0 ? 10 : safeArea.bottom)
                    .padding(.horizontal, 25)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .clipped()
            }
                .containerShape(Rectangle())
                .offset(y: offsetY)
                .gesture(
                DragGesture()
                    .onChanged({ value in
                    let translationY = value.translation.height
                    offsetY = (translationY > 0 ? translationY : 0)
                }).onEnded({ value in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        if offsetY > size.height * 0.4 {
                            expandSheet = false
                            animateContent = false
                        } else {
                            offsetY = .zero
                        }

                    }
                })
            )
                .ignoresSafeArea(.container, edges: .all)
        }
            .onAppear() {
            withAnimation(.easeInOut(duration: 0.35)) {
                animateContent = true
            }
        }
    }



    @ViewBuilder
    func PlayerView(_ mainSize: CGSize) -> some View {
        GeometryReader {
            let size = $0.size
            let spacing = size.height * 0.04
            VStack(spacing: spacing) {
                VStack(spacing: spacing) {
                    HStack(alignment: .center, spacing: 15) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("푸른 산호초")
                                .font(.title3)
                                .fontWeight(.semibold)

                            Text("가수우우")
                                .foregroundStyle(.gray)
                        }
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Button {

                        } label: {
                            Image(systemName: "heart")
                                .foregroundColor(.white)
                                .padding(12)
                                .background {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .environment(\.colorScheme, .light)
                            }
                        }
                    }

                    Capsule()
                        .fill(.ultraThinMaterial)
                        .environment(\.colorScheme, .light)
                        .frame(height: 5)
                        .padding(.top, spacing)

                    // MARK: TimeLine
                    HStack {
                        Text("0:00")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer(minLength: 0)
                        Text("3:00")
                            .font(.caption)
                            .foregroundColor(.gray)

                    }
                }
                    .frame(height: size.height / 2.5, alignment: .top)
                HStack(spacing: size.width * 0.1) {

                    Button {

                    } label: {
                        Image(systemName: "shuffle")
                            .font(.title3)

                    }


                    Button {

                    } label: {
                        Image(systemName: "backward.fill")
                            .font(size.height < 300 ? .title3 : .title2)
                    }

                    Button {

                    } label: {
                        Image(systemName: "pause.fill")
                            .font(size.height < 300 ? .largeTitle : .system(size: 50))
                    }

                    Button {

                    } label: {
                        Image(systemName: "forward.fill")
                            .font(size.height < 300 ? .title3 : .title2)
                    }


                    Button {

                    } label: {
                        Image(systemName: "repeat") // toggle repeat.1
                        .font(.title3)

                    }

                }
                    .foregroundColor(.indigo)
                    .frame(maxHeight: .infinity)
            }
        }
    }
}

#Preview {
    ContentView()
}


extension View {
    var deviceCornerRadius: CGFloat {
        let key = "_displayCornerRadius"
        if let screen = (UIApplication.shared.connectedScenes.first as?
            UIWindowScene)?.windows.first?.screen {
            if let conrnerRadius = screen.value(forKey: key) as? CGFloat {
                return conrnerRadius
            }
            return 0
        }
        return 0
    }
}
