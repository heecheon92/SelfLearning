//
//  onChangeExtension.swift
//  onChangeDemo
//
//  Created by Heecheon Park on 2022/06/30.
//

import SwiftUI
import Combine

extension View {
    @_disfavoredOverload
    @ViewBuilder
    func onChange<T>(of value: T, _ onChangeCb: @escaping (_ :T)->()) -> some View where T: Equatable {
        // iOS 14 일 경우 기존 시스템 API를 그대로 사용하도록 합니다.
        if #available(iOS 14.0, *) {
            onChange(of: value, perform: { newVal in onChangeCb(newVal) })
        } else {
            // iOS 13 이하일 경우엔 커스텀 ViewModifier를 붙입니다.
            modifier(_ChangeObserver(value: value, cb: onChangeCb))
        }
    }
}


// iOS 13에선 onChange modifier가 없을 뿐
// Combine Publisher가 던지는 값을 받는 onReceive modifier는 있습니다.
// 뷰에서 State 변수가 변화 될때 Combine Just publisher로 값을 래핑해서
// 뷰에다가 값이 변화 됬음을 알립니다.
struct _ChangeObserver<T: Equatable>: ViewModifier {
    private typealias onChangeCallback = (T) -> Void
    private let _value: T
    private let _action: onChangeCallback
    @State private var _state : (T, onChangeCallback)?
    init(value: T, cb: @escaping (T) -> Void) {
        self._value = value
        self._action = cb
    }
    func body(content: Content) -> some View {
        if #available(iOS 14, *) {
            assertionFailure("This view modifier MUST be used iOS less than 14. Please use .onChange(of: perform:) modifier instead.")
        }
        return content
            .onReceive(Just(_value).receive(on: DispatchQueue.main)) { newValue in
                if let (currentValue, action) = _state,
                   newValue != currentValue {
                    action(newValue)
                }
                _state = (newValue, _action)
            }
    }
}
