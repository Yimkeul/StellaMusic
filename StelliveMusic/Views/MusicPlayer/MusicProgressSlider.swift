//
//  MusicProgressSlider.swift
//  StelliveMusic
//
//  Created by yimkeul on 9/8/24.
//

import SwiftUI

struct MusicProgressSlider<T: BinaryFloatingPoint>: View {
    @Binding var value: T
    @Binding var inRange: ClosedRange<T>
    let activeFillColor: Color
    let fillColor: Color
    let emptyColor: Color
    let height: CGFloat
    let onEditingChanged: (Bool) -> Void

    @State private var localRealProgress: T = 0
    @State private var localTempProgress: T = 0
    @GestureState private var isActive: Bool = false // 드래그 상태를 추적

    var body: some View {
        GeometryReader { bounds in
            ZStack {
                VStack {
                    ZStack(alignment: .center) {
                        Capsule().fill(emptyColor)
                        Capsule()
                            .fill(isActive ? activeFillColor : fillColor)
                            .mask({
                            HStack {
                                Rectangle()
                                    .frame(width: max(bounds.size.width * CGFloat(localRealProgress + localTempProgress), 0), alignment: .leading)
                                Spacer(minLength: 0)
                            }
                        })
                    }

                    HStack {
                        // 현재 시간을 value로 설정
                        Text(value.asTimeString(style: .positional))
                        Spacer(minLength: 0)
                        // 남은 시간을 표시
                        Text("-" + ((inRange.upperBound - value).asTimeString(style: .positional)))
                    }
                        .font(.system(.headline, design: .rounded))
                        .monospacedDigit()
                        .foregroundColor(isActive ? fillColor : emptyColor)
                }
                    .frame(width: bounds.size.width, alignment: .center)
            }
            // 드래그 상태에 따른 높이 변화
            .frame(height: isActive ? height * 1.25 : height, alignment: .center)
                .animation(animation, value: isActive) // 드래그 상태에 따른 애니메이션 적용
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .updating($isActive) { _, state, _ in
                    state = true
                    onEditingChanged(true) // 슬라이더가 조작 중일 때 true로 설정
                }
                    .onChanged { gesture in
                    // 슬라이더 값과 위치를 실시간으로 업데이트
                    let newProgress = T(gesture.translation.width / bounds.size.width)
                    localTempProgress = newProgress // 실시간으로 슬라이더 이동 반영
                    let clampedProgress = max(min(localRealProgress + localTempProgress, 1), 0)
                    value = inRange.lowerBound + (clampedProgress * (inRange.upperBound - inRange.lowerBound))
                }
                    .onEnded { _ in
                    // 드래그가 끝났을 때 최종 위치 고정 및 슬라이더 해제
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { // 애니메이션 적용
                        localRealProgress = getPrgPercentage(value)
                        localTempProgress = 0 // 드래그가 끝난 후 슬라이더 위치 고정
                    }
                    onEditingChanged(false) // 슬라이더 조작이 끝났음을 알림
                }
            )
                .onAppear {
                localRealProgress = getPrgPercentage(value)
            }
                .onChange(of: value) { newValue in
                // 슬라이더가 조작 중이지 않을 때만 업데이트
                if !isActive {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { // 애니메이션 적용
                        localRealProgress = getPrgPercentage(newValue)
                    }
                }
            }
        }
            .environment(\.colorScheme, .light)
    }

    // 애니메이션 설정: 드래그 중일 때는 부드럽게 확장되고, 드래그가 끝나면 원래 크기로 돌아감
    private var animation: Animation {
            .spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.5) // 자연스러운 애니메이션
    }

    // 현재 진행 비율을 계산
    private func getPrgPercentage(_ value: T) -> T {
        let range = inRange.upperBound - inRange.lowerBound
        let correctedStartValue = value - inRange.lowerBound
        return correctedStartValue / range
    }
}




