//
//  LoginInView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/10.
//

import SwiftUI
import AuthenticationServices
import Combine

struct LoginInView: View {
    @StateObject private var viewModel: LogInViewModel = .init(
        authenticationUseCase: .init(
            authenticationRepository: FirebaseAuthenticationRepository()
        )
    )
    
    /// ログインが完了した時に呼び出されるクロージャ。
    /// AuthDataResultModel を受け取り、MainTabView へ遷移する。
    var onLoginCompleted: (AuthDataResultModel) -> Void = { _ in }

    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(.white), Color.accentColor.opacity(0.3)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // App icon and title
                VStack(spacing: 16) {
                    Image(.appLogo)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.accent)
                    
                    Text("Know Your Code")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                    
                }
                
                Spacer()
                
                // Login buttons
                VStack(spacing: 12) {
                    Button {
                        Task {
                            let authDataResult = await viewModel.signInWithGoogle()
                            if let authDataResult = authDataResult {
                                onLoginCompleted(authDataResult)
                            }
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(.google)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                            
                            Text("Googleでサインイン")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        Task {
                            let authDataResult = await viewModel.signInWithApple()
                            if let authDataResult {
                                onLoginCompleted(authDataResult)
                            }
                        }
                    } label: {
                        SignInWithAppleButtonViewRepresentable(type: .default, style: .black)
                            .frame(height: 54)
                            .cornerRadius(12)
                            .allowsHitTesting(false)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
        }
        .alert(isPresented: $viewModel.showErrorAlert) {
            Alert(title: Text("エラー発生"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    NavigationStack {
        LoginInView()
    }
}

