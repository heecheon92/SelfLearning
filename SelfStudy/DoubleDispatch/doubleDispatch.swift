import Foundation

final class Processor {
  func process(_ obj: BaseClass) { 
    print("got a base object")
    obj.myFunction()
  }

  func process(_ obj: Derived1) {
    print("got a derived1 object")
    obj.myFunction()
  }

  func process(_ obj: Derived2) {
    print("got a derived2 object")
    obj.myFunction()
  }
}

class BaseClass {
  func myFunction() { print("BaseClass myFunction called") }
  func process(with proc: Processor){ proc.process(self) }
}

class Derived1: BaseClass {
  override func myFunction() { print("Derived1 myFunction called") }
  override func process(with proc: Processor){ proc.process(self) }
}

class Derived2: BaseClass {
  override func myFunction() { print("Derived2 myFunction called") }
  override func process(with proc: Processor){ proc.process(self) }
}

class Derived3: BaseClass {
  override func myFunction() { print("Derived3 myFunction called") }
  override func process(with proc: Processor){ proc.process(self) }
}

let p: Processor = Processor()

//first set results
let bc: BaseClass = BaseClass()
let dc1: Derived1 = Derived1()
let dc2: Derived2 = Derived2()
let dc3: Derived3 = Derived3()
p.process(bc)
p.process(dc1)
p.process(dc2)
p.process(dc3)

print("\n\n")

//second set results
let bc_1: BaseClass = bc
let dc1_1: BaseClass = dc1
let dc2_1: BaseClass = dc2
let dc3_1: BaseClass = dc3
p.process(bc_1)
p.process(dc1_1)
p.process(dc2_1)
p.process(dc3_1)

print("\n\n")

bc_1.process(with: p)
dc1_1.process(with: p)
dc2_1.process(with: p)
dc3_1.process(with: p)