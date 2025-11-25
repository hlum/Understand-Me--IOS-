//
//  DetailAverageScoreView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/11/21.
//

import SwiftUI

struct DetailAverageScoreView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                averageScoreForClassItem(className: "IOS開発科", averageScore: 80, finishedHomeworkCount: 8, maxHomeworkCount: 20)
                averageScoreForClassItem(className: "Android開発科", averageScore: 85, finishedHomeworkCount: 12, maxHomeworkCount: 40)
                averageScoreForClassItem(className: "Web開発科", averageScore: 92, finishedHomeworkCount: 10, maxHomeworkCount: 25)
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("平均スコア")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private func averageScoreForClassItem(className: String, averageScore: Int, finishedHomeworkCount: Int, maxHomeworkCount: Int) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: "graduationcap.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        LinearGradient(
                            colors: [.secAccent, .accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Text(className)
                    .font(.title3.bold())
                
                Spacer()
            }
            
            // Stats Cards
            HStack(spacing: 12) {
                // Average Score Card
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "star.hexagon")
                            .font(.title3)
                            .foregroundStyle(.accent)
                        
                        Text("平均点")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("\(averageScore)")
                            .font(.system(size: 32, weight: .bold))
                        
                        Text("点")
                            .font(.subheadline)
                    }
                    .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                
                // Homework Count Card
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secAccent)
                        
                        Text("課題数")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        
                        Text("\(finishedHomeworkCount)")
                            .font(.system(size: 32, weight: .bold))
                        
                        Text("/\(maxHomeworkCount)")
                            .font(.subheadline)
                        
                        Text("個")
                            .font(.subheadline)
                        
                    }
                    .foregroundStyle(.primary)
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        DetailAverageScoreView()
    }
}
