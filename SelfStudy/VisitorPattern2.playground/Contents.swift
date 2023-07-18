import Foundation

protocol ComputerEquipment {
    var name: String { get }
    func accept(_ visitor: any ComputerEquipmentVisitor)
}

protocol ComputerEquipmentVisitor {
    func visit(_ equipment: any ComputerEquipment)
}

class OS: ComputerEquipmentVisitor {
    func visit(_ equipment: any ComputerEquipment) {
        print("OS visited: \(equipment.name) - type: \(type(of: equipment)))")
    }
}

class Engineer: ComputerEquipmentVisitor {
    func visit(_ equipment: any ComputerEquipment) {
        print("Engineer visited: \(equipment.name) - type: \(type(of: equipment)))")
    }
}

class CPU: ComputerEquipment {
    var name = "cpu"
    func accept(_ visitor: any ComputerEquipmentVisitor) {
        visitor.visit(self)
    }
}

class RAM: ComputerEquipment {
    var name = "ram"
    func accept(_ visitor: any ComputerEquipmentVisitor) {
        visitor.visit(self)
    }
}

class Keyboard: ComputerEquipment {
    var name = "keyboard"
    func accept(_ visitor: any ComputerEquipmentVisitor) {
        visitor.visit(self)
    }
}

let os = OS()
let engineer = Engineer()

let visitors: [any ComputerEquipmentVisitor] = [os, engineer]
let components: [any ComputerEquipment] = [
    CPU(), RAM(), Keyboard()
]

components.forEach { comp in visitors.forEach { comp.accept($0) } }
