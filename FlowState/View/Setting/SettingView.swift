//
//  SettingView.swift
//  FlowState
//
//  Created by Dương Đinh Đông Khoa on 25/1/25.
//

import SwiftUI
import SwiftData

struct SettingView: View {
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.modelContext) var modelContext
    @Query var blockedList: [BlockedItem]
    
    @State var inputURL: String = ""
    @State var isValidURL: Bool = true
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                backButton
                
                Text("Edit Blocked Websites")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.grayWarm950)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 32) {
                inputURLField
                listBlockedWebsites
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.white)
    }
}
