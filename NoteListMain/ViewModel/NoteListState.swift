//
//  NoteListState.swift
//  NoteList
//
//  Created by Александра Сергеева on 15.02.2024.
//

import Foundation

enum NoteListState {
    case success([NoteListNoteModel])
    case error
    case empty
}
