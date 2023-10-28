//
//  ContentView.swift
//  MatchedGeometryNavigation
//
//  Created by Heecheon Park on 10/25/23.
//

import SwiftUI

struct ContentView: View {
    
    @State private var selectedProfile: Profile?
    @State private var pushView: Bool = false
    @State private var hideView: (Bool, Bool) = (false, false)
    
    var body: some View {
        NavigationStack {
            Home(selectedProfile: $selectedProfile, pushView: $pushView)
                .navigationTitle("Profile")
                .navigationDestination(isPresented: $pushView) {
                    DetailView(selectedProfile: $selectedProfile, pushView: $pushView, hideView: $hideView)
                }
        }
        .overlayPreferenceValue(AnchorKey.self, { value in
            GeometryReader { gp in
                ForEach(profiles) { profile in
                    /// Fetching each profile image view using the profile id
                    if let selectedProfile,
                       let anchor = value[selectedProfile.id],
                       !hideView.0 {
                        let rect = gp[anchor]
                        ImageView(profile: selectedProfile, size: rect.size)
                            .offset(x: rect.minX, y: rect.minY)
                            .animation(.snappy(duration: 0.35, extraBounce: 0), value: rect)
                    }
                }
            }
        })
    }
}

#Preview {
    ContentView()
}
