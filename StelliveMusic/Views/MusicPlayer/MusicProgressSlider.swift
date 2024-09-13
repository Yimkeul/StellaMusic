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
            ZStack(alignment: .top) {
                VStack {
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(emptyColor)
                        // 색을 칠하는 캡슐
                        Capsule()
                            .fill(isActive ? activeFillColor : fillColor)
                            .overlay {
                            Capsule().stroke(activeFillColor, lineWidth: 0.5)
                        }
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
                        .foregroundColor(emptyColor)
                }
                    .frame(width: bounds.size.width)
            }
                .frame(height: isActive ? height * 1.5 : height)
                .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .updating($isActive) { _, state, _ in
                    state = true
                    onEditingChanged(true)
                }
                    .onChanged { gesture in
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        let newProgress = T(gesture.translation.width / bounds.size.width)
                        localTempProgress = newProgress
                    }
                    let clampedProgress = max(min(localRealProgress + localTempProgress, 1), 0)
                    value = inRange.lowerBound + (clampedProgress * (inRange.upperBound - inRange.lowerBound))
                }
                    .onEnded { _ in
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { localRealProgress = getPrgPercentage(value)
                        localTempProgress = 0
                    }
                    onEditingChanged(false)
                }
            )
                .onAppear {
                localRealProgress = getPrgPercentage(value)
            }
                .onChange(of: value) { newValue in
                if !isActive {
                    withAnimation(.spring(response: 0.5, dampingFraction: 1))
                    {
                        localRealProgress = getPrgPercentage(newValue)
                    }
                }
            }
        }
            .environment(\.colorScheme, .light)
    }
    
    private func getPrgPercentage(_ value: T) -> T {
        let range = inRange.upperBound - inRange.lowerBound
        let correctedStartValue = value - inRange.lowerBound
        return correctedStartValue / range
    }
}




