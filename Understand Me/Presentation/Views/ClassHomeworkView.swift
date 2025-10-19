//
//  ClassHomeworkView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/08.
//

import SwiftUI

struct ClassHomeworkView: View {
    
    @StateObject private var viewModel: ClassHomeworkViewModel
    
    var classID: String
    
    
    init(classID: String) {
        self.classID = classID
        _viewModel = StateObject(wrappedValue: ClassHomeworkViewModel(
            homeworkUseCase: HomeworkUseCase(homeworkRepository: LollipopHomeworkRepository()),
            authenticationUseCase: AuthenticationUseCase(authenticationRepository: FirebaseAuthenticationRepository()),
            classUseCase: ClassUseCase(classRepository: LollipopClassRepository()),
            classID: classID
        ))
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ForEach(viewModel.homeworks) { homework in
                HomeworkListItemView(id: homework.id, title: homework.title, dueDate: homework.dueDate ?? Date(), state: homework.submissionState)
            }
        }
        .navigationTitle(viewModel.classInfo?.name ?? "")
        .task {
            await viewModel.loadClassInfos()
            await viewModel.loadHomeworks(classID: classID)
        }
    }
}

#Preview {
    NavigationStack {
        ClassHomeworkView(classID: "IOS プログラミング")
    }
}
