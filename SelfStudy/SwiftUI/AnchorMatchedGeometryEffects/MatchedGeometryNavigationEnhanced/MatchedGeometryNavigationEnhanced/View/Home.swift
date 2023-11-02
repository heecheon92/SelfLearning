//
//  Home.swift
//  MatchedGeometryNavigationEnhanced
//
//  Created by Heecheon Park on 11/2/23.
//

import SwiftUI

struct Home: View {
    
    @State private var allProfiles: [Profile] = profiles
    
    @State private var selectedProfile: Profile? = nil
    @State private var showDetail: Bool = false
    
    var body: some View {
        NavigationStack {
            List(allProfiles) { profile in
                HStack(spacing: 12) {
                    profile.placeholderColor
                        .frame(width: 50, height: 50)
                        .clipShape(.circle)
                        .anchorPreference(key: AnchorKey.self, value: .bounds) { anchor in
                            return [profile.id: anchor]
                        }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(profile.userName)
                            .fontWeight(.semibold)
                        
                        Text(profile.lastMsg)
                            .font(.caption2)
                            .foregroundStyle(.gray)
                    }
                }
                .contentShape(.rect)
                .onTapGesture {
                    selectedProfile = profile
                    showDetail = true
                }
            }
            .navigationTitle("Progress Effect")
        }
        .overlay {
            DetailView(selectedProfile: $selectedProfile,
                       showDetail: $showDetail)
        }
        .overlayPreferenceValue(AnchorKey.self) { value in
            GeometryReader { gp in
                if let selectedProfile,
                   let source = value[selectedProfile.id],
                   let destination = value["Destination"] {
                    let sourceRect = gp[value]
                    let destinationRect = gp[destination]
                    
                    
                }
            }
        }
    }
}

struct DetailView: View {
    
    @Binding var selectedProfile: Profile?
    @Binding var showDetail: Bool
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        if let selectedProfile, showDetail {
            GeometryReader { gp in
                let size = gp.size
                
                ScrollView {
                    Rectangle()
                        .fill(.clear)
                        .overlay {
                            selectedProfile.placeholderColor
                                .frame(width: size.width, height: 400)
                                .hidden()
                        }
                        .frame(height: 400)
                        .anchorPreference(key: AnchorKey.self, value: .bounds) { anchor in
                            return ["Destination": anchor]
                        }
                }
                .scrollIndicators(.hidden)
                .ignoresSafeArea()
                .frame(width: size.width, height: size.height)
                .background {
                    Rectangle()
                        .fill(scheme == .dark ? .black : .white)
                        .ignoresSafeArea()
                }
                .overlay(alignment: .topLeading) {
                    Button(action: {
                        showDetail = false
                        self.selectedProfile = nil
                    }, label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.largeTitle)
                            .imageScale(.medium)
                            .contentShape(.rect)
                            .foregroundStyle(.white, .black)
                    })
                    .buttonStyle(.plain)
                    .padding()
                }
            }
        }
    }
}
