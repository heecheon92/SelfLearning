//
//  onChangeSecondView.swift
//  onChangeDemo
//
//  Created by Heecheon Park on 2022/06/30.
//

import SwiftUI

/// 벡조드는 상태 변수의 변경을
/// Binding 변수의 set 클로져와
/// State 변수의 didSet 클로져를 이용해서 해결 했습니다.
/// 원하는 동작대로 잘 동작하지만 이럴 경우 변화를 관측해야하는
/// 변수가 늘어나면 코드 사이즈가 급격하게 늘어나게 됩니다.
/// 때문에 onChange modifier가 13에서도 돌아갈 수 있도록 구현했습니다. (onChangeExtension.swift)
struct onChangeSecondView: View {
    @State var txt = "" {
        didSet {
            self.isValidNumber = oldValue == validNumber
        }
    }
    @State var isValidNumber = false
    
    let validNumber = "99999"
    
    var body: some View {
        
        VStack {
            TextField("숫자", text: Binding<String>(
                get: { self.txt },
                set: { self.txt = $0 }))
            
            Button(action: {}, label: {
                Text(isValidNumber ? "Ok" : "Not Ok")
            })
            .disabled(isValidNumber)
        }
    }
}

struct onChangeSecondView_Previews: PreviewProvider {
    static var previews: some View {
        onChangeSecondView()
    }
}
