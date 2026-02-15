//
//  ContentView.swift
//  FlowState
//
//  Created by Dương Đinh Đông Khoa on 25/1/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(ViewModel.self) var viewModel
    @Query var blockedWebsiteList: [BlockedWebsite]
    @Query var blockedAppList: [BlockedApp]
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        Group {
            switch viewModel.appNavigationView {
            case .home:
                HomeView()
            case .edit:
                SettingView()
            }
        }
        .onAppear {
            viewModel.blockedDomains = blockedWebsiteList.map { $0.domain }
            viewModel.blockedAppNames = blockedAppList.map { $0.name }
        }
        .onChange(of: blockedWebsiteList) {
            viewModel.blockedDomains = blockedWebsiteList.map { $0.domain }
        }
        .onChange(of: blockedAppList) {
            viewModel.blockedAppNames = blockedAppList.map { $0.name }
        }
        .sheet(isPresented: $viewModel.showSessionComplete) {
            SessionCompleteView()
                .environment(viewModel)
        }
    }
}
