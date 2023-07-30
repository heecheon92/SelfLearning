import UIKit

struct MemoryAddress<T>: CustomStringConvertible {
    
    let intValue: Int
    let hexValue: String
    
    var description: String {
        let length = 2 + 2 * MemoryLayout<UnsafeRawPointer>.size
        return String(format: "%0\(length)p", intValue)
    }
    
    // for structures
    init(of structPointer: UnsafePointer<T>) {
        intValue = Int(bitPattern: structPointer)
        let strHexValue = String(format: "%llx", intValue)
        var tmpHexValue = ""
        tmpHexValue = strHexValue
        repeat {
            tmpHexValue = "0\(tmpHexValue)"
        } while (tmpHexValue.count < 16)
        tmpHexValue = "0x\(tmpHexValue)"
        hexValue = tmpHexValue
    }
}

extension MemoryAddress where T: AnyObject {
    
    // for classes
    init(of classInstance: T) {
        intValue = unsafeBitCast(classInstance, to: Int.self)
        // or      Int(bitPattern: Unmanaged<T>.passUnretained(classInstance).toOpaque())
        let strHexValue = String(format: "%llx", intValue)
        var tmpHexValue = ""
        tmpHexValue = strHexValue
        repeat {
            tmpHexValue = "0\(tmpHexValue)"
        } while (tmpHexValue.count < 16)
        tmpHexValue = "0x\(tmpHexValue)"
        hexValue = tmpHexValue
    }
}

enum WrapperType: String { case c = "class", s = "struct" }
struct WrappedContent { let description = "this is a wrapped content" }
struct Wrapped {
    let type: WrapperType
    
    init(_ t: WrapperType) { self.type = t }
    
    lazy var content: WrappedContent = {
        var w = WrappedContent()
        self.description = "\(w.description): \(self.type.rawValue)"
        print("Content accessed: \(String(describing: self.description))")
        return w
    }()
    
    var description: String? = nil
}

class TestClass {
    private var wrapped = Wrapped(.c)
    var description: String? { wrapped.description }
    var content: WrappedContent { wrapped.content }
    
    init() {
        print("\ninit class: \(MemoryAddress(of: self))")
    }
}

struct TestStruct {
    private var wrapped = Wrapped(.s)
    var description: String? { wrapped.description }
    var content: WrappedContent { mutating get { wrapped.content } }
    
    init() {
        print("init struct: \(MemoryAddress(of: &self))")
    }
}

var c = TestClass()
var s = TestStruct()

print("\naddress class: \(MemoryAddress(of: c))")
print("address struct: \(MemoryAddress(of: &s))\n")

print("\n\(String(describing: c.description))")
print("\(String(describing: s.description))\n")

print("\n\(String(describing: c.content))")   // Lazily load c.description
print("\(String(describing: s.content))\n")   // Lazily load s.description

print("\n\(String(describing: c.description))")
print("\(String(describing: s.description))\n")
