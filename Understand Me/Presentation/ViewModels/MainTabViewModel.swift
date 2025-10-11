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
    
    
    
    func saveUserData(authDataResult: AuthDataResultModel) async {
        do {
            guard let email = authDataResult.email else {
                print("Emailが取得できません")
                return
            }
            
            let userData = UserData(
                id: authDataResult.id,
                email: email,
                fcmToken: nil,
                photoURL: authDataResult.photoURL?.absoluteString
            )
            
            try await userDataUseCase.saveUserData(userData: userData)
        } catch {
            print("UserDataの保存に失敗しました。")
        }
    }
}
