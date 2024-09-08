//
//  MusicEmptyProgressSlider.swift
//  StelliveMusic
//
//  Created by yimkeul on 9/9/24.
//

import Foundation
import SwiftUI

struct MusicEmptyProgressSlider: View  {
    let activeFillColor: Color
    let fillColor: Color
    let emptyColor: Color
    let height: CGFloat
    
    var body: some View {
        GeometryReader { bounds in
            ZStack {
                VStack {
                    ZStack(alignment: .center) {
                        Capsule().fill(emptyColor)
                        Capsule()
                            .fill(.clear)
                    }

                    HStack {
                        Text("00:00")
                        Spacer(minLength: 0)
                        Text("-00:00")
                    }
                        .font(.system(.headline, design: .rounded))
                        .monospacedDigit()
                        .foregroundColor(emptyColor)
                }
                    .frame(width: bounds.size.width, alignment: .center)
            }
            .frame(height: height, alignment: .center)
        }
            .environment(\.colorScheme, .light)
    }
}
