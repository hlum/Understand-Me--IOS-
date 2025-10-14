//
//  HomeworkListViewModel.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/14.
//

import Foundation
import Combine

class HomeworkListViewModel: ObservableObject {
    @Published var homeworks: [HomeworkWithStatus] = []
    
    private var homeworkUseCase: HomeworkUseCase
    private var authenticationUseCase: AuthenticationUseCase
    
    init(
        homeworkUseCase: HomeworkUseCase,
        authenticationUseCase: AuthenticationUseCase
    ) {
        self.homeworkUseCase = homeworkUseCase
        self.authenticationUseCase = authenticationUseCase
    }
    
    @MainActor
    func loadHomeworks() async {
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            print("HomeworkListViewModel.loadHomeworks: ログインしているユーザーがいません。")
            return
        }
        
        do {
            self.homeworks = try await homeworkUseCase.fetchHomeworks(studentID: authDataResult.id)
        } catch {
            print("HomeworkListViewModel.loadHomeworks: 宿題の取得に失敗しました。\(error.localizedDescription)")
        }
    }
}
