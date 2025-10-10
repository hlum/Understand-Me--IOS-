//
//  LoginInView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/10.
//

import SwiftUI
import AuthenticationServices
import GoogleSignIn
import GoogleSignInSwift

struct SignInWithAppleButtonViewRepresentable: UIViewRepresentable {
    
    var type: ASAuthorizationAppleIDButton.ButtonType
    var style: ASAuthorizationAppleIDButton.Style
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        ASAuthorizationAppleIDButton(type: type, style: style)
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
        
    }
}

struct LoginInView: View {
    var body: some View {
        VStack {
            Text("Understand Me")
                .font(.system(size: 50, weight: .bold))
            
            Button {
                
            } label: {
                HStack {
                    Image(.google)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20)
                    
                    Text("Googleでサインイン")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .frame(height: 55)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                )

            }
            .padding(.top, 30)

            
            Button {
                
            } label: {
                SignInWithAppleButtonViewRepresentable(type: .default, style: .black)
                    .frame(height: 55)
                    .cornerRadius(10)
                    .allowsHitTesting(false)
            }
        }
        .padding()
    }
}

#Preview {
    LoginInView()
}
