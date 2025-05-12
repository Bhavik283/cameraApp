//
//  HelperViews.swift
//  cameraApp
//
//  Created by Bhavik Goyal on 13/05/25.
//

import SwiftUI

struct InputField: View {
    @Binding var isFocused: Bool
    @Binding var text: String
    @FocusState private var internalFocus: Bool

    init(isFocused: Binding<Bool>, text: Binding<String>) {
        self._text = text
        self._isFocused = isFocused
    }

    var body: some View {
        TextField("", text: $text)
            .focused($internalFocus)
            .textFieldStyle(.plain)
            .onAppear {
                internalFocus = isFocused
            }
            .onChange(of: internalFocus) { _, newValue in
                isFocused = newValue
            }
    }
}

struct TextItem: View {
    @Binding var items: [String]
    @Binding var selectedIndex: Int?
    @Binding var editingIndex: Int?
    let index: Int

    var body: some View {
        Text(items[index])
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
                if selectedIndex == index {
                    editingIndex = index
                } else {
                    selectedIndex = index
                    if editingIndex != index {
                        editingIndex = nil
                    }
                }
            }
    }
}

struct Buttons: View {
    @Binding var items: [String]
    @Binding var selectedIndex: Int?

    var body: some View {
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
