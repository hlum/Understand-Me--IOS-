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
        VStack {
            Text("Understand Me")
                .font(.system(size: 50, weight: .bold))
            
            Button {
                Task {
                    let authDataResult = await viewModel.signInWithGoogle()
                    if let authDataResult = authDataResult {
                        onLoginCompleted(authDataResult)
                    }
                }
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
        .alert(isPresented: $viewModel.showErrorAlert) {
            Alert(title: Text("エラー発生"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("OK")))
        }
        .task {
            let authDataResult = await viewModel.fetchCurrentLoginUser()
            if let authDataResult = authDataResult {
                onLoginCompleted(authDataResult)
            }
        }
    }
}

#Preview {
    NavigationStack {
        LoginInView()
    }
}

