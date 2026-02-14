//
//  SettingView.swift
//  FlowState
//
//  Created by Dương Đinh Đông Khoa on 25/1/25.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingView: View {
    @Environment(ViewModel.self) var viewModel
    @Environment(\.modelContext) var modelContext
    @Query var blockedWebsiteList: [BlockedWebsite]
    @Query var blockedAppList: [BlockedApp]
    
    @State var inputURL: String = ""
    @State var isValidURL: Bool = true
    @State var showingAppPicker: Bool = false
    
    var body: some View {
        VStack(spacing: 40) {
            VStack(alignment: .leading, spacing: 16) {
                backButton
                
                VStack (alignment: .leading, spacing: 8) {
                    Text("Settings")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.grayWarm950)
                    
                    if viewModel.isSessionActive {
                        Text("Your session is active. You cannot remove any blocked items.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.error500)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView(.vertical) {
                VStack(spacing: 32) {
                    // MARK: - Blocked Websites Section
                    VStack(spacing: 12) {
                        Text("Blocked Websites")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.grayWarm700)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        inputURLField
                        listBlockedWebsites
                    }
                    
                    // MARK: - Blocked Apps Section
                    VStack(spacing: 12) {
                        Text("Blocked Apps")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.grayWarm700)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        addAppButton
                        listBlockedApps
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 2)
            }
        }
        .pageBackground()
        .fileImporter(
            isPresented: $showingAppPicker,
            allowedContentTypes: [.application],
            allowsMultipleSelection: false
        ) { result in
            handleAppSelection(result)
        }
    }
}
