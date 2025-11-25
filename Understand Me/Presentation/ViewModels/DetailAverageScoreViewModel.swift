//
//  DetailAverageScoreViewModel.swift
//  Understand Me
//
//  Created by cmStudent on 2025/11/25.
//
import Foundation
import Combine

class DetailAverageScoreViewModel: ObservableObject {
    @Published var averageScoresPerClass: [AverageScorePerClass] = []
    
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private let averageScoreUseCase: AverageScoreUseCase
    private let authenticationUseCase: AuthenticationUseCase
    
    init(averageScoreUseCase: AverageScoreUseCase, authenticationUseCase: AuthenticationUseCase) {
        self.averageScoreUseCase = averageScoreUseCase
        self.authenticationUseCase = authenticationUseCase
    }
    
    
    @MainActor
    func loadAverageScoresPerClass() async {
        guard let authData = await authenticationUseCase.fetchCurrentUser() else  {
            showAlert(message: "予期せぬエラーが発生しました。もう一度やり直してください。")
            return
        }
        
        
        do {
            self.averageScoresPerClass = try await averageScoreUseCase.fetch(userID: authData.id)
        } catch let error as UseCaseErrors {
            showAlert(message: error.localizedDescription)
        } catch {
            showAlert(message: "予期せぬエラーが発生しました。もう一度やり直してください。")
        }
    }
    
    
    @MainActor
    private func showAlert(message: String) {
        self.alertMessage = message
        self.showAlert = true
    }
}
