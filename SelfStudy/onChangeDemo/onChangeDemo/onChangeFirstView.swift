//
//  onChangeFirstView.swift
//  onChangeDemo
//
//  Created by Heecheon Park on 2022/06/30.
//

import SwiftUI


/// 아래의 텍스트 필드는 txt 상태 변수와 Bind 되어 있습니다.
/// TextField의 bind된 변수가 업데이트 되면 txt 변수도 같이 업데이트가 됩니다.
///  TextField 아래에는 버튼이 있는데 이 버튼은 텍스트 필드에 "99999" 가 입력이 되어야만
///  활성화가 됩니다. 매번 텍스트를 칠때마다 해당 텍스트가 valid한 텍스트 인지 확인 해야 하는데
/// 이러한 동작은 iOS 14부터 지원되는 onChange(of: txt, perform: 핸들러) 를 사용하면 상태값이
/// 변할때마다 콜백함수를 통해 이벤트 처리가 간단하게 처리되지만 iOS 13에선 이 기능이 없습니다.
/// 이 문제를 벡조드는 onChangeSecondView 처럼 해결 했습니다.
struct onChangeFirstView: View {
    
    @State var txt = ""
    @State var isValidNumber = false
    
    let validNumber = "99999"
    
    var body: some View {

        VStack {
            TextField("숫자", text: $txt)
            
            Button(action: {}, label: {
                Text(isValidNumber ? "Ok" : "Not Ok")
            })
            .disabled(isValidNumber)
        }
        /// iOS 14 이상부터 사용 가능
        /// 매번 텍스트가 변경될때마다 호출됩니다.
        .onChange(of: txt) { value in

            self.isValidNumber = value == validNumber
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        onChangeFirstView()
    }
}
