//
//  SignInWithAppleButtonViewRepresentable.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/10.
//

import SwiftUI
import AuthenticationServices


struct SignInWithAppleButtonViewRepresentable: UIViewRepresentable {
    
    var type: ASAuthorizationAppleIDButton.ButtonType
    var style: ASAuthorizationAppleIDButton.Style
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        ASAuthorizationAppleIDButton(type: type, style: style)
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
        
    }
}
