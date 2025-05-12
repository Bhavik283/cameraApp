//
//  VideoCaptureView.swift
//  cameraApp
//
//  Created by Bhavik Goyal on 11/05/25.
//

import AVFoundation
import SwiftUI

// MARK: - SwiftUI Capture View

struct VideoCaptureView: NSViewRepresentable {
    var session: AVCaptureSession

    func makeNSView(context: Context) -> CaptureView {
        let view = CaptureView()
        view.configure(with: session)
        return view
    }

    func updateNSView(_ nsView: CaptureView, context: Context) {
        nsView.configure(with: session)
    }
}

class CaptureView: NSView {
    private var previewLayer: AVCaptureVideoPreviewLayer?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
    }

    func configure(with session: AVCaptureSession) {
        // If already set to this session, skip
        if previewLayer?.session == session {
            return
        }

        previewLayer?.removeFromSuperlayer()

        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        self.layer = CALayer()
        self.layer?.addSublayer(layer)
        previewLayer = layer

        needsLayout = true
    }

    override func layout() {
        super.layout()
        previewLayer?.frame = bounds
    }
}

struct TableViewWrapper: NSViewRepresentable {
    @Binding var items: [String]
    @Binding var activeItem: String?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true

        let tableView = ForceClickTableView()
        tableView.delegate = context.coordinator
        tableView.dataSource = context.coordinator

        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("Column"))
        column.title = "Items"
        tableView.addTableColumn(column)

        tableView.doubleAction = #selector(Coordinator.doubleClickedRow)
        tableView.target = context.coordinator

        scrollView.documentView = tableView
        context.coordinator.tableView = tableView

        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        context.coordinator.tableView?.reloadData()
        if let active = activeItem, let index = items.firstIndex(of: active) {
            context.coordinator.tableView?.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
        }
    }

    class Coordinator: NSObject, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate {
        var parent: TableViewWrapper
        weak var tableView: NSTableView?

        init(_ parent: TableViewWrapper) {
            self.parent = parent
        }

        func numberOfRows(in tableView: NSTableView) -> Int {
            parent.items.count
        }

        func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
            let identifier = NSUserInterfaceItemIdentifier("Cell")
            let textField: NSTextField

            if let cell = tableView.makeView(withIdentifier: identifier, owner: nil) as? NSTextField {
                textField = cell
            } else {
                textField = NSTextField()
                textField.identifier = identifier
                textField.isEditable = false
                textField.isBordered = false
                textField.delegate = self
                textField.tag = row
                textField.backgroundColor = .clear
                textField.heightAnchor.constraint(equalToConstant: 20).isActive = true
            }

            textField.stringValue = parent.items[row]
            return textField
        }

        func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
            return 20
        }

        @objc func doubleClickedRow() {
            guard let tableView = tableView else { return }
            let row = tableView.clickedRow
            guard row >= 0 else { return }

            if let textField = tableView.view(atColumn: 0, row: row, makeIfNecessary: false) as? NSTextField {
                textField.isEditable = true
                textField.becomeFirstResponder()
            }
        }

        func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
            parent.activeItem = parent.items[row]
            return true
        }

        func controlTextDidEndEditing(_ obj: Notification) {
            guard let textField = obj.object as? NSTextField else { return }
            let row = textField.tag
            if row >= 0 && row < parent.items.count {
                parent.items[row] = textField.stringValue
            }
        }
    }
}

class ForceClickTableView: NSTableView {
    override func pressureChange(with event: NSEvent) {
        super.pressureChange(with: event)
        if event.stage == 2 {
            let location = convert(event.locationInWindow, from: nil)
            let row = self.row(at: location)
            if row >= 0 {
                if let textField = view(atColumn: 0, row: row, makeIfNecessary: false) as? NSTextField {
                    textField.isEditable = true
                    textField.becomeFirstResponder()
                }
            }
        }
    }
}

struct NSTextFieldWrapper: NSViewRepresentable {
    @Binding var text: String
    @Binding var isEditing: Bool
    @State var startedEditing: Bool = false

    class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: NSTextFieldWrapper

        init(_ parent: NSTextFieldWrapper) {
            self.parent = parent
        }

        func controlTextDidEndEditing(_ obj: Notification) {
            parent.isEditing = false
            parent.startedEditing = false
        }

        func controlTextDidChange(_ obj: Notification) {
            if let field = obj.object as? NSTextField {
                parent.text = field.stringValue
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField()
        textField.isBordered = false
        textField.backgroundColor = .white
        textField.delegate = context.coordinator
        textField.focusRingType = .none
        return textField
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        if nsView.stringValue != text {
            nsView.stringValue = text
        }

        if !startedEditing && isEditing {
            nsView.becomeFirstResponder()
            DispatchQueue.main.async {
                startedEditing = true
            }
        }
    }
}
