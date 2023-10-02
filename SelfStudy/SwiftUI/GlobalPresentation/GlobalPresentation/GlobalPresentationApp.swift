//
//  GlobalPresentationApp.swift
//  GlobalPresentation
//
//  Created by Heecheon Park on 11/9/22.
//

import SwiftUI

final class PresentationContext: ObservableObject {
    
    @Published var showGlobalView = false
}

@main
struct GlobalPresentationApp: App {
    
    @StateObject var presentationContext = PresentationContext()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(presentationContext)
                .globalSheet(isActive: $presentationContext.showGlobalView) {
                    GlobalView()
                }
        }
    }
}

struct GlobalView: View {
    
    var body: some View {
        Button(action: {
            print("Test from GlobalView")
        }, label: {
            Text("This view can be displayed from any view")
        })
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
                                        isPresented: $isPresented)
                    vcHolder?.present(content: contentToPresent)
                } else {
                    vcHolder?.dismiss()
                }
            }
    }
}

struct VCHolder {
    unowned var vc: UIViewController?
    @Binding var isPresented: Bool
    
    func present(@ViewBuilder content: @escaping () -> some View) {
        let hostingVC = CustomHostingController(rootView: content(), isPresented: $isPresented)
        vc?.present(hostingVC, animated: true)
    }
    
    func dismiss() {
        vc?.presentedViewController?.dismiss(animated: true)
    }
}

extension View {
    
    @ViewBuilder
    func globalSheet(isActive: Binding<Bool>, content: @escaping () -> some View) -> some View {
        modifier(TopMostViewModifier(isPresented: isActive, contentToPresent: content))
    }
}

final class CustomHostingController<T: View>: UIHostingController<T>,
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
