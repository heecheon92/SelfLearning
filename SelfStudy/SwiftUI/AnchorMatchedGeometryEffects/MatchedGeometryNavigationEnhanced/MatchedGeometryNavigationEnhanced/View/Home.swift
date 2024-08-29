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
    
    @State private var heroProgress: CGFloat = 0;
    @State private var showHeroView: Bool = true
    
    var body: some View {
        NavigationStack {
            List(allProfiles) { profile in
                HStack(spacing: 12) {
                    profile.placeholderColor
                        .frame(width: 50, height: 50)
                        .clipShape(.circle)
                        .opacity(selectedProfile?.id == profile.id ? 0 : 1)
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
                    
                    withAnimation(.snappy(duration: 0.35, extraBounce: 0), completionCriteria: AnimationCompletionCriteria.logicallyComplete) {
                        heroProgress = 1.0
                    } completion: {
                        Task {
                            try? await Task.sleep(for: .seconds(0.1))
                            showHeroView = false
                        }
                    }
                }
            }
            .navigationTitle("Progress Effect")
        }
        .overlay {
            DetailView(selectedProfile: $selectedProfile,
                       showDetail: $showDetail,
                       heroProgress: $heroProgress,
                       showHeroView: $showHeroView
            )
        }
        .overlayPreferenceValue(AnchorKey.self) { value in
            GeometryReader { gp in
                if let selectedProfile,
                   let source = value[selectedProfile.id],
                   let destination = value["Destination"] {
                    
                    let sourceRect = gp[source]
                    let destinationRect = gp[destination]
                    
                    let diffSize = CGSize(
                        width: destinationRect.width - sourceRect.width,
                        height: destinationRect.height - sourceRect.height
                    )
                    let diffOrigin = CGPoint(
                        x: destinationRect.minX - sourceRect.minX,
                        y: destinationRect.minY - sourceRect.minY
                    )
                    
                    selectedProfile.placeholderColor
                        .clipShape(Circle())
                        .frame(
                            width: sourceRect.width + (diffSize.width * heroProgress),
                            height: sourceRect.height + (diffSize.height * heroProgress)
                        )
                        .offset(
                            x: sourceRect.minX + (diffOrigin.x * heroProgress),
                            y: sourceRect.minY + (diffOrigin.y * heroProgress)
                        )
                        .opacity(showHeroView ? 1 : 0)
                        .allowsHitTesting(false)
                }
            }
        }
    }
}

struct DetailView: View {
    
    @Binding var selectedProfile: Profile?
    @Binding var showDetail: Bool
    @Binding var heroProgress: CGFloat
    @Binding var showHeroView: Bool
    @Environment(\.colorScheme) var scheme
    
    @GestureState private var isDragging: Bool = false
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        if let selectedProfile, showDetail {
            GeometryReader { gp in
                let size = gp.size
                
                ScrollView {
                    Rectangle()
                        .fill(.clear)
                        .overlay {
                            if !showHeroView {
                                selectedProfile.placeholderColor
                                    .frame(width: size.width, height: 400)
                                    .transition(.identity)
                            }
                        }
                        .frame(height: 400)
                        .anchorPreference(key: AnchorKey.self, value: .bounds) { anchor in
                            return ["Destination": anchor]
                        }
                        .visualEffect { content, gp in
                            content
                                .offset(
                                    x: gp.frame(in: .scrollView).minY > 0 ?
                                    -gp.frame(in: .scrollView).minY : 0)
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
                        showHeroView = true
                        withAnimation(
                            .snappy(duration: 0.35, extraBounce: 0),
                            completionCriteria: .logicallyComplete) {
                                heroProgress = 0
                            } completion: {
                                showDetail = false
                                self.selectedProfile = nil
                            }
                    }, label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.largeTitle)
                            .imageScale(.medium)
                            .contentShape(.rect)
                            .foregroundStyle(.white, .black)
                    })
                    .buttonStyle(.plain)
                    .padding()
                    .opacity(showHeroView ? 0 : 1)
                    .animation(.snappy(duration: 0.2, extraBounce: 0), value: showHeroView)
                }
                .offset(x: size.width - (size.width * heroProgress))
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(.clear)
                        .frame(width: 10)
                        .contentShape(.rect)
                        .gesture(dragGesture(size: size))
                }
            }
        }
    }
    
    func dragGesture(size: CGSize) -> some Gesture {
        return DragGesture()
            .updating($isDragging, body: { _, out, _ in
                out = true
            })
            .onChanged({ value in
                var width = value.translation.width
                width = isDragging ? width : 0
                width = width > 0 ? width : 0
                
                let dragProgress = 1 - (width / size.width)
                let cappedProgress = min(max(0, dragProgress), 1)
                heroProgress = cappedProgress
                dragOffset = width
                if !showHeroView {
                    showHeroView = true
                }
            })
            .onEnded({ value in
                let velocity = value.velocity.width
                if (dragOffset + velocity) > (size.width * 0.8) {
                    withAnimation(
                        .snappy(duration: 0.35, extraBounce: 0),
                        completionCriteria: .logicallyComplete) {
                            heroProgress = .zero
                        } completion: {
                            dragOffset = .zero
                            showDetail = false
                            showHeroView = true
                            self.selectedProfile = nil
                        }
                } else {
                    withAnimation(
                        .snappy(duration: 0.35, extraBounce: 0),
                        completionCriteria: .logicallyComplete) {
                            heroProgress = 1.0
                            dragOffset = .zero
                        } completion: {
                            showHeroView = true
                        }
                }
            })
    }
}

#Preview {
    Home()
}
