//
//  SettingView-Components.swift
//  FlowState
//
//  Created by Dương Đinh Đông Khoa on 29/6/25.
//

import SwiftUI

extension SettingView {
    var inputURLField: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField("", text: $inputURL, prompt: Text("Enter website e.g facebook.com").foregroundStyle(.grayWarm300))
                .autocorrectionDisabled(true)
                .textFieldStyle(.plain)
                .frame(maxWidth: .infinity)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 16)
                .padding(.horizontal, 12)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppConfig.ColorTheme.primaryText)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isValidURL ? .grayWarm950 : .error500, lineWidth: 2)
                )
            
                Text("The input URL not valid!")
                    .foregroundStyle(.error500)
                    .opacity(isValidURL ? 0 : 1)
        }
        .onSubmit {
            guard !inputURL.isEmpty else { // Empty
                isValidURL = false
                return
            }
            
            guard inputURL.count > 3 else { // Too short
                isValidURL = false
                return
            }
            
            guard !blockedList.contains(where: { $0.blockedURL == inputURL }) else { // Duplicate
                isValidURL = true
                inputURL = ""
                return
            }
            
            // Add data
            modelContext.insert(BlockedItem(blockedURL: inputURL))
            inputURL = ""
            isValidURL = true
        }

    }
    
    var backButton: some View {
        Button(action: {
            viewModel.appNavigationView = .home
        }) {
            Image(systemName: "chevron.backward")
                .font(.system(size: 14, weight: .semibold))
                .fixedSize(horizontal: true, vertical: true)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .foregroundStyle(.grayWarm950)
                .background(.grayWarm200)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    var listBlockedWebsites: some View {
        if !blockedList.isEmpty {
            ScrollView(.vertical) {
                VStack(spacing: 8) {
                    ForEach(blockedList) { website in
                        HStack(spacing: 12) {
                            Text(website.blockedURL)
                                .foregroundStyle(.grayWarm950)
                                .font(.system(size: 14, weight: .semibold))
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Button(action: {
                                modelContext.delete(website)
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.grayWarm950)
                            }
                            .buttonStyle(.plain)
                            
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(.grayWarm200)
                        .clipShape(RoundedRectangle(cornerRadius: .infinity))
                    }
                }
            }
        } else {
            Button {
                modelContext.insert(BlockedItem(blockedURL: "facebook.com"))
                modelContext.insert(BlockedItem(blockedURL: "x.com"))
                modelContext.insert(BlockedItem(blockedURL: "reddit.com"))
                modelContext.insert(BlockedItem(blockedURL: "tiktok.com"))
            } label: {
                Text("Add suggested websites")
                    .padding(.horizontal, 24)
                    .padding(.vertical)
                    .foregroundStyle(.white)
                    .background(
                        Capsule()
                            .fill(.blue600)
                    )
            }
            .buttonStyle(.plain)
        }
    }
}
