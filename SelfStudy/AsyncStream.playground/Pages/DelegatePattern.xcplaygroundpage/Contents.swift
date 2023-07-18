import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// MARK: Library Code Begin
protocol Event {
    static var id: Int { get set }
}

struct TestEvent: Event {
    static var id = 0
    init() { Self.id += 1 }
}

protocol EventDelegate: AnyObject {
    func didStart(_ event: Event)
    func didFinish(_ event: Event)
}

final class EventMonitor {
    weak var eventDelegate: (any EventDelegate)?
    
    private(set) var isPublishing = false
    
    func startPublishing() { isPublishing = true }
    func stopPublishing() { isPublishing = false }
    
    func onEventStart(_ event: Event) { eventDelegate?.didStart(event) }
    func onEventFinish(_ event: Event) { eventDelegate?.didFinish(event) }
}

// MARK: Client Code Begin
final class DefaultEventDelegate: EventDelegate {
    func didStart(_ event: Event) {
        print("\(type(of: self)) \(type(of: event).id): event didStart")
    }
    
    func didFinish(_ event: Event) {
        print("\(type(of: self)) \(type(of: event).id): event didFinish")
    }
}

let delegate: EventDelegate = DefaultEventDelegate()
let monitor: EventMonitor = EventMonitor()
monitor.eventDelegate = delegate
monitor.startPublishing()


// MARK: RunLoop
Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
    let event = TestEvent()
    if monitor.isPublishing {
        monitor.onEventStart(event)
    } else {
        monitor.onEventFinish(event)
        PlaygroundPage.current.finishExecution()
    }
    
    if TestEvent.id == 10 { monitor.stopPublishing() }
}


