import Foundation

protocol Visitable {
    associatedtype Visitee = Visitor
    func accept(_ visitor: Visitee)
}

protocol Visitor {
    associatedtype Node = Visitable
    func visit(_ place: Node)
}

protocol ComputerComponent  : Visitable where Visitee == any ComputerAccessor {}
protocol ComputerAccessor   : Visitor where Node == any ComputerComponent {}
protocol Building           : Visitable where Visitee == any BuildingVisitor {}
protocol BuildingVisitor    : Visitor where Node == any Building {}

/*
 protocol Apartment          : Building where Visitee == any Resident {}
 protocol Resident           : BuildingVisitor where Node == any Apartment {}
 -----------------------------------------------------------------------------
 Apartment protocol은 Building protocol을 만족하면서
 동시에 Visitee의 타입은 Resident protocol을 상속받는 자료형으로
 constraint / specialize를 하려했으나, 그럴경우 Apartment protocol은
 더이상 Building protocol을 상속 받을 수 없음... Building protocol의
 associatedtype "Visitee"는 "any BuildingVisitor"이지만
 Apartment protocol에 "Visitee == any Resident" 제약사항을 달면
 Swift compiler는 다음과 같은 문법을 처리할 방법이 없음....
 
 i.e.
 
 let visitor: BuildingVisitor = BuildingVisitor()
 let building: Building = Apartment()
 
 building.accept(visitor)  <<- Compiler가 처리할 수 없음....
 
 "building" 변수는 컴파일타임엔 "Building" 자료형이기 때문에 "BuildingVisitor"의
 자료형을 갖는 "visitor" 변수를 accept 함수에서 매개변수로 받을수 있지만.
 런타임에선 building의 구체타입은 Apartment이고 Apartment의 associatetype
 제약이 "any Resident"로 묶이게되면 BuildingVisitor를 상속받지만 Resident는
 상속받지 않는 타입이 들어오면 처리할 방법이 없음.....
 -----------------------------------------------------------------------------
 */

class CPU: ComputerComponent {
    func accept(_ visitor: any ComputerAccessor) {
        visitor.visit(self)
    }
}
class Keyboard: ComputerComponent {
    func accept(_ visitor: any ComputerAccessor) {
        visitor.visit(self)
    }
}
class Speaker: ComputerComponent {
    func accept(_ visitor: any ComputerAccessor) {
        visitor.visit(self)
    }
}
class Mainboard: ComputerComponent {
    func accept(_ visitor: any ComputerAccessor) {
        visitor.visit(self)
    }
}
class OS: ComputerComponent, ComputerAccessor {
    func accept(_ visitor: any ComputerAccessor) {
        visitor.visit(self)
    }
    
    func visit(_ place: any ComputerComponent) {
        print("OS visiting computer component: \(place)")
    }
}
class ComputerEngineer: ComputerAccessor {
    func visit(_ place: any ComputerComponent) {
        print("ComputerEngineer visiting computer component: \(place)")
    }
}

let computer: [any ComputerComponent] = [CPU(), Keyboard(), Speaker(), Mainboard(), OS()]
let engineer = ComputerEngineer()

computer.forEach { $0.accept(engineer) }
