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

class TestClass {
    var member: Int
    var memberStruct: TestStruct
    
    lazy var description: String = {
        print("lazy in class: \(MemoryAddress(of: self))")
        self.member = 999
        return "description accessed and changed the member variable"
    }()
    
    init(_ m: Int) {
        self.member = m
        self.memberStruct = TestStruct(m)
        print("init class: \(MemoryAddress(of: self))")
    }
}

struct TestStruct {
    var member: Int
    
    lazy var description: String = {
        print("lazy in struct: \(MemoryAddress(of: &self))")
        self.member = 999
        return "description accessed and changed the member variable"
    }()
    
    
    init(_ m: Int) {
        self.member = m
        print("init struct: \(MemoryAddress(of: &self))")
    }
}

// Init both class and struct with member property 1.
var c = TestClass(1)
var s = TestStruct(1)

print("\naddress class: \(MemoryAddress(of: c))")
print("address struct: \(MemoryAddress(of: &s))\n")

// Access lazy member "description" thereby mutating "member" property to 999
print(c.description)
print(s.description)

print(c.member) // prints 999 -> OK I got it
print(s.member) // prints 999 -> OK I got it

print(c.memberStruct.member)  // prints 1 -> Not OK, why member property didn't mutate?
