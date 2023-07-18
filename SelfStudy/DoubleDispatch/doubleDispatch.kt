open class BaseClass {
    open fun myFunction() {
        println("BaseClass myFunction called")
    }

    open fun process(proc: Processor) {
        proc.process(this)
    }
}

class Derived1 : BaseClass() {
    override fun myFunction() {
        println("Derived1 myFunction called")
    }

    override fun process(proc: Processor) {
        proc.process(this)
    }
}

class Derived2 : BaseClass() {
    override fun myFunction() {
        println("Derived2 myFunction called")
    }

    override fun process(proc: Processor) {
        proc.process(this)
    }
}

class Derived3 : BaseClass() {
    override fun myFunction() {
        println("Derived3 myFunction called")
    }

    override fun process(proc: Processor) {
        proc.process(this)
    }
}

class Processor {
    fun process(obj: BaseClass) {
        println("got a base object")
        obj.myFunction()
    }

    fun process(obj: Derived1) {
        println("got a derived1 object")
        obj.myFunction()
    }

    fun process(obj: Derived2) {
        println("got a derived2 object")
        obj.myFunction()
    }
}

fun main() {
    val p = Processor()

    val bc: BaseClass = BaseClass()
    val dc1: Derived1 = Derived1()
    val dc2: Derived2 = Derived2()
    val dc3: Derived3 = Derived3()

    p.process(bc)
    p.process(dc1)
    p.process(dc2)
    p.process(dc3)
    
    println("\n\n")
    
    val bc_1: BaseClass = bc
    val dc1_1: BaseClass = dc1
    val dc2_1: BaseClass = dc2
    val dc3_1: BaseClass = dc3
    
    p.process(bc_1)
    p.process(dc1_1)
    p.process(dc2_1)
    p.process(dc3_1)
    
    println("\n\n")
    
    bc_1.process(p)
    dc1_1.process(p)
    dc2_1.process(p)
    dc3_1.process(p)
}