//
//  AddContactFeature.swift
//  AppFeature
//
//  Created by Heecheon Park on 9/26/25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct AddContactFeature {

    @ObservableState
    struct State: Equatable {
        var contact: Contact
    }

    enum Action {
        case saveButtonTapped
        case delegate(Delegate)
        case cancelButtonTapped
        case setName(String)

        enum Delegate: Equatable {
            case saveContact(Contact)
        }
    }

    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .saveButtonTapped:
                return .run { [contact = state.contact] dispatch in
                    await dispatch(.delegate(.saveContact(contact)))
                    await self.dismiss()
                }

            case .cancelButtonTapped:
                return .run { _ in await self.dismiss() }

            case .delegate: return .none

            case let .setName(name):
                state.contact.name = name
                return .none
            }
        }
    }
}

struct AddContactView: View {
    @Bindable var store: StoreOf<AddContactFeature>

    var body: some View {
        Form {
            TextField("name", text: $store.contact.name.sending(\.setName))
            Button("Save") {
                store.send(.saveButtonTapped)
            }
        }
        .toolbar {
            ToolbarItem {
                Button("Cancel") {
                    store.send(.cancelButtonTapped)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AddContactView(
            store: Store(
                initialState: AddContactFeature.State(
                    contact: Contact(
                        id: UUID(),
                        name: "Blob"
                    )
                )
            ) {
                AddContactFeature()._printChanges()
            }
        )
    }
}
