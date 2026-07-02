//
//  SyntacticTextViewController.swift
//  CodeEditSourceEditor
//
//  Created by Daniel Choroszucha on 23/03/2025.
//

import AppKit
import CodeEditLanguages
import CodeEditTextView
import Combine
import SwiftUI
import TextFormation

public struct SyntacticCategoryPosition: Sendable, Codable, Equatable, Hashable {
    public let category: String
    public let cursor: CursorPosition
}

public class SyntacticTextViewController: TextViewController {
    // swiftlint:disable:next line_length
    public static let syntacticCategoryPositionNotification: Notification.Name = .init("SyntacticTextViewController.syntacticCategoryPositionNotification")

    var syntacticCategoryPosition: SyntacticCategoryPosition?
    public private(set) var syntacticTextView: SyntacticTextView!

    init(
        string: String,
        language: CodeLanguage,
        configuration: SourceEditorConfiguration,
        cursorPositions: [CursorPosition],
        syntacticCategoryPosition: SyntacticCategoryPosition?,
        highlightProviders: [HighlightProviding] = [TreeSitterClient()],
        undoManager: CEUndoManager? = nil,
        coordinators: [TextViewCoordinator] = []
    ) {
        let syntacticTextView = SyntacticTextView(string: string)
        self.syntacticTextView = syntacticTextView
        self.syntacticCategoryPosition = syntacticCategoryPosition

        super.init(
            string: string,
            language: language,
            configuration: configuration,
            cursorPositions: cursorPositions,
            highlightProviders: highlightProviders,
            undoManager: undoManager,
            coordinators: coordinators,
            textView: syntacticTextView
        )
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SyntacticTextViewController {
    public func attributesFor(_ capture: CaptureName?) -> [NSAttributedString.Key: Any] {
        [
            .font: configuration.appearance.theme.fontFor(for: capture, from: font),
            .foregroundColor: configuration.appearance.theme.colorFor(capture),
            .kern: textView.kern,
            .captureName: capture?.mappedName as Any,
        ]
    }
}
