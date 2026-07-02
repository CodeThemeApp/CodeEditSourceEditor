//
//  SyntacticCategoryEditor.swift
//  CodeEditSourceEditor
//
//  Created by Daniel Choroszucha on 23/03/2025.
//

import CodeEditTextView
import Foundation
import SwiftUI

public extension SyntacticCategoryEditor {
    @MainActor
    class Coordinator: NSObject {
        weak var controller: TextViewController?
        var isUpdatingFromRepresentable: Bool = false
        var isUpdateFromTextView: Bool = false
        var textStorage: NSTextStorage
        @Binding var cursorPositions: [CursorPosition]
        @Binding var syntacticCategoryPosition: SyntacticCategoryPosition?

        init(
            textStorage: NSTextStorage,
            cursorPositions: Binding<[CursorPosition]>,
            syntacticCategoryPosition: Binding<SyntacticCategoryPosition?>
        ) {
            self.textStorage = textStorage
            self._cursorPositions = cursorPositions
            self._syntacticCategoryPosition = syntacticCategoryPosition
            super.init()

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(textViewDidChangeText(_:)),
                name: TextView.textDidChangeNotification,
                object: nil
            )

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(textControllerCursorsDidUpdate(_:)),
                name: TextViewController.cursorPositionUpdatedNotification,
                object: nil
            )

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(syntacticTextControllerSelectionDidUpdate(_:)),
                name: SyntacticTextViewController.syntacticCategoryPositionNotification,
                object: nil
            )
        }

        @objc func textViewDidChangeText(_ notification: Notification) {
            guard let textView = notification.object as? TextView,
                  let controller,
                  controller.textView === textView else {
                return
            }
        }

        @objc func textControllerCursorsDidUpdate(_ notification: Notification) {
            guard let notificationController = notification.object as? TextViewController,
                  notificationController === controller else {
                return
            }
            guard !isUpdatingFromRepresentable else { return }
            isUpdateFromTextView = true
            cursorPositions = notificationController.cursorPositions
        }

        // TODO: [23.03.2025] Send notification to this method -
        @objc func syntacticTextControllerSelectionDidUpdate(_ notification: Notification) {
            guard let notificationController = notification.object as? SyntacticTextViewController,
                  notificationController === controller else {
                return
            }
            // TODO: [23.03.2025] Verify those flags -
            guard !isUpdatingFromRepresentable else { return }
            isUpdateFromTextView = true
            syntacticCategoryPosition = notificationController.syntacticCategoryPosition
        }

        deinit {
            NotificationCenter.default.removeObserver(self)
        }
    }
}
