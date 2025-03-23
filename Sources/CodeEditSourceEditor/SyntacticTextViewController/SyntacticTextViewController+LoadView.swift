//
//  SyntacticTextViewController+LoadView.swift
//  CodeEditSourceEditor
//
//  Created by Daniel Choroszucha on 23/03/2025.
//

import AppKit
import CodeEditTextView

public extension SyntacticTextViewController {
    override func loadView() {
        super.loadView()

        NotificationCenter.default.addObserver(
            forName: SyntacticTextSelectionManager.syntacticCategorySelectionChangedNotification,
            object: syntacticTextView.syntacticSelectionManager,
            queue: .main
        ) { [weak self] _ in
            self?.notifyAboutSelectionChange()
        }
    }

    private func notifyAboutSelectionChange() {
        if let name = syntacticTextView.syntacticSelectionManager.selectedSyntacticName,
           let range = syntacticTextView.syntacticSelectionManager.selectedSyntacticRange {
            syntacticCategoryPosition = .init(
                category: name,
                cursor: .init(range: range)
            )
        } else {
            syntacticCategoryPosition = nil
        }

        NotificationCenter.default.post(name: Self.syntacticCategoryPositionNotification, object: self)
    }
}
