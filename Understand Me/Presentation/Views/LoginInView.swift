//
//  LoginInView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/10.
//

import SwiftUI
import AuthenticationServices
import Combine
import AlertToast

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

                    // MARK: - Google Login
                    Button {
                        guard !viewModel.isGoogleLoggingIn else { return }

                        Task {
                            let authDataResult = await viewModel.signInWithGoogle()
                            if let authDataResult {
                                onLoginCompleted(authDataResult)
                            }
                        }
                    } label: {
                        HStack(spacing: 12) {
                            if viewModel.isGoogleLoggingIn {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            } else {
                                Image(.google)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)

                                Text("Googleでサインイン")
                                    .font(.system(size: 17, weight: .semibold))
                            }
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
                    .disabled(viewModel.isGoogleLoggingIn)

                    // MARK: - Apple Login
                    Button {
                        guard !viewModel.isAppleLoggingIn else { return }

                        Task {
                            let authDataResult = await viewModel.signInWithApple()
                            if let authDataResult {
                                onLoginCompleted(authDataResult)
                            }
                        }
                    } label: {
                        ZStack {
                            SignInWithAppleButtonViewRepresentable(
                                type: .default,
                                style: .black
                            )
                            .cornerRadius(12)
                            .allowsHitTesting(false)
                        }
                        .frame(height: 54)
                    }
                    .disabled(viewModel.isAppleLoggingIn)
                }

                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
        }
        .toast(isPresenting: $viewModel.showErrorAlert) {
            AlertToast(
                displayMode: .hud,
                type: .error(.red),
                title: "ログインエラー",
                subTitle: viewModel.errorMessage
            )
        }
    }
}

#Preview {
    NavigationStack {
        LoginInView()
    }
}

