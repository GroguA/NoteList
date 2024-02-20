//
//  DefaultNoteProvider.swift
//  NoteList
//
//  Created by Александра Сергеева on 20.02.2024.
//

import UIKit


class DefaultNoteProvider {
    
    private let defaultTitle = "Hello world"
    private let defaultText = "Let start with your first note"
    private let defaultTextSize = 17.0
    
    func provideDefaultNoteText() -> NSMutableAttributedString {
        let attributedText = NSMutableAttributedString(string: self.defaultText)
        attributedText.addAttribute(
            NSAttributedString.Key.font,
            value: UIFont.systemFont(ofSize: defaultTextSize),
            range: NSRange(defaultText.startIndex..., in: defaultText)
        )
        return attributedText
    }
    
    func provideDefaultNoteTitle() -> String {
        return defaultTitle
    }
    
    func provideDefaultNote(noteId: String) -> FetchNoteCoreDataModel {
        return FetchNoteCoreDataModel(
            title: provideDefaultNoteTitle(),
            id: noteId,
            attributedText: provideDefaultNoteText()
        )
    }
}
