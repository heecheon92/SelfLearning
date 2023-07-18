import Foundation

protocol TestProcotol {
    
    associatedtype WrappedType
    var description: String { get }
    var wrappedValue: WrappedType { get }
    var _description: String { get }
}

extension TestProcotol {
    var _description: String {
        "This is \(wrappedValue) -- \(type(of: self))"
    }
}

struct TestA: TestProcotol {
    var wrappedValue: Int
    
    typealias WrappedType = Int
    
    var description: String {
        "This is integer \(wrappedValue) -- \(type(of: self))"
    }
}

struct TestB: TestProcotol {
    var wrappedValue: String
    
    typealias WrappedType = String
    
    var description: String {
        "This is string \(wrappedValue) -- \(type(of: self))"
    }
}

func getOpaqueA() -> some TestProcotol { TestA(wrappedValue: 1) }
func getOpaqueB() -> some TestProcotol { TestB(wrappedValue: "2") }

func getExistentialA() -> any TestProcotol { TestA(wrappedValue: 1) }
func getExistentialB() -> any TestProcotol { TestB(wrappedValue: "2") }

func testAsParameter(param: some TestProcotol) {
    print("\n\n")
    print("\(param.wrappedValue)")
    print("\n\n")
}

func testTwoParameters(paramOne: some TestProcotol, paramTwo: some TestProcotol) {
    print("\n\n")
    print("testTwoParameters")
    print("\n\n")
}

let oa = getOpaqueA()
let ob = getOpaqueB()

let ea = getExistentialA()
let eb = getExistentialB()

print(oa.description)
print(oa._description)
print(ob.description)
print(ob._description)

print(ea.description)
print(ea._description)
print(eb.description)
print(eb._description)

testAsParameter(param: oa)
testAsParameter(param: ob)
testAsParameter(param: ea)
testAsParameter(param: eb)

protocol GenericProtocol<T> {
    associatedtype T
}

class GenericClass<T>: GenericProtocol {
    typealias T = T
}


protocol SesameDeveloper {}
protocol TalkPlusDeveloper {}
class 희천: SesameDeveloper {}
class 민제: SesameDeveloper {}
class 톡플러스: TalkPlusDeveloper {}

func doCoding<T: SesameDeveloper>(developer: T) {
    print("코딩 완료")
}

func doCoding(dev: some SesameDeveloper) {
    print("코딩 완료")
}

func doCodingTwo(dev: SesameDeveloper) {}
