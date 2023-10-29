//
//  Home.swift
//  MatchedGeometrySheet
//
//  Created by Heecheon Park on 10/29/23.
//

import SwiftUI

struct Home: View {
    
    @State private var selectedProfile: Profile?
    @State private var showProfileView: Bool = false
    @Environment(WindowSharedModel.self) private var windowSharedModel
    @Environment(SceneDelegate.self) private var sceneDelegate
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(profiles) { profile in
                    HStack(spacing: 12) {
                        
                        GeometryReader { gp in
                            
                            let frame = gp.frame(in: .global)
                            
                            profile.placeholderColor
                                .frame(width: frame.width, height: frame.height)
                                .opacity(windowSharedModel.selectedProfile?.id == profile.id ? (windowSharedModel.hideNativeView || showProfileView ? 0 : 1) : 1)
                                .clipShape(.circle)
                                .contentShape(.circle)
                                .onTapGesture {
                                    Task {
                                        selectedProfile = profile
                                        windowSharedModel.selectedProfile = profile
                                        windowSharedModel.cornerRadius = frame.width * 0.5
                                        windowSharedModel.sourceRect = frame
                                        windowSharedModel.previousSourceRect = frame
                                        
                                        try? await Task.sleep(for: .seconds(0))
                                        windowSharedModel.hideNativeView = true
                                        showProfileView.toggle()
                                        
                                        try? await Task.sleep(for: .seconds(0.5))
                                        if windowSharedModel.hideNativeView {
                                            windowSharedModel.hideNativeView = false
                                        }
                                    }
                                }
                                .onAppear { print(frame) }
                        }
                        .frame(width: 50, height: 50)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(profile.userName)
                                .fontWeight(.bold)
                            
                            Text(profile.lastMsg)
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(profile.lastActive)
                            .font(.caption2)
                            .foregroundStyle(.gray)
                    }
                }
            }
            .padding(15)
            .padding(.horizontal, 5)
        }
        .scrollIndicators(.hidden)
        .sheet(isPresented: $showProfileView) {
            DetailProfileView(selectedProfile: $selectedProfile, showProfileView: $showProfileView)
                .presentationDetents([.medium, .large])
                .presentationCornerRadius(25)
            // Disabling interactive dismiss is necessary for the
            // manual matched geometry effect to take place.
                .interactiveDismissDisabled()
        }
        .onAppear {
            guard sceneDelegate.overlayWindow == nil else {return}
            sceneDelegate.addOverlayWindow(windowSharedModel)
        }
    }
}

struct DetailProfileView: View {
    @Binding var selectedProfile: Profile?
    @Binding var showProfileView: Bool
    @Environment(\.colorScheme) var scheme
    @Environment(WindowSharedModel.self) var windowSharedModel
    
    var body: some View {
        VStack {
            GeometryReader { gp in
                
                let size = gp.size
                let rect = gp.frame(in: .global)
                
                if let selectedProfile {
                    selectedProfile.placeholderColor
                        .frame(width: size.width, height: size.height)
                        .overlay {
                            let c = scheme == .dark ? Color.black : Color.white
                            LinearGradient(colors: [
                                .clear,
                                .clear,
                                .clear,
                                .clear,
                                c.opacity(0.1),
                                c.opacity(0.5),
                                c.opacity(0.7),
                                c.opacity(1)
                            ], startPoint: .top, endPoint: .bottom)
                        }
                        .preference(key: RectKey.self, value: rect)
                        .onPreferenceChange(RectKey.self, perform: { value in
                            if showProfileView {
                                windowSharedModel.sourceRect = value
                            }
                        })
                }
            }
            .overlay(alignment: .topLeading) {
                Button(action: {
                    Task {
                        windowSharedModel.hideNativeView = true
                        showProfileView = false
                        try? await Task.sleep(for: .seconds(0))
                        
                        windowSharedModel.sourceRect = windowSharedModel.previousSourceRect
                        
                        try? await Task.sleep(for: .seconds(0.5))
                        
                        if windowSharedModel.hideNativeView {
                            windowSharedModel.reset()
                            selectedProfile = nil
                        }
                    }
                }, label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .contentShape(.rect)
                        .padding(10)
                        .background(.black, in: .circle)
                })
                .padding(.leading, 20)
                .padding(.top, 25)
            }
            
            
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
