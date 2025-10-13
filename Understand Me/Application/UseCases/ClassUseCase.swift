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
    
    
    
    func fetchClassList(studentID: String) async throws -> [Class] {
        try await classRepository.fetchAll(studentID: studentID)
    }
}
