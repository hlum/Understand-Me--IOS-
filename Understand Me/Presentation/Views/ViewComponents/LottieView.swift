//
//  LottieView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/07.
//

import Foundation
import Lottie
import SwiftUI

struct LottieView: UIViewRepresentable {
    var filename: String
    
    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> some UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView()
        animationView.animation = LottieAnimation.named(filename)
        animationView.contentMode = .scaleAspectFit
        animationView.play()
        animationView.loopMode = .loop
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: UIViewRepresentableContext<LottieView>) {}
}


