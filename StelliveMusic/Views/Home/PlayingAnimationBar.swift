//
//  PlayingAnimationBar.swift
//  StelliveMusic
//
//  Created by yimkeul on 9/10/24.
//

import SwiftUI

private let numBars = 5
private let spacerWidthRatio: CGFloat = 0.2

private let barWidthScaleFactor = 1 / (CGFloat(numBars) + CGFloat(numBars - 1) * spacerWidthRatio)

struct PlayingAnimationBar: View {

    @State private var animating = false

    var body: some View {
        GeometryReader { (geo: GeometryProxy) in
            let barWidth = geo.size.width * barWidthScaleFactor
            let spacerWidth = barWidth * spacerWidthRatio
            HStack(spacing: spacerWidth) {
                ForEach(0..<numBars, id:\.self) { index in
                    Bar(minHeightFraction: 0.1, maxHeightFraction: 1, completion: animating ? 1 : 0)
                        .fill(Color.white.opacity(0.5))
                        .frame(width: barWidth)
                        .animation(createAnimation(), value: animating)
                }
            }
        }
            .onAppear {
            animating = true
        }
    }

    private func createAnimation() -> Animation {
        Animation
            .easeInOut(duration: 0.8 + Double.random(in: -0.3...0.3))
            .repeatForever(autoreverses: true)
            .delay(Double.random(in: 0...0.75))
    }
}

private struct Bar: Shape {

    private let minHeightFraction: CGFloat
    private let maxHeightFraction: CGFloat
    var animatableData: CGFloat

    init(minHeightFraction: CGFloat, maxHeightFraction: CGFloat, completion: CGFloat) {
        self.minHeightFraction = minHeightFraction
        self.maxHeightFraction = maxHeightFraction
        self.animatableData = completion
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let heightFractionDelta = maxHeightFraction - minHeightFraction
        let heightFraction = minHeightFraction + heightFractionDelta * animatableData

        let rectHeight = rect.height * heightFraction

        let rectOrigin = CGPoint(x: rect.minX, y: rect.maxY - rectHeight)
        let rectSize = CGSize(width: rect.width, height: rectHeight)

        let barRect = CGRect(origin: rectOrigin, size: rectSize)

        path.addRect(barRect)

        return path
    }
}
