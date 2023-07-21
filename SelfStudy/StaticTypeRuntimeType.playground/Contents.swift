import UIKit

// Compile 타임에 변수에 선언한 자료형으로 (existential type) 나오는지 확인....
func staticType<T>(of value: T) -> T.Type {
    return T.self
}

// Concrete 타입으로 찍히는지 확인하려 했으나 type constraint를 걸지 않으면
// 파라미터를 existential type으로 인식하는 듯?
// i.e "func runtimeType(of value: any Foo) -> Foo.Type"
func runtimeType<T>(of value: T) -> T.Type {
    return type(of: value)
}

// Runtime concrete type나오게 하려면 type constraint를 걸어야 함...
func runtimeTypeEx(of value: some Foo) -> Foo.Type {
    return type(of: value)
}

protocol Foo {}
struct Bar: Foo {}

let bar: Bar = Bar()
print("CT: \(staticType(of: bar)), RT: \(runtimeType(of: bar)), RTEx: \(runtimeTypeEx(of: bar))")

let foo: Foo = Bar()
print("CT: \(staticType(of: foo)), RT: \(runtimeType(of: foo)), RTEx: \(runtimeTypeEx(of: foo))")
