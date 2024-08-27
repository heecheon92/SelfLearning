//
//  Observation.swift
//  
//
//  Created by Heecheon Park on 8/27/24.
//

import Foundation

/// This file is to explore and understand mechanics of Observation framework
/// via reimplementation. (in a naive fashion)
/// For the purpose of understanding the basic scheme of the framework,
/// the reimplementation does not consider concurrency safety.

/// In real implementation, GLOBAL_ACCESS_LIST is not a true single global variable
/// but rather a per-thread-global . Refer to ThreadLocal.cpp and ThreadLocal.swift.
/// ThreadLocal.cpp: https://github.com/swiftlang/swift/blob/main/stdlib/public/Observation/Sources/Observation/ThreadLocal.cpp
/// ThreadLocal.swift: https://github.com/swiftlang/swift/blob/main/stdlib/public/Observation/Sources/Observation/ThreadLocal.swift
var GLOBAL_ACCESS_LIST: AccessList?
struct AccessList {
    struct Entry {
        var registrar: ObservationRegistrar
        var keyPaths: Set<AnyKeyPath> = []
    }
    
    var entries: [ObjectIdentifier: Entry] = [:]
    mutating func trackAccess(_ registrar: ObservationRegistrar, keyPath: AnyKeyPath) {
        let id = ObjectIdentifier(registrar)
        entries[id, default: Entry(registrar: registrar)].keyPaths.insert(keyPath)
    }
    func registerOnChange(_ onChange: @escaping @Sendable () -> Void) {
        let observationIds: Box<[ObjectIdentifier: ObservationRegistrar.Observation.ID]> = Box(value: [:]) // <-- wrap in a box to bypass concurrency issue.
        let processOnChange: @Sendable () -> Void = {
            onChange()
            for (registrarId, observationId) in observationIds.value {
                entries[registrarId]?.registrar.cancel(observationId)
            }
        }
        
        for entry in entries {
            let registrar = entry.value.registrar
            let keyPaths = entry.value.keyPaths
            let observationId = registrar.registerOnChange(keyPaths, processOnChange)
            observationIds.value[entry.key] = observationId
        }
    }
}

protocol Observable {}
final class ObservationRegistrar : @unchecked Sendable {
    
    struct Observation: Identifiable {
        let id: UUID = UUID()
        let keyPaths: Set<AnyKeyPath>
        let closure: @Sendable () -> Void
    }
    
    var lookups: [AnyKeyPath: Set<Observation.ID>] = [:]
    var observations: [Observation.ID: Observation] = [:]
    
    func access<Subject, Member>(_ subject: Subject,
                                 keyPath: KeyPath<Subject, Member>) where Subject : Observable {
        GLOBAL_ACCESS_LIST?.trackAccess(self, keyPath: keyPath)
        print("access(\(keyPath))")
    }
    func withMutation<Subject, Member, T>(of subject: Subject,
                                          keyPath: KeyPath<Subject, Member>,
                                          _ mutation: () throws -> T) rethrows -> T where Subject : Observable {
        print("withMutation(\(keyPath))")
        if let observationIds = lookups.removeValue(forKey: keyPath) {
            for observationId in observationIds {
                if let observation = observations.removeValue(forKey: observationId) {
                    observation.closure()
                    for keyPath in observation.keyPaths {
                        lookups[keyPath]?.remove(observation.id)
                        
                        if (lookups[keyPath]?.isEmpty ?? false) {
                            lookups.removeValue(forKey: keyPath)
                        }
                    }
                }
            }
        }
        return try mutation()
    }
    
    /// - create a new wrapped onChange
    ///     - call the initial onChange
    ///     - remove the callbacks from evey associated object
    /// - stash it into the registrars of every associated object
    func registerOnChange(_ keyPaths: Set<AnyKeyPath>, _ onChange: @escaping @Sendable () -> Void) -> Observation.ID {
        let observation = Observation(keyPaths: keyPaths, closure: onChange)
        observations[observation.id] = observation
        for keyPath in keyPaths {
            lookups[keyPath, default: []].insert(observation.id)
        }
        return observation.id
    }
    
    func cancel(_ observationId: Observation.ID) {
        print("CANCEL \(observationId)")
        if let observation = observations.removeValue(forKey: observationId) {
            for keyPath in observation.keyPaths {
                lookups[keyPath]?.remove(observation.id)
                
                if (lookups[keyPath]?.isEmpty ?? false) {
                    lookups.removeValue(forKey: keyPath)
                }
            }
        }
    }
}

/// This class is to bypass concurrency safety issue for non-sendable value-types
/// to allow mutation in asynchronous context.
/// Do not use this kind of implementation in production.
final class Box<T>: @unchecked Sendable {
    var value: T
    init(value: T) {
        self.value = value
    }
}

func withObservationTracking<T>(_ apply: () -> T,
                                onChange: @escaping @Sendable () -> Void) -> T {
    
    /// 1. Set a ACCESS_LIST
    GLOBAL_ACCESS_LIST = AccessList()
    /// 2. call apply()
    let result = apply()
    ///     - obj.access(\.objKey)
    /// 3. USE ACCESS_LIST
    ///     - associate the closure
    ///     - give it the ability to cancel all callbacks
    
    GLOBAL_ACCESS_LIST?.registerOnChange(onChange)
    return result
}

class Suspect: Observable {
    
    var name: String {
        get {
            access(keyPath: \.name)
            return _name
        }
        set {
            withMutation(keyPath: \.name) {
                _name = newValue
            }
        }
    }
    var suspiciousness: Int {
        get {
            access(keyPath: \.suspiciousness)
            return _suspiciousness
        }
        set {
            withMutation(keyPath: \.suspiciousness) {
                _suspiciousness = newValue
            }
        }
    }
    init(name: String, suspiciousness: Int) {
        self.name = name
        self.suspiciousness = suspiciousness
    }
    
    /// Below are properties that are auto-generated if the class is
    /// declared with @Observable macro.
    private let _$observationRegistrar = ObservationRegistrar()
    internal nonisolated func access<Member>(
        keyPath: KeyPath<Suspect , Member>
    ) {
        _$observationRegistrar.access(self, keyPath: keyPath)
    }
    internal nonisolated func withMutation<Member, MutationResult>(
        keyPath: KeyPath<Suspect , Member>,
        _ mutation: () throws -> MutationResult
    ) rethrows -> MutationResult {
        try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
    }
    private var _name: String = ""
    private var _suspiciousness: Int = 0;
}

let suspect = Suspect(name: "Glib Butler", suspiciousness: 33)
let suspect2 = Suspect(name: "Jimmy the Shrimp", suspiciousness: 10)

withObservationTracking {
    print("I am observing \(suspect.suspiciousness)")
} onChange: {
    print("Name/Suspciousness changed")
}

print("1")
suspect.name = "Jim Shrimp"
print("2")
suspect.suspiciousness = 300
print("3")
