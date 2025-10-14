//
//  ClassListView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/08.
//

import SwiftUI

struct ClassListView: View {
    
    @StateObject private var viewModel = ClassListViewModel(
        classUseCase: ClassUseCase(classRepository: LollipopClassRepository()),
        authenticationUseCase: AuthenticationUseCase(authenticationRepository: FirebaseAuthenticationRepository())
    )

    var body: some View {
        ScrollView(showsIndicators: false) {
            ForEach(viewModel.classes) { classItem in
                NavigationLink {
                    ClassHomeworkView(classID: classItem.id)
                } label: {
                    ClassItemView(classID: "id", className: classItem.name, teacherName: classItem.teacherId)
                }
            }
        }
        .navigationTitle("クラス一覧")
        .foregroundStyle(.primary)
        .task {
            await viewModel.loadClasses()
        }
    }
}

#Preview {
    NavigationView {
        ClassListView()
    }
}
