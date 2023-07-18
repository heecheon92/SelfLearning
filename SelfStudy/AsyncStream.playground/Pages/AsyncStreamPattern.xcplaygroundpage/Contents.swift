import PlaygroundSupport
import Foundation

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
    private(set) lazy var eventStream: AsyncStream<Event> = {
        AsyncStream { (continuation: AsyncStream<Event>.Continuation) -> Void in
            self.eventContinuation = continuation
            self.eventContinuation?.onTermination = { termination in
                switch termination {
                    case .cancelled: fallthrough
                    case .finished: self.eventContinuation = nil
                }
            }
        }
    }()
    private var eventContinuation: AsyncStream<Event>.Continuation?
    private(set) var isPublishing = false
    
    func startPublishing() { isPublishing = true }
    func stopPublishing() { isPublishing = false }
    
    func onEventStart(_ event: Event) { eventContinuation?.yield(event) }
    func onEventFinish(_ event: Event) { eventContinuation?.finish() }
}

// MARK: Client Code Begin
let monitor: EventMonitor = EventMonitor()
let eventTask = Task {
    for await event in monitor.eventStream {
        print("\(type(of: event)) \(type(of: event).id): event didStart")
    }
}
monitor.startPublishing()

// MARK: RunLoop
Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
    let event = TestEvent()
    if monitor.isPublishing {
        monitor.onEventStart(event)
    } else {
        monitor.onEventFinish(event)
        print(monitor.eventStream)
        PlaygroundPage.current.finishExecution()
    }
    
    if TestEvent.id == 10 {
        monitor.stopPublishing()
        eventTask.cancel()
    }
}
