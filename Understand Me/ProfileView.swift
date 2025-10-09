//
//  ProfileView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/09.
//

import SwiftUI
import Charts

struct DataPoint: Identifiable {
    let id = UUID()
    let category: String
    let value: Double
}

struct ProfileView: View {
    @State private var data: [DataPoint] = [
        DataPoint(category: "1月", value: 100),
        DataPoint(category: "2月", value: 65),
        DataPoint(category: "3月", value: 75),
        DataPoint(category: "4月", value: 80)
    ]
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                profileBasicInfo
                
                graphInfo
                
                statusInfo
                
                logoutBtn
            }
            .padding(.horizontal)
        }
        .navigationTitle("プロフィール")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    
    @ViewBuilder
    private var profileBasicInfo: some View {
        AsyncImage(url: URL(string: "https://e-quester.com/wp-content/uploads/2021/11/placeholder-image-person-jpg.jpg")) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 150)
                .cornerRadius(300)
        } placeholder: {
            Image(.profilePic)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 150)
                .cornerRadius(300)
        }
        
        Text("田中　太郎")
            .font(.title.bold())
        
        Text(verbatim: "24cm0138@gmail.com")
            .foregroundStyle(.gray)
    }
    
    
    @ViewBuilder
    private var graphInfo: some View {
        Text("学業進捗")
            .font(.title2.bold())
            .frame(maxWidth: .infinity, alignment: .leading)
        
        Chart {
            ForEach(data) { dataPoint in
                
                BarMark(
                    x: .value("Category", dataPoint.category),
                    y: .value("Value", dataPoint.value)
                )
                .foregroundStyle(.accent)
            }
        }
        .frame(height: 200)
        .chartYScale(domain: 0...100)
        .padding()
        
        HStack {
            Circle()
                .fill(.accent)
                .frame(width: 10, height: 10)
            Text("平均スコア")
                .font(.caption)
        }
    }
    
    
    @ViewBuilder
    private var statusInfo: some View {
        HStack {
            VStack(spacing: 10) {
                Image(systemName: "checkmark.circle")
                    .font(.title2)
                    .foregroundStyle(.secAccent)
                
                Text("13")
                    .font(.headline)
                
                Text("完了した課題")
                    .fontWeight(.thin)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(lineWidth: 2)
                    .foregroundStyle(.gray.opacity(0.2))
            )
            .padding(.horizontal)
            
            VStack(spacing: 10) {
                Image(systemName: "star.hexagon")
                    .font(.title2)
                    .foregroundStyle(.accent)
                
                Text("80")
                    .font(.headline)
                
                Text("平均スコア")
                    .fontWeight(.thin)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(lineWidth: 2)
                    .foregroundStyle(.gray.opacity(0.2))
            )
            .padding(.horizontal)
        }
    }
    
    
    @ViewBuilder
    private var logoutBtn: some View {
        Button {
            
        } label: {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                
                Text("ログアウト")
                
            }
            .foregroundStyle(.red)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 55)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .stroke(lineWidth: 2)
                .foregroundStyle(.gray.opacity(0.2))
        )
        .padding(.top, 50)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}
