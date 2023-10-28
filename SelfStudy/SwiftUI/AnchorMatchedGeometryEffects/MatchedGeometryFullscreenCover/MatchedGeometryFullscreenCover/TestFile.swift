//
//  TestFile.swift
//  MatchedGeometryFullscreenCover
//
//  Created by Heecheon Park on 3/4/23.
//

import Foundation
import UIKit
import SwiftUI

extension UIApplication {
    var currentKeyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first
    }
    
    var rootViewController: UIViewController? {
        currentKeyWindow?.rootViewController
    }
    
    var visibleViewController: UIViewController? {
        while let presentVC = rootViewController?.presentedViewController {
            return presentVC
        }
        return rootViewController
    }
    
    func topViewController(base: UIViewController? = UIApplication.shared.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }

        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController
            { return topViewController(base: selected) }
        }

        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

struct TopMostViewModifier<T: View>: ViewModifier {
    
    @State var vcHolder: VCHolder?
    @Binding var isPresented: Bool
    let contentToPresent: () -> T
    
    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { newValue in
                if isPresented {
                    vcHolder = VCHolder(vc: UIApplication.shared.visibleViewController,
//                    vcHolder = VCHolder(vc: UIApplication.shared.topViewController(),
                                        isPresented: $isPresented)
                    vcHolder?.present(content: contentToPresent)
                } else {
                    vcHolder?.dismiss()
                }
            }
    }
}

struct VCHolder {
    var vc: UIViewController?
    @Binding var isPresented: Bool
    
    func present(@ViewBuilder content: @escaping () -> some View) {
        let hostingVC = HostingController(isPresented: $isPresented, rootView: content())
        hostingVC.modalPresentationStyle = .overCurrentContext
        hostingVC.modalTransitionStyle = .crossDissolve
        hostingVC.view.backgroundColor = .clear
        vc?.present(hostingVC, animated: false)
//        let hostingVC = TestHostingController(rootView: content(), isPresented: $isPresented)
//        vc?.present(hostingVC, animated: true)
    }
    
    func dismiss() {
        vc?.presentedViewController?.dismiss(animated: false)
    }
}

extension View {
    
    @ViewBuilder
    func globalPresentation(isActive: Binding<Bool>, content: @escaping () -> some View) -> some View {
        modifier(TopMostViewModifier(isPresented: isActive, contentToPresent: content))
    }
}

final class TestHostingController<T: View>: UIHostingController<T>,
                                              UIAdaptivePresentationControllerDelegate {
    
    @Binding var isPresented: Bool
    
    init(rootView: T, isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        super.init(rootView: rootView)
        
        print("HostingController Initailized")
    }
    
    deinit {
        print("HostingController Deinitialized")
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.presentationController?.delegate = self
    }
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print("Did dismiss with swipe")
        isPresented = false
    }
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        print("Will dismiss with swipe")
    }
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        print("Did attempt to dismiss with swipe")
    }
}
