//
//  ClassUseCase.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/13.
//



import Foundation
import OSLog

enum ClassUseCaseErrors: LocalizedError {
    case InvalidClassCode
    case AlreadyEnrolled
    case UnknownError
    
    var errorDescription: String? {
        switch self {
            case .InvalidClassCode:
                return "無効な学科コードです。"
            case .AlreadyEnrolled:
                return "すでにこの科目に登録されています。"
            case .UnknownError:
                return "予期せぬエラーが発生しました。やり直してください。"
        }
    }
}


class ClassUseCase {
    private let classRepository: ClassRepository
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UnderstandMe", category: "UseCase")
    
    
    init(classRepository: ClassRepository) {
        self.classRepository = classRepository
    }
    
    
    func addOptionalClass(classCode: String, userID: String) async throws {
        try await checkClassCode(classCode: classCode, userID: userID)
        try await classRepository.addOptionalClass(classCode: classCode, userID: userID)
    }
    
    
    func fetchClass(id: String) async throws -> Class {
        try await classRepository.fetch(id: id)
    }
    
    
    
    func fetchClass(classCode: String) async throws -> Class? {
        try await classRepository.fetch(classCode: classCode)
    }
    
    
    
    func fetchClassList(studentID: String) async throws -> [Class] {
        try await classRepository.fetchAll(studentID: studentID)
    }
    
    
    
    private func checkClassCode(classCode: String, userID: String) async throws {
        var classExists = false
        
        do {
            classExists = try await fetchClass(classCode: classCode) != nil
        } catch {
            logger.error("学科コードの有効性の検証のため、学科取得に失敗しました。\(error.localizedDescription)")
            throw ClassUseCaseErrors.UnknownError
        }
        
        if !classExists {
            throw ClassUseCaseErrors.InvalidClassCode
        }
        
        var userAlreadyEnrolled = false
        do {
            let classes = try await fetchClassList(studentID: userID)
            userAlreadyEnrolled = classes.contains { $0.classCode == classCode }
        } catch {
            logger.error("学科コードの有効性の検証のため、学科取得に失敗しました。\(error.localizedDescription)")
            throw ClassUseCaseErrors.UnknownError
        }
        
        if userAlreadyEnrolled {
            throw ClassUseCaseErrors.AlreadyEnrolled
        }
    }
}
