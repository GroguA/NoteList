//
//  EditNoteState.swift
//  NoteList
//
//  Created by Александра Сергеева on 16.02.2024.
//

import Foundation

enum EditNoteState {
    case success(text: String?, title: String?, attributedText: NSAttributedString?)
    case error
}
