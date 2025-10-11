//
//  MainTabViewModel.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/11.
//

import Foundation
import Combine

class MainTabViewModel: ObservableObject {
    private let userDataUseCase: UserDataUseCase
    
    init(userDataUseCase: UserDataUseCase) {
        self.userDataUseCase = userDataUseCase
    }
    
    
    
    func saveUserData(userData: UserData) async {
        do {
            try await userDataUseCase.saveUserData(userData: userData)
        } catch {
            print("UserDataの保存に失敗しました。")
        }
    }
}
