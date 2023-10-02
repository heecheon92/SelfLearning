//
//  ContentView.swift
//  test
//
//  Created by Heecheon Park on 6/25/22.
//

import SwiftUI
import Combine

protocol DemoViewModel {
    
    /// 뷰에 뿌려줘야할 데이터를 비즈니스 로직을 처리 한 후
    /// 해당 로직에 따라 뿌려줘야 할 데이터를 웹으로 부터
    /// 페칭하는 함수라고 가정합니다.
    /// 뷰모델이 아래 함수를 뷰가 뜨기 전에 (i.e. 뷰모델의 초기화 함수에)
    /// 미리 데이터를 페칭 함 으로서
    /// 화면에 뷰를 표출할때의 화면 전환 시간을 줄일 수 있습니다.
    func runBusinessLogic() -> Void
}

class ViewModelOne: ObservableObject, DemoViewModel {
    
    func runBusinessLogic() {
        self.text = String("\(Int.random(in: 0...100))")
    }
    
    @Published var text = "one"
    
    init(){
        print("ViewModelOne init")
        self.runBusinessLogic()
    }
}

class ViewModelTwo: ObservableObject, DemoViewModel {
    func runBusinessLogic() {
        self.text = String("\(Int.random(in: 0...100))")
    }
    
    @Published var text = "two"
    
    init(){
        print("ViewModelTwo init")
        self.runBusinessLogic()
    }
}

class ViewModelThree: ObservableObject, DemoViewModel {
    func runBusinessLogic() {
        self.text = String("\(Int.random(in: 0...100))")
    }
    
    @Published var text = "three"
    
    init(){
        print("ViewModelThree init")
        self.runBusinessLogic()
    }
}

class ViewModelFour: ObservableObject, DemoViewModel {
    func runBusinessLogic() {
        self.text = String("\(Int.random(in: 0...100))")
    }
    
    @Published var text = "four"
    
    init(){
        print("ViewModelFour init")
        self.runBusinessLogic()
    }
}

class MasterViewModel: ObservableObject, DemoViewModel {
    func runBusinessLogic() {
        self.text = String("\(Int.random(in: 100...1000))")
    }
    
    @Published var text = "master"
    
    init(){
        print("MasterViewModel init")
        self.runBusinessLogic()
    }
}

struct ContentView: View {
    
    @StateObject var vmMaster = MasterViewModel()
    @State private var testVar: String = ""
    @State var showNextView: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                TextField("아무거나 입력 해주세요", text: $testVar)
                    .padding()
                
                /// testVar 상태 변수가 변경될때 변경된 내역을 화면에 업데이트 및 렌더링 하기 위해
                /// ContentView의 body 변수가 호출 되는데
                /// 이때 ChildViewOne과 ChildViewTwo가 재생성 됩니다.
                /// 문제는 ChildViewOne의 뷰 모델은 StateObject로 생성되기 때문에 ChildViewOne은
                /// 재생성 된다 하더라도 뷰모델이 재초기화가 되지 않아 멤버 변수로 들고 있는 @Published 변수를
                /// 재사용 가능하지만 ChildViewTwo의 경우를 ObservedObject로 생성되기 때문에
                /// ChildViewTwo가 재생성 될때 ChildViewTwo가 들고 있는 뷰모델 또한 재초기화가 일어 납니다.
                /// 키링 iOS 에서 ChildView의 해당되는 뷰를 리팩토링 할 경우 StateObject를 이용한 뷰모델 초기화를
                /// 사용하지 않는다면 ParentView의 상태 값이나 ParentView의 뷰모델의 멤버 변수가 변경될때마다
                /// ChildView의 ViewModel이 재 초기화가 일어나게 되므로 예상치 못한 사이드가 생길 수 있습니다.
                /// 물론 View의 onAppear / onDisappear의 라이프 사이클을 이용하거나
                /// 모든 뷰모델을 최상위 뷰에서 초기화 시키고 (또는 전역 및 싱글턴 객채로 초기화 하고) ChildView로 의존성 주입을 해서 넘기는 편법으로
                /// 문제 해결은 되지만 결코 깔끔한 해결 방법은 아닌거 같습니다.
                ChildViewOne()
                    .padding()
                
                ChildViewTwo()
                    .padding()
                
                NavigationLink(isActive: self.$showNextView, destination: {
                    ContentViewTwo(vmMaster: self.vmMaster)
                }, label: {
                    Text("다음 화면으로 넘어가기")
                })
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct ContentViewTwo: View {
    @ObservedObject var vmMaster: MasterViewModel
    
    var body: some View {
        VStack {
            
            ChangeMasterViewModelButton()
                .padding()
            
            ChildViewThree()
                .padding()
            
            ChildViewFour()
                .padding()
        }
    }
    
    @ViewBuilder func ChangeMasterViewModelButton() -> some View {
        HStack {
            Button(action: {
                vmMaster.runBusinessLogic()
            }, label: {
                Text("MasterViewModel의 비즈니스 로직 실행하기")
            })
        }
    }
}

struct ChildViewOne: View {
    
    @StateObject var vmOne = ViewModelOne()
    
    init() {
        print("ChildViewOne init")
    }
    
    var body: some View {
        Text(vmOne.text)
    }
}

struct ChildViewTwo: View {
    @ObservedObject var vmTwo = ViewModelTwo()
    
    init() {
        print("ChildViewTwo init")
    }
    
    var body: some View {
        Text(vmTwo.text)
    }
}

struct ChildViewThree: View {
    @StateObject var vmThree = ViewModelThree()
    
    init() {
        print("ChildViewThree init")
    }
    
    var body: some View {
        Text(vmThree.text)
    }
}

struct ChildViewFour: View {
    @ObservedObject var vmFour = ViewModelFour()
    
    init() {
        print("ChildViewFour init")
    }
    
    var body: some View {
        Text(vmFour.text)
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


