//
//  MatchedGeometrySheetApp.swift
//  MatchedGeometrySheet
//
//  Created by Heecheon Park on 10/29/23.
//

import SwiftUI

@main
  struct MatchedGeometrySheetApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var windowSharedModel = WindowSharedModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(windowSharedModel)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        
        return config
    }
}


@Observable
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    weak var windowScene: UIWindowScene?
    var overlayWindow: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        windowScene = scene as? UIWindowScene
    }
    
    func addOverlayWindow(_ windowSharedModel: WindowSharedModel) {
        
        guard let windowScene else { return }
        
        let vc = UIHostingController(rootView: MatchedGeometryView()
            .environment(windowSharedModel)
            .allowsHitTesting(false)
        )
        vc.view.backgroundColor = .clear
        let overlay = UIWindow(windowScene: windowScene)
        overlay.rootViewController = vc
        overlay.isHidden = false
        overlay.isUserInteractionEnabled = false
        
        self.overlayWindow = overlay
    }
}

struct MatchedGeometryView: View {
    @Environment(WindowSharedModel.self) private var windowSharedModel
    
    var body: some View {
        GeometryReader { gp in
            VStack {
                let sourceRect = windowSharedModel.sourceRect
                if let selectedProfile = windowSharedModel.selectedProfile,
                    windowSharedModel.hideNativeView {
                    selectedProfile.placeholderColor
                        .frame(width: sourceRect.width, height: sourceRect.height)
                        .clipShape(.rect(cornerRadius: windowSharedModel.cornerRadius))
                        .offset(x: sourceRect.minX, y: sourceRect.minY)
                }
            }
            .animation(.snappy(duration: 0.3), value: windowSharedModel.sourceRect)
            .ignoresSafeArea()
        }
    }
}

struct RectKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
