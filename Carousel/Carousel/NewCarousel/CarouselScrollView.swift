//
//  CarouselScrollView.swift
//  Carousel
//
//  Created by Aya Irshaid on 04/09/2025.
//

import SwiftUI

struct CarouselScrollView: View {
    let items = Array(0..<10)
    let cardWidth: CGFloat = 200
    let cardSpacing: CGFloat = 20

    var body: some View {
        GeometryReader { outerGeo in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: cardSpacing) {
                    ForEach(items, id: \.self) { index in
                        GeometryReader { geo in
                            let midX = geo.frame(in: .global).midX
                            let distance = abs(midX - outerGeo.size.width / 2)
                            let scale = max(1 - (distance / outerGeo.size.width), 0.8)

                            CardView(index: index)
                                .scaleEffect(scale)
                                .animation(.easeOut(duration: 0.3), value: scale)
                        }
                        .frame(width: cardWidth, height: 300)
                    }
                }
                .padding(.horizontal, (outerGeo.size.width - cardWidth) / 2)
            }
        }
    }
}

struct CardView: View {
    let index: Int

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.blue)
            Text("Card \(index)")
                .font(.title)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    CarouselScrollView()
}
