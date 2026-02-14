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
            let cleaned = cleanDomainInput(inputURL)
            
            guard isValidDomain(cleaned) else {
                isValidURL = false
                return
            }
            
            guard !blockedWebsiteList.contains(where: { $0.domain == cleaned }) else {
                isValidURL = true
                inputURL = ""
                return
            }
            
            modelContext.insert(BlockedWebsite(domain: cleaned))
            try? modelContext.save()
            inputURL = ""
            isValidURL = true
        }
    }
    
    var backButton: some View {
        IconActionButton(icon: "chevron.backward") {
            viewModel.appNavigationView = .home
        }
    }
    
    @ViewBuilder
    var listBlockedWebsites: some View {
        if !blockedWebsiteList.isEmpty {
            VStack(spacing: 8) {
                ForEach(blockedWebsiteList) { website in
                    HStack(spacing: 12) {
                        Text(website.domain)
                            .foregroundStyle(.grayWarm950)
                            .font(.system(size: 14, weight: .semibold))
                            .lineLimit(1)
                        
                        Spacer()
                        
                        DeleteButton(isDisabled: viewModel.isSessionActive) {
                            modelContext.delete(website)
                            try? modelContext.save()
                        }
                    }
                    .listItemRow()
                }
            }
        } else {
            Button {
                modelContext.insert(BlockedWebsite(domain: "facebook.com"))
                modelContext.insert(BlockedWebsite(domain: "x.com"))
                modelContext.insert(BlockedWebsite(domain: "reddit.com"))
                modelContext.insert(BlockedWebsite(domain: "tiktok.com"))
                try? modelContext.save()
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
    
    // MARK: - Blocked Apps Components
    
    var addAppButton: some View {
        Button(action: {
            showingAppPicker = true
        }) {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .semibold))
                Text("Choose App")
                    .font(.system(size: 14, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundStyle(.grayWarm950)
            .contentShape(Rectangle())
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.grayWarm950, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    var listBlockedApps: some View {
        if !blockedAppList.isEmpty {
            VStack(spacing: 8) {
                ForEach(blockedAppList) { app in
                    HStack(spacing: 12) {
                        AppIconView(appPath: app.path)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(app.name)
                                .foregroundStyle(.grayWarm950)
                                .font(.system(size: 14, weight: .semibold))
                                .lineLimit(1)
                            
                            Text(app.path)
                                .foregroundStyle(.grayWarm400)
                                .font(.system(size: 11, weight: .regular))
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        DeleteButton(isDisabled: viewModel.isSessionActive) {
                            modelContext.delete(app)
                            try? modelContext.save()
                        }
                    }
                    .listItemRow()
                }
            }
        }
    }
    
    func handleAppSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            let appPath = url.path
            let appName = url.deletingPathExtension().lastPathComponent
            
            guard !blockedAppList.contains(where: { $0.path == appPath }) else { return }
            
            modelContext.insert(BlockedApp(name: appName, path: appPath))
            try? modelContext.save()
            
        case .failure(let error):
            print("Error selecting app: \(error)")
        }
    }
    
    // MARK: - Helpers
    
    private func cleanDomainInput(_ input: String) -> String {
        var result = input
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        
        for prefix in ["https://", "http://"] {
            if result.hasPrefix(prefix) {
                result = String(result.dropFirst(prefix.count))
            }
        }
        
        if result.hasPrefix("www.") {
            result = String(result.dropFirst(4))
        }
        
        if let slashIndex = result.firstIndex(of: "/") {
            result = String(result[result.startIndex..<slashIndex])
        }
        
        return result
    }
    
    private func isValidDomain(_ domain: String) -> Bool {
        let pattern = #"^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"#
        return domain.range(of: pattern, options: .regularExpression) != nil
    }
}
