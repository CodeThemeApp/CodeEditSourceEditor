//
//  SyntacticCategoryEditor.swift
//  CodeEditSourceEditor
//
//  Created by Daniel Choroszucha on 23/03/2025.
//

import AppKit
import CodeEditLanguages
import CodeEditTextView
import SwiftUI

public struct SyntacticCategoryEditor: NSViewControllerRepresentable {
    public init(
        _ textStorage: NSTextStorage,
        language: CodeLanguage,
        theme: EditorTheme,
        font: NSFont,
        tabWidth: Int,
        indentOption: IndentOption = .spaces(count: 4),
        lineHeight: Double,
        wrapLines: Bool,
        editorOverscroll: CGFloat = 0,
        cursorPositions: Binding<[CursorPosition]>,
        syntacticCategoryPosition: Binding<SyntacticCategoryPosition?>,
        useThemeBackground: Bool = true,
        highlightProviders: [any HighlightProviding] = [TreeSitterClient()],
        contentInsets: NSEdgeInsets? = nil,
        isEditable: Bool = true,
        isSelectable: Bool = true,
        letterSpacing: Double = 1.0,
        bracketPairEmphasis: BracketPairEmphasis? = nil,
        useSystemCursor: Bool = true,
        undoManager: CEUndoManager? = nil,
        coordinators: [any TextViewCoordinator] = []
    ) {
        self.textStorage = textStorage
        self.language = language
        self.configuration = Self.makeConfiguration(
            theme: theme,
            font: font,
            tabWidth: tabWidth,
            indentOption: indentOption,
            lineHeight: lineHeight,
            wrapLines: wrapLines,
            editorOverscroll: editorOverscroll,
            useThemeBackground: useThemeBackground,
            contentInsets: contentInsets,
            isEditable: isEditable,
            isSelectable: isSelectable,
            letterSpacing: letterSpacing,
            useSystemCursor: useSystemCursor,
            bracketPairEmphasis: bracketPairEmphasis
        )
        self.cursorPositions = cursorPositions
        self.syntacticCategoryPosition = syntacticCategoryPosition
        self.highlightProviders = highlightProviders
        self.undoManager = undoManager
        self.coordinators = coordinators
    }

    package var textStorage: NSTextStorage
    private var language: CodeLanguage
    private var configuration: SourceEditorConfiguration
    package var cursorPositions: Binding<[CursorPosition]>
    package var syntacticCategoryPosition: Binding<SyntacticCategoryPosition?>
    private var highlightProviders: [any HighlightProviding]
    private var undoManager: CEUndoManager?
    package var coordinators: [any TextViewCoordinator]

    public typealias NSViewControllerType = SyntacticTextViewController

    public func makeNSViewController(context: Context) -> SyntacticTextViewController {
        let controller = SyntacticTextViewController(
            string: "",
            language: language,
            configuration: configuration,
            cursorPositions: cursorPositions.wrappedValue,
            syntacticCategoryPosition: syntacticCategoryPosition.wrappedValue,
            highlightProviders: highlightProviders,
            undoManager: undoManager,
            coordinators: coordinators
        )
        controller.textView.setTextStorage(textStorage)
        if controller.textView == nil {
            controller.loadView()
        }
        if !cursorPositions.wrappedValue.isEmpty {
            controller.setCursorPositions(cursorPositions.wrappedValue)
        }

        context.coordinator.controller = controller
        return controller
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(
            textStorage: textStorage,
            cursorPositions: cursorPositions,
            syntacticCategoryPosition: syntacticCategoryPosition
        )
    }

    public func updateNSViewController(_ controller: SyntacticTextViewController, context: Context) {
        if !context.coordinator.isUpdateFromTextView {
            context.coordinator.isUpdatingFromRepresentable = true
            controller.setCursorPositions(cursorPositions.wrappedValue)
            context.coordinator.isUpdatingFromRepresentable = false
        } else {
            context.coordinator.isUpdateFromTextView = false
        }

        controller.textCoordinators = coordinators.map { WeakCoordinator($0) }

        guard !paramsAreEqual(controller: controller) else {
            return
        }

        controller.configuration = configuration
        controller.reloadUI()
    }

    func paramsAreEqual(controller: NSViewControllerType) -> Bool {
        controller.language.id == language.id &&
            controller.configuration == configuration
    }

    private static func makeConfiguration(
        theme: EditorTheme,
        font: NSFont,
        tabWidth: Int,
        indentOption: IndentOption,
        lineHeight: Double,
        wrapLines: Bool,
        editorOverscroll: CGFloat,
        useThemeBackground: Bool,
        contentInsets: NSEdgeInsets?,
        isEditable: Bool,
        isSelectable: Bool,
        letterSpacing: Double,
        useSystemCursor: Bool,
        bracketPairEmphasis: BracketPairEmphasis?
    ) -> SourceEditorConfiguration {
        SourceEditorConfiguration(
            appearance: Appearance(
                theme: theme,
                useThemeBackground: useThemeBackground,
                font: font,
                lineHeightMultiple: lineHeight,
                letterSpacing: letterSpacing,
                wrapLines: wrapLines,
                useSystemCursor: useSystemCursor,
                tabWidth: tabWidth,
                bracketPairEmphasis: bracketPairEmphasis
            ),
            behavior: Behavior(
                isEditable: isEditable,
                isSelectable: isSelectable,
                indentOption: indentOption
            ),
            layout: Layout(
                editorOverscroll: editorOverscroll,
                contentInsets: contentInsets
            ),
            peripherals: Peripherals(
                showGutter: true,
                showMinimap: false,
                showReformattingGuide: false,
                showFoldingRibbon: false
            )
        )
    }
}

public extension SyntacticCategoryEditor {
    var body: some View {
        EmptyView()
    }
}

private typealias Appearance = SourceEditorConfiguration.Appearance
private typealias Behavior = SourceEditorConfiguration.Behavior
private typealias Layout = SourceEditorConfiguration.Layout
private typealias Peripherals = SourceEditorConfiguration.Peripherals
