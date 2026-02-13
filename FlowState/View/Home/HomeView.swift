//
//  ContentView.swift
//  FlowState
//
//  Created by Dương Đinh Đông Khoa on 25/1/25.
//

import SwiftUI
import Foundation

struct HomeView: View {
    @EnvironmentObject var viewModel: ViewModel
    @State var showCategorySheet = false
    
    var body: some View {
        VStack(spacing: 96) {
            editCategoryButton
            VStack(spacing: 24) {
                header
                mainGroupButtons
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
    }
}
