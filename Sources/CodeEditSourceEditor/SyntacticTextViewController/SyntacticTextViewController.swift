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
    public var syntacticTextView: SyntacticTextView!

    init(
        string: String,
        language: CodeLanguage,
        font: NSFont,
        theme: EditorTheme,
        tabWidth: Int,
        indentOption: IndentOption,
        lineHeight: CGFloat,
        wrapLines: Bool,
        cursorPositions: [CursorPosition],
        syntacticCategoryPosition: SyntacticCategoryPosition?,
        editorOverscroll: CGFloat,
        useThemeBackground: Bool,
        highlightProviders: [HighlightProviding] = [TreeSitterClient()],
        contentInsets: NSEdgeInsets?,
        isEditable: Bool,
        isSelectable: Bool,
        letterSpacing: Double,
        useSystemCursor: Bool,
        bracketPairHighlight: BracketPairHighlight?,
        undoManager: CEUndoManager? = nil,
        coordinators: [TextViewCoordinator] = []
    ) {
        self.syntacticCategoryPosition = syntacticCategoryPosition
        self.syntacticTextView = SyntacticTextView(string: string)

        super.init(
            view: syntacticTextView,
            string: string,
            language: language,
            font: font,
            theme: theme,
            tabWidth: tabWidth,
            indentOption: indentOption,
            lineHeight: lineHeight,
            wrapLines: wrapLines,
            cursorPositions: cursorPositions,
            editorOverscroll: editorOverscroll,
            useThemeBackground: useThemeBackground,
            highlightProviders: highlightProviders,
            contentInsets: contentInsets,
            isEditable: isEditable,
            isSelectable: isSelectable,
            letterSpacing: letterSpacing,
            useSystemCursor: useSystemCursor,
            bracketPairHighlight: bracketPairHighlight,
            undoManager: undoManager,
            coordinators: coordinators
        )
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func attributesFor(_ capture: CaptureName?) -> [NSAttributedString.Key: Any] {
        [
            .font: theme.fontFor(for: capture),
            .foregroundColor: theme.colorFor(capture),
            .kern: textView.kern,
            .captureName: capture?.mappedName as Any,
        ]
    }
}
