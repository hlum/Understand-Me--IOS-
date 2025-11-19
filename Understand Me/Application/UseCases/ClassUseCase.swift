//
//  ClassUseCase.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/13.
//

import Foundation

class ClassUseCase {
    private let classRepository: ClassRepository
    
    init(classRepository: ClassRepository) {
        self.classRepository = classRepository
    }
    
    
    func addOptionalClass(classCode: String, userID: String) async throws {
        // TODO: Class 存在するかをチェックしてユーザーに知らせる
        try await classRepository.addOptionalClass(classCode: classCode, userID: userID)
    }
    
    
    func fetchClass(id: String) async throws -> Class {
        try await classRepository.fetch(id: id)
    }
    
    
    
    func fetchClassList(studentID: String) async throws -> [Class] {
        try await classRepository.fetchAll(studentID: studentID)
    }
}
