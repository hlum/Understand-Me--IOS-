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
    @State var addOptionalClassLoading: Bool = false
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ClassListSkeleton()
            } else if !viewModel.classes.isEmpty {
                ScrollView(showsIndicators: false) {
                    ForEach(viewModel.classes) { classItem in
                        NavigationLink {
                            ClassHomeworkView(classID: classItem.id)
                        } label: {
                            ClassItemView(classID: classItem.id, className: classItem.name, teacherName: classItem.teacherName)
                        }
                    }
                }
            } else {
                ContentUnavailableView("所属しているクラスがありません。", systemImage: "book.closed")
                    .foregroundStyle(.secondary.opacity(0.7))
            }
        }
        .navigationTitle("科目一覧")
        .toolbar(content: {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.showAddOptionalClassSheet = true
                } label: {
                    Image(systemName: "plus")
                        .bold()
                }
                .foregroundStyle(.accent)
            }
        })
        .foregroundStyle(.primary)
        .sheet(isPresented: $viewModel.showAddOptionalClassSheet) {
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
                .background(.gray.opacity(0.3))
                .cornerRadius(10)
            
            Text(viewModel.classCodeErrorMessage)
                .foregroundStyle(.red)
                .frame(minHeight: 10)
            
            Spacer()
            
            
            Button {
                Task {
                    addOptionalClassLoading = true
                    await viewModel.addOptionalClass()
                    addOptionalClassLoading = false
                }
            } label: {
                Text(addOptionalClassLoading ? "エントリー中。。" : "参加する")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(viewModel.classCode.isEmpty || addOptionalClassLoading ? .gray.opacity(0.3) : .accent)
                    .foregroundColor(viewModel.classCode.isEmpty || addOptionalClassLoading ? .gray : .white)
                    .cornerRadius(10)
            }
            .disabled(viewModel.classCode.isEmpty || addOptionalClassLoading)
        }
        .padding()
    }
}

#Preview {
    NavigationView {
        ClassListView()
    }
}
