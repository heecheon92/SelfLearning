import Foundation
import PlaygroundSupport

func fib(_ n: Int) async -> Int {
    if (n < 2) { return n }
    return (await fib(n - 1)) + (await fib(n - 2))
}

func fib(_ n: Int) -> Int {
    if (n < 2) { return n }
    return fib(n - 1) + fib(n - 2)
}

var count = 0
let t = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
    count += 1
    print("\(count) second passed")
}

Task {
    print(await fib(28), Thread.isMainThread)
    print("Task done")
    t.invalidate()
    PlaygroundPage.current.needsIndefiniteExecution = false
    PlaygroundPage.current.finishExecution()
}
//print(fib(26), Thread.isMainThread)   // <- 이 코드를 실행하면 타이머 출력 스레드가 block됨.

PlaygroundPage.current.needsIndefiniteExecution = true
