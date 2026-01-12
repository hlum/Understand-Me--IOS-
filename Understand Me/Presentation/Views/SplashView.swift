//
//  SplashView.swift
//  Understand Me
//
//  Created by cmStudent on 2026/01/11.
//

import SwiftUI

struct SplashView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color(.white)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(.appLogo)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.accent)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .animation(
                        .easeInOut(duration: 4).repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                
                Text("Know Your Code")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(.black)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    SplashView()
}
