//
//  GlobalAlert.swift
//  GlobalAlert
//
//  Created by Heecheon Park on 10/8/23.
//

import SwiftUI
import UIKit

@Observable class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        
        // Setting SceneDelegate class
        config.delegateClass = SceneDelegate.self
        
        return config
    }
}

@Observable class SceneDelegate: NSObject, UIWindowSceneDelegate {
    
    // Current Scene
    weak var windowScene: UIWindowScene?
    var overlayWindow: UIWindow?
    var tag: Int = 0
    var alerts: [UIView] = []
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        windowScene = scene as? UIWindowScene
        setupOverlayWindow()
    }
    
    // Add an overlay window to handle all alerts on the top of the current window.
    private func setupOverlayWindow() {
        guard let windowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.isHidden = true
        window.isUserInteractionEnabled = false
        overlayWindow = window
    }
    
    ///
    /// The viewTag closure will return the appropriate tag for the added alert view,
    /// and with that, we can remove the alert in some complex cases.
    fileprivate func alert<Content: View>(config: Binding<GlobalAlertConfiguration>,
                                          @ViewBuilder content: @escaping () -> Content,
                                          viewTag: @escaping (Int) -> ()) {
        
        guard let alertWindow = overlayWindow else { return }
        let vc = UIHostingController(rootView: GlobalAlert(config: config,
                                                           tag: tag,
                                                           content: { content() }))
        
        vc.view.backgroundColor = .clear
        vc.view.tag = tag
        viewTag(tag)
        tag += 1
        
        if alertWindow.rootViewController == nil {
            alertWindow.rootViewController = vc
            alertWindow.isHidden = false
            alertWindow.isUserInteractionEnabled = true
        } else {
            print("Existing alert is still present, reserving for the next one.")
            vc.view.frame = alertWindow.rootViewController?.view.frame ?? .zero
            alerts.append(vc.view)
        }
    }
}

extension View {
    @ViewBuilder func alert<Content: View>(config: Binding<GlobalAlertConfiguration>,
                                           @ViewBuilder content: @escaping () -> Content) -> some View {
        
        self.modifier(GlobalAlertModifier(config: config, alertContent: content))
    }
}

fileprivate struct GlobalAlertModifier<AlertContent: View>: ViewModifier {
    @Binding var config: GlobalAlertConfiguration
    @ViewBuilder var alertContent: () -> AlertContent
    // SceneDelegate
    @Environment(SceneDelegate.self) private var sceneDelegate
    // ViewTag
    @State private var viewTag: Int = 0
    
    func body(content: Content) -> some View {
        content
            .onChange(of: config.show, initial: false) { oldValue, newValue in
                if newValue {
                    sceneDelegate.alert(config: $config, content: alertContent) { tag in
                        viewTag = tag
                    }
                } else {
                    guard let alertWindow = sceneDelegate.overlayWindow else { return }
                    if config.displayContent {
                        withAnimation(.smooth(duration: 0.35)) {
                            config.displayContent = false
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            if sceneDelegate.alerts.isEmpty {
                                alertWindow.rootViewController = nil
                                alertWindow.isHidden = true
                                alertWindow.isUserInteractionEnabled = false
                            } else {
                                
                                if let first = sceneDelegate.alerts.first {
                                    // Removing the preview view
                                    alertWindow.rootViewController?.view.subviews.forEach { v in
                                        v.removeFromSuperview()
                                    }
                                    
                                    // Presenting next alert
                                    alertWindow.rootViewController?.view.addSubview(first)
                                    
                                    // Removing the added alert from the array
                                    sceneDelegate.alerts.removeFirst()
                                }
                            }
                        }
                    } else {
                        print("View is not appeared")
                        sceneDelegate.alerts.removeAll(where: { $0.tag == viewTag })
                    }
                }
            }
    }
}


struct GlobalAlert<Content: View>: View {
    @Binding var config: GlobalAlertConfiguration
    
    var tag: Int
    @ViewBuilder var content: () -> Content
    @State private var show: Bool = false
    
    var body: some View {
        GeometryReader { gp in
            ZStack {
                if config.enableBackgroundBlur {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                } else {
                    Rectangle()
                        .fill(.primary.opacity(0.25))
                }
            }
            .ignoresSafeArea()
            .contentShape(.rect)
            .onTapGesture {
                if config.tapOutsideToDismiss {
                    config.dismiss()
                }
            }
            .opacity(show ? 1 : 0)
            
            if show && config.transition == .slide {
                content()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.move(edge: config.slideEdge))
            } else {
                content()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .opacity(show ? 1 : 0)
            }
        }
        .onAppear {
            config.displayContent = true
        }
        .onChange(of: config.displayContent) { oldValue, newValue in
            withAnimation(.smooth(duration: 0.35, extraBounce: 0)) {
                show = newValue
            }
        }
    }
}

struct GlobalAlertConfiguration {
    fileprivate var enableBackgroundBlur: Bool = false
    fileprivate var tapOutsideToDismiss: Bool = true
    fileprivate var transition: Transition = .slide
    fileprivate var slideEdge: Edge = .bottom
    fileprivate var show: Bool = false
    fileprivate var displayContent: Bool = false
    
    init(enableBackgroundBlur: Bool = false,
         tapOutsideToDismiss: Bool = true,
         transition: Transition = .slide,
         slideEdge: Edge = .bottom) {
        
        self.enableBackgroundBlur = enableBackgroundBlur
        self.tapOutsideToDismiss = tapOutsideToDismiss
        self.transition = transition
        self.slideEdge = slideEdge
    }
    
    enum Transition {
        case slide, opacity
    }
    
    mutating func present() { show = true }
    mutating func dismiss() { show = false }
}
