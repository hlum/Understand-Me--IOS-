//
//  MainTabViewModel.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/11.
//

import Foundation
import Combine

class MainTabViewModel: ObservableObject {
    @Published var userData: UserData? = nil
    private let userDataUseCase: UserDataUseCase
    
    init(userDataUseCase: UserDataUseCase) {
        self.userDataUseCase = userDataUseCase
    }
    
    
    
    func saveUserDataIfNotExist(authDataResult: AuthDataResultModel) async {
        do {
            guard let email = authDataResult.email else {
                print("Emailが取得できません")
                return
            }
            
            guard let info = extractStudentInfo(from: email) else {
                print("メール形式が正しくありません。")
                return
            }
            
            
            let userData = UserData(
                id: authDataResult.id,
                email: email,
                fcmToken: nil,
                studentCode: info.studentCode,
                majorCode: info.className,
                admissionYear: info.admissionYear,
                photoURL: authDataResult.photoURL?.absoluteString
            )
            
            try await userDataUseCase.saveUserDataIfNotExist(userData: userData)
        } catch {
            print("UserDataの保存に失敗しました。")
        }
    }
    
    
    
    @MainActor
    func loadUserData(userID: String) async {
        do {
            self.userData = try await userDataUseCase.fetchUserData(userID: userID)
        } catch {
            // TODO: Userにエラーを知らせる
            print("UserDataの取得に失敗しました。\(error.localizedDescription)")
        }
    }
    
    
    
    func extractStudentInfo(from email: String) -> (studentCode: String, className: String, admissionYear: Int)? {
        // Example: "24cm0138@jec.ac.jp"
        guard let atIndex = email.firstIndex(of: "@") else { return nil }
        
        // Get part before "@"
        let localPart = String(email[..<atIndex]) // "24cm0138"
        
        // admissionYear = first 2 chars
        let yearPart = String(localPart.prefix(2)) // "24"
        guard let admissionYear = Int(yearPart) else { return nil }
        
        // Extract class name: find alphabet part after year
        let letters = localPart.dropFirst(2).prefix { $0.isLetter }
        let className = String(letters) // "cm"
        
        // studentCode is the full before "@"
        let studentCode = localPart // "24cm0138"
        
        return (studentCode, className, admissionYear)
    }

}
