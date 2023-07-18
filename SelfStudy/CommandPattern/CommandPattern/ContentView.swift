//
//  ContentView.swift
//  CommandPattern
//
//  Created by Heecheon Park on 7/22/22.
//

import SwiftUI

struct ContentView: View, ContentViewCommandReceiver {
    
    @State var updateValue: Bool = false
    @State var fetchedValue: TestModel? = nil
    
    var body: some View {
        
        VStack {
            Text(updateValue.description)
                .font(.largeTitle)
            
            Button(action: {
                let command = UpdateValueButtonCommand(target: self)
                command.execute()
            }, label: {
                Text("Update")
                    .font(.title)
            })
            
            Text(fetchedValue?.success?.description ?? "No Value yet")
                .font(.largeTitle)
                .redacted(reason: fetchedValue == nil ? .placeholder : [])
            
            Button(action: {
                Task {
                    let command = AsyncFetchCommand(target: self)
                    await command.execute()
                }
            }, label: {
                Text("Fetch")
                    .font(.title)
            })
        }
        
    }
}


protocol CommandReceiver {}
protocol ContentViewCommandReceiver: CommandReceiver {
    var updateValue: Bool { get set }
    var fetchedValue: TestModel? { get set }
}

protocol Command {
    func execute() -> Void
}
extension Command {
    func execute() -> Void {}
}
protocol ButtonPressCommand: Command {
    var target: ContentViewCommandReceiver { get set }
    func execute() -> Void
}
protocol AsyncCommand: Command {
    func execute() async -> Void
}

final class UpdateValueButtonCommand: ButtonPressCommand {
    var target: ContentViewCommandReceiver
    init(target: ContentViewCommandReceiver) {
        self.target = target
    }
    func execute() {
        self.target.updateValue.toggle()
    }
}
actor AsyncFetchCommand: AsyncCommand {
    var target: ContentViewCommandReceiver
    init(target: ContentViewCommandReceiver) {
        self.target = target
    }
    
    @MainActor
    func execute() async {
        do {
            let (data, _) = try await URLSession.shared.data(for: URLRequest(url: URL(string: "https://reqbin.com/echo/get/json")!))
            let res = try JSONDecoder().decode(TestModel.self, from: data)
            await self.target.fetchedValue = res
        } catch { print("Fetch Error") }
    }
}

struct TestModel: Codable, Identifiable {
    var id = UUID()
    var success: String?
    
    enum CodingKeys: String, CodingKey {
        case success = "success"
    }
}
