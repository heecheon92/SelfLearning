//
//  Home.swift
//  MatchedGeometryNavigation
//
//  Created by Heecheon Park on 10/25/23.
//

import SwiftUI

struct Home: View {
    
    @Binding var selectedProfile: Profile?
    @Binding var pushView: Bool
    
    var body: some View {
        List {
            ForEach(profiles) { profile in
                Button(action: {
                    selectedProfile = profile
                    pushView.toggle()
                }, label: {
                    HStack(spacing: 15) {

                        Color.clear
                            .frame(width: 60, height: 60)
                            /// Extract anchors of ImageView's placeholder
                            .anchorPreference(key: AnchorKey.self, value: .bounds, transform: { anchor in
                                [profile.id: anchor]
                            })
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(profile.userName)
                                .fontWeight(.semibold)
                            
                            Text(profile.lastMsg)
                                .font(.callout)
                                .textScale(.secondary)
                                .foregroundStyle(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(profile.lastActive)
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                })
            }
        }
        .overlayPreferenceValue(AnchorKey.self, { value in
            GeometryReader { gp in
                ForEach(profiles) { profile in
                    /// Fetching each profile image view using the profile id
                    if let anchor = value[profile.id],
                       selectedProfile?.id != profile.id {
                        let rect = gp[anchor]
                        ImageView(profile: profile, size: rect.size)
                            .offset(x: rect.minX, y: rect.minY)
                    }
                }
            }
            .allowsHitTesting(false)
        })
    }
}

struct ImageView: View {
    
    var profile: Profile
    var size: CGSize
    
    var body: some View {
        Rectangle()
            .fill(profile.placeholderColor)
            .frame(width: size.width, height: size.height)
            .overlay(
                LinearGradient(colors: [
                    .clear,
                    .clear,
                    .clear,
                    .white.opacity(0.1),
                    .white.opacity(0.5),
                    .white.opacity(0.9),
                    .white
                ], startPoint: .top, endPoint: .bottom)
                .opacity(size.width > 60 ? 1 : 0)
            )
            .clipShape(.rect(cornerRadius: size.width > 60 ? 0 : 30))
    }
}

#Preview {
    Home(selectedProfile: .constant(profiles[0]), pushView: .constant(false))
}
