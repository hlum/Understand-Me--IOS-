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
            print("UserDataの保存に失敗しました。\(error.localizedDescription)")
        }
    }
    
    
    
    @MainActor
    func loadUserData(userID: String) async {
        do {
            self.userData = try await userDataUseCase.fetchUserData(userID: userID)
        } catch {
            // TODO: Userにエラーを知らせる
            print("MainTabViewModel.loadUseData: UserDataの取得に失敗しました。\(error.localizedDescription)")
        }
    }
    
    
    // メールから学年と学科コードを取得する、もしメールが学校のメールじゃない場合ダミーを返す
    func extractStudentInfo(from email: String) -> (studentCode: String, className: String, admissionYear: Int)? {
        // Example valid format: "24cm0138@jec.ac.jp"
        guard let atIndex = email.firstIndex(of: "@") else {
            return ("99zz", "zz", 99)
        }
        
        // Get part before "@"
        let localPart = String(email[..<atIndex]) // e.g., "24cm0138"
        
        // Must have at least 4 characters to include year + class
        guard localPart.count >= 4 else {
            return ("99zz", "zz", 99)
        }
        
        // admissionYear = first 2 chars
        let yearPart = String(localPart.prefix(2)) // "24"
        guard let admissionYear = Int(yearPart) else {
            return ("99zz", "zz", 99)
        }
        
        // Extract class name: next 2 letters after the year
        let startIndex = localPart.index(localPart.startIndex, offsetBy: 2)
        let classPart = localPart[startIndex...]
        let letters = classPart.prefix(while: { $0.isLetter })
        let className = String(letters)
        
        // Class name must be exactly 2 letters (e.g., "cm")
        guard className.count == 2 else {
            return ("99zz", "zz", 99)
        }
        
        // studentCode is the full before "@"
        let studentCode = localPart
        
        return (studentCode, className, admissionYear)
    }

}
