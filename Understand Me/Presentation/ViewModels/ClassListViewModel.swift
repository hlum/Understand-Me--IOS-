//
//  ClassListViewModel.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/13.
//

import Foundation
import Combine

class ClassListViewModel: ObservableObject {
    @Published var classes: [Class] = []
    
    private let classUseCase: ClassUseCase
    private let authenticationUseCase: AuthenticationUseCase
    
    
    
    init(classUseCase: ClassUseCase, authenticationUseCase: AuthenticationUseCase) {
        self.classUseCase = classUseCase
        self.authenticationUseCase = authenticationUseCase
    }
    
    
    
    @MainActor
    func loadClasses() async {
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            print("ClassListViewModel.loadClasses: ログイン中のユーザのデータ取得に失敗したので、クラスの取得ができません。")
            return
        }
        do {
            classes = try await classUseCase.fetchClassList(studentID: authDataResult.id)
        } catch {
            print("ClassListViewModel.loadClasses: クラスの取得に失敗しました。詳細：\(error.localizedDescription)")
        }
    }
}
