//
//  ProfileViewModel.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/11.
//
import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published var userData: UserData?
    @Published var results: [Result] = []
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    
    private let authenticationUseCase: AuthenticationUseCase
    private let userDataUseCase: UserDataUseCase
    private let resultUseCase: ResultUseCase
    
    init(
        authenticationUseCase: AuthenticationUseCase,
        userDataUseCase: UserDataUseCase,
        resultUseCase: ResultUseCase
    ) {
        self.authenticationUseCase = authenticationUseCase
        self.userDataUseCase = userDataUseCase
        self.resultUseCase = resultUseCase
    }
    
    
    
    
    @MainActor
    func loadUserData() async {
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            print("AuthDataResultを取得できません。")
            return
        }
        
        do {
            self.userData = try await userDataUseCase.fetchUserData(userID: authDataResult.id)
        } catch {
            // TODO: UserにAlertで知らせる
            print("ProfileViewModel.loadUserData: UserDataの取得に失敗しました。")
        }
    }

    
    
    @MainActor
    func loadResults(year: Int) async {
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            print("AuthDataResultを取得できません。")
            return
        }
        
        do {
            self.results = try await resultUseCase.fetchResults(userID: authDataResult.id, year: year)
        } catch {
            // TODO: UserにAlertで知らせる
            print("ProfileViewModel.loadResults: Resultの取得に失敗しました。")
        }
    }
    
    
    func signOut() {
        do {
            try authenticationUseCase.signOut()
        } catch {
            showErrorAlert(message: errorMessage.description)
        }
    }
    
    @MainActor
    private func showErrorAlert(message: String) {
        self.errorMessage = message
        self.showError = true
    }
}
