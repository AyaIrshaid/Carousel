//
//  CarouselView.swift
//  Carousel
//
//  Created by Aya Irshaid on 25/08/2025.
//

import Combine
import SwiftUI

struct CarouselView: View {
    @State private var currentIndex: Int = 0
    @State private var timerSubscription: AnyCancellable?
    @State private var lastUserScrolledTime: Date?
    
    @GestureState private var dragOffset: CGFloat = 0
    
    let cardWidth: CGFloat = UIScreen.main.bounds.width * 0.5
    let cardHeight: CGFloat = UIScreen.main.bounds.height * 0.3
    let leftDisplacement = (UIScreen.main.bounds.width - (UIScreen.main.bounds.width * 0.5)) / 2.2
    let itemsCount: Int = 5
    let atuoScrollAfter: Double = 2.0
    
    var body: some View {
        VStack(spacing: .zero) {
            VStack(alignment: .center, spacing: .zero) {
                GeometryReader { geometry in
                    ZStack {
                        ForEach(0..<itemsCount, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 15.0)
                                .fill(Color.blue)
                                .frame(width: self.cardWidth, height: self.cardHeight)
                                .offset(x: CGFloat(index - currentIndex) * (geometry.size.width * 0.6) + leftDisplacement + dragOffset)
                                .id(index)
                                .animation(.easeIn, value: dragOffset)
                        }
                    }
                    .gesture(
                        DragGesture()
                            .updating($dragOffset) { value, state, _ in
                                state = value.translation.width
                            }
                            .onEnded { value in
                                userScrolled()
                                let threadshold = geometry.size.width * 0.3
                                if value.translation.width > threadshold {
                                    currentIndex += 1
                                } else if value.translation.width < -threadshold {
                                    currentIndex = min(currentIndex + 1, itemsCount)
                                }
                            }
                    )
                }
            }
            .padding(.horizontal, 16.0)
            pageControler
            .padding(.horizontal, 16.0)
        }
        .frame(height: cardHeight + 24.0)
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
}

extension CarouselView {
    var pageControler: some View {
        HStack {
            ForEach(0..<itemsCount, id: \.self) { index in
                Button {
                    withAnimation(.easeIn) {
                        currentIndex = index
                    }
                } label: {
                    RoundedRectangle(cornerRadius: 100.0)
                        .fill(currentIndex == index ? Color.blue : Color.gray)
                        .frame(width: 16.0, height: 2.0)
                }
            }
        }
    }
}

extension CarouselView {
    private func startTimer() {
        timerSubscription?.cancel()
        timerSubscription = Timer.publish(every: atuoScrollAfter, on: .main, in: .common)
            .autoconnect()
            .subscribe(on: DispatchQueue(label: "AutoscrollThread", qos: .background))
            .receive(on: DispatchQueue.main)
            .sink { _ in
                autoScroll()
            }
    }

    private func autoScroll() {
        guard let lastScrolltime = lastUserScrolledTime else {
            withAnimation(.easeInOut) {
                currentIndex = (currentIndex + 1) % itemsCount
            }
            return
        }
        if Date().timeIntervalSince(lastScrolltime) >= atuoScrollAfter {
            withAnimation(.easeInOut) {
                currentIndex = (currentIndex + 1) % itemsCount
            }
        }
    }

    private func stopTimer() {
        timerSubscription?.cancel()
        timerSubscription = nil
    }

    private func userScrolled() {
        lastUserScrolledTime = Date()
        startTimer()
    }
}

#Preview {
    CarouselView()
}
