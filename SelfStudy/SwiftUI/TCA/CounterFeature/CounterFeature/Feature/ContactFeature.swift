//
//  ContactFeature.swift
//  AppFeature
//
//  Created by Heecheon Park on 9/26/25.
//

import ComposableArchitecture
import Foundation
import SwiftUI

struct Contact: Equatable, Identifiable {
    let id: UUID
    var name: String
}

@Reducer struct ContactFeature {

    @ObservableState struct State: Equatable {
        @Presents var addContact: AddContactFeature.State?
        @Presents var alert: AlertState<Action.Alert>?
        var contacts: IdentifiedArrayOf<Contact> = []
    }

    enum Action {
        case addButtonTapped
        case addContact(PresentationAction<AddContactFeature.Action>)
        case alert(PresentationAction<Alert>)
        case deleteButtonTapped(Contact.ID)
        enum Alert: Equatable {
            case confirmDeletion(id: Contact.ID)
        }
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                state.addContact = AddContactFeature.State(
                    contact: .init(id: UUID(), name: "Tester"))
                return .none

            case let .addContact(.presented(.delegate(.saveContact(contact)))):
                state.contacts.append(contact)
                return .none

            case .addContact:
                return .none

            case let .deleteButtonTapped(id):
                state.alert = AlertState {
                    TextState("Are you sure?")
                } actions: {
                    ButtonState(
                        role: .destructive, action: .confirmDeletion(id: id)
                    ) {
                        TextState("Delete")
                    }
                }
                return .none
            case let .alert(.presented(.confirmDeletion(id))):
                state.contacts.remove(id: id)
                return .none
            case .alert: return .none
            }

        }
        .ifLet(\.$addContact, action: \.addContact) {
            AddContactFeature()
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

struct ContactView: View {
    @Bindable var store: StoreOf<ContactFeature>

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.contacts) { contact in
                    HStack {
                        Text(contact.name)
                        Spacer()
                        Button {
                            store.send(.deleteButtonTapped(contact.id))
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Contacts")
            .toolbar {
                ToolbarItem {
                    Button {
                        store.send(.addButtonTapped)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(
            item: $store.scope(
                state: \.addContact,
                action: \.addContact)
        ) {
            addContactStore in
            NavigationStack {
                AddContactView(store: addContactStore)
            }
        }
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}

#Preview {
    ContactView(
        store: Store(
            initialState: ContactFeature.State(contacts: [
                Contact(id: UUID(), name: "Blob"),
                Contact(id: UUID(), name: "Blob Jr"),
                Contact(id: UUID(), name: "Blob Sr"),
            ]), reducer: { ContactFeature() })
    )
}
