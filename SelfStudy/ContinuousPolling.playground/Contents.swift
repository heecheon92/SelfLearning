import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

var runLoopCount = 0

class Record {
    var count = 0
}

let record = Record()

let timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
    print("timer: record.count == \(record.count)")
    record.count += 1
}

let runLoop = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
    if runLoopCount == 10 {
        runLoop.invalidate()
        timer.invalidate()
        PlaygroundPage.current.finishExecution()
    }
    runLoopCount += 1
    
    print("runLoop: record.count == \(record.count)")
    record.count += 1
}



