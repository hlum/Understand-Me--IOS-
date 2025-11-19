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
    
    @State private var showAddOptionalClassSheet: Bool = false
    
    var body: some View {
        Group {
            if !viewModel.classes.isEmpty {
                ScrollView(showsIndicators: false) {
                    ForEach(viewModel.classes) { classItem in
                        NavigationLink {
                            ClassHomeworkView(classID: classItem.id)
                        } label: {
                            ClassItemView(classID: "id", className: classItem.name, teacherName: classItem.teacherId)
                        }
                    }
                }
            } else {
                ContentUnavailableView("所属しているクラスがありません。", systemImage: "book.closed")
                    .foregroundStyle(.secondary.opacity(0.7))
            }
        }
        .navigationTitle("クラス一覧")
        .toolbar(content: {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddOptionalClassSheet = true
                } label: {
                    Image(systemName: "plus")
                        .bold()
                }
                .foregroundStyle(.accent)
            }
        })
        .foregroundStyle(.primary)
        .sheet(isPresented: $showAddOptionalClassSheet) {
            addOptionalClassSheetView
                .presentationDetents([.height(300)])
        }
        .task {
            await viewModel.loadClasses()
        }
    }
    
    
    @ViewBuilder
    private var addOptionalClassSheetView: some View {
        VStack(alignment: .leading) {
            Text("クラスコードを入力して参加")
                .font(.title2.bold())
                .padding(.top, 10)
            Text("選択科目のコードは担当の先生から受け取ってください。")
                .foregroundStyle(.secondary)
            
            
            TextField("科目コードを入力", text: $viewModel.classCode)
                .padding()
                .frame(maxWidth: .infinity)
                .frame(height: 55)
                .background(.background)
                .cornerRadius(10)
            
            Text(viewModel.classCodeErrorMessage)
                .foregroundStyle(.red)
                .frame(minHeight: 10)
            
            Spacer()
            
            
            Button {
                
            } label: {
                Text("参加する")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(viewModel.classCode.isEmpty ? .gray.opacity(0.3) : .accent)
                    .foregroundColor(viewModel.classCode.isEmpty ? .gray : .white)
                    .cornerRadius(10)
            }
            .disabled(viewModel.classCode.isEmpty)
        }
        .padding()
    }
}

#Preview {
    NavigationView {
        ClassListView()
    }
}
