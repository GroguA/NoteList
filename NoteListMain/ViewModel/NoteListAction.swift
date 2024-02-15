//
//  NoteListAction.swift
//  NoteList
//
//  Created by Александра Сергеева on 15.02.2024.
//

import Foundation

enum NoteListAction {
    case openNoteEdit(noteId: String)
    case showErrorDialog(errorText: String)
}
