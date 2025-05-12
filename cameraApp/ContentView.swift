//
//  ContentView.swift
//  cameraApp
//
//  Created by Bhavik Goyal on 11/05/25.
//

import SwiftUI

// struct ContentView: View {
//    var body: some View {
//        VStack {
//            Text("Camera Preview")
//                .font(.headline)
//            CameraSelectorView()
//                .frame(width: 640, height: 480)
//                .border(Color.gray, width: 1)
//        }
//        .padding()
//    }
// }

struct ContentView: View {
    var body: some View {
        EditableListView()
    }
}

#Preview {
    ContentView()
}

struct EditableListView: View {
    @State private var items = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5"]
    @State private var selectedIndex: Int? = nil
    @State private var editingIndex: Int? = nil

    func getTextBinding(index: Int) -> Binding<String> {
        Binding(
            get: { index < items.count ? items[index] : "" },
            set: {
                if index < items.count {
                    items[index] = $0
                }
            }
        )
    }

    func editingBinding(index: Int) -> Binding<Bool> {
        Binding(
            get: { editingIndex == index },
            set: { if !$0 { commitEdit() } }
        )
    }

    var body: some View {
        VStack {
            List(items.indices, id: \.self, selection: $selectedIndex) { index in
                Group {
                    if editingIndex == index {
                        NSTextFieldWrapper(text: getTextBinding(index: index), isEditing: editingBinding(index: index))
                            .frame(height: 20)
                    } else {
                        Text(items[index])
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                            .onTapGesture(count: 1) {
                                selectedIndex = index
                                if editingIndex != index {
                                    editingIndex = nil
                                }
                            }
                            .simultaneousGesture(
                                TapGesture(count: 2)
                                    .onEnded {
                                        selectedIndex = index
                                        editingIndex = index
                                    }
                            )
                    }
                }
                .padding(0)
                .frame(height: 20)
                .listRowSeparator(.hidden)
            }
            .listStyle(.bordered)

            HStack {
                Button("Add Item") {
                    items.append("New Item \(items.count + 1)")
                }

                Spacer()

                if let selected = selectedIndex {
                    Button("Remove") {
                        if selected < items.count {
                            items.remove(at: selected)
                            selectedIndex = nil
                        }
                    }
                }
            }
            .padding()
        }
    }

    private func commitEdit() {
        if let index = editingIndex, index < items.count {
            editingIndex = nil
        }
    }
}
