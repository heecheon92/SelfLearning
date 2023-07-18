//
//  ContentView.swift
//  MatchedGeometryFullscreenCover
//
//  Created by Heecheon Park on 3/4/23.
//

import SwiftUI

let uuid = "demo"

struct ContentView: View {
    
    var body: some View {
        // MatchedGeometryEffect with FullscreenCover only works if and only if
        // both parent view and matched child view are nested within
        // either NavigationStack or NavigationView
        
        //        NavigationStack {
        NavigationView {
            MatchedGeometryParentView()
                .navigationBarHidden(true)
        }
    }
}

struct MatchedGeometryParentView: View {
    @State private var shapeId = 0
    @State private var showPresentation = false
    @State private var showTestPresentation = false
    @Namespace var geometry
    var body: some View {
        VStack {
            if shapeId == 0 {
                Rectangle()
                    .fill(Color.green)
                    .matchedGeometryEffect(id: uuid, in: geometry)
                    .frame(width: 100, height: 100)
            } else {
                Color.clear
                    .frame(width: 100, height: 100)
            }
            
            Button(action: {
                withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.8)) {
                    shapeId = shapeId == 0 ? 1 : 0
                    showPresentation = true
                }
            }, label: {
                Text("Present")
            })
            
            Button(action: {
                withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.8)) {
                    shapeId = shapeId == 0 ? 1 : 0
                    showTestPresentation = true
                }
            }, label: {
                Text("Present Test")
            })
            .padding(.top)
            Spacer()
        }
        .padding()
        .matchedGeometryPresentation(isPresented: $showPresentation) {
            MatchedGeometryView(shapeId: $shapeId, isPresented: $showPresentation, namespace: geometry)
        }
        .globalPresentation(isActive: $showTestPresentation, content: {
            MatchedGeometryView(shapeId: $shapeId, isPresented: $showTestPresentation, namespace: geometry)
        })
    }
}

struct MatchedGeometryView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Binding var shapeId: Int
    @Binding var isPresented: Bool
    @State private var animateContent = false
    var namespace: Namespace.ID
    var body: some View {
        VStack {
            if animateContent {
                Rectangle()
                    .fill(Color.red)
                    .matchedGeometryEffect(id: uuid, in: namespace)
                    .frame(width: 100, height: 100)
                    .onTapGesture {
                        withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.8)) {
                            animateContent = false
                            shapeId = 0
//                            isPresented = false
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                            dismiss()
//                            UIApplication.shared.rootViewController?.dismiss(animated: true)
                        }
                    }
            } else {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 100, height: 100)
                    .onTapGesture {
                        withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.8)) {
                            animateContent = false
                            shapeId = 0
                            dismiss()
                        }
                    }
            }
        }
        .onAppear {
            withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.8)) {
                animateContent = true
            }
        }
    }
}

extension View {
    @ViewBuilder func matchedGeometryPresentation<T: View>(isPresented: Binding<Bool>,
                                                           @ViewBuilder content: () -> T) -> some View {
        self
            .modifier(MatchedGeometryPresentationModifier(isPresented: isPresented, overlay: content()))
    }
}

class HostingController<T: View>: UIHostingController<T> {
    
    @Binding var isPresented: Bool
    init(isPresented: Binding<Bool>, rootView: T) {
        self._isPresented = isPresented
        super.init(rootView: rootView)
    }
    
    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        isPresented = false
    }
}

struct MatchedGeometryPresentationModifier<T: View>: ViewModifier {
    @Binding var isPresented: Bool
    var overlay: T
    
    @State private var hostController: HostingController<T>?
    @State private var parentController: UIViewController?
    
    func body(content: Content) -> some View {
        content
            .background(ParentViewControllerExtractor(content: overlay,
                                                      hostController: $hostController,
                                                      onFetchParentController: { parentVC in
                parentController = parentVC
            }))
            .onAppear {
                hostController = HostingController(isPresented: $isPresented, rootView: overlay)
            }
            .onChange(of: isPresented) { newValue in
                if newValue {
                    if let hostController {
                        hostController.modalPresentationStyle = .overCurrentContext
                        hostController.modalTransitionStyle = .crossDissolve
                        hostController.view.backgroundColor = .clear
                        parentController?.present(hostController, animated: false)
                    }
                } else {
                    hostController?.dismiss(animated: false)
                }
            }
    }
}

struct ParentViewControllerExtractor<T: View>: UIViewRepresentable {
    
    var content: T
    @Binding var hostController: HostingController<T>?
    var onFetchParentController: (UIViewController?) -> Void
    
    func makeUIView(context: Context) -> some UIView {
        return UIView()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        hostController?.rootView = content
        DispatchQueue.main.async {
            onFetchParentController(uiView.superview?.superview?.parentController)
        }
    }
}

extension UIView {
    var parentController: UIViewController? {
        var responder = self.next
        while responder != nil {
            if let responder = responder as? UIViewController { return responder }
            responder = responder?.next
        }
        return nil
    }
}
