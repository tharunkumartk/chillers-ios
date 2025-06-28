//
//  HomeView.swift
//  chillers
//
//  Created by Tharun Kumar on 6/27/25.
//

import SwiftUI

// MARK: - Home View

struct HomeView: View {
    var body: some View {
        ComingSoonView()
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environment(AppState())
    }
}
