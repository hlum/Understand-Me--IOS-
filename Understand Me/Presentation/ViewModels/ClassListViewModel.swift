//
//  ClassListViewModel.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/13.
//

import Foundation
import Combine
import OSLog

class ClassListViewModel: ObservableObject {
    @Published var classes: [Class] = []
    
    private let classUseCase: ClassUseCase
    private let authenticationUseCase: AuthenticationUseCase
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UnderstandMe", category: "Presentation")
    
    
    
    init(classUseCase: ClassUseCase, authenticationUseCase: AuthenticationUseCase) {
        self.classUseCase = classUseCase
        self.authenticationUseCase = authenticationUseCase
    }
    
    
    
    @MainActor
    func loadClasses() async {
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            logger.error("ClassListViewModel.loadClasses: ログイン中のユーザのデータ取得に失敗したので、クラスの取得ができません。")
            return
        }
        do {
            classes = try await classUseCase.fetchClassList(studentID: authDataResult.id)
        } catch {
            logger.error("ClassListViewModel.loadClasses: クラスの取得に失敗しました。詳細：\(error.localizedDescription)")
        }
    }
}
