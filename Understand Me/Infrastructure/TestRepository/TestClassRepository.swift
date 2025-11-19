//
//  TestClassRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/20.
//

import Foundation

class TestClassRepository: ClassRepository {
    func fetch(classCode: String) async throws -> Class? {
        return nil
    }
    
    func addOptionalClass(classCode: String, userID: String) async throws {
        return
    }
    
    func fetch(id: String) async throws -> Class {
        return Class.getDummy()
    }
    
    func fetchAll(studentID: String) async throws -> [Class] {
        return [.getDummy(), .getDummy(), .getDummy(), .getDummy()]
    }
}
