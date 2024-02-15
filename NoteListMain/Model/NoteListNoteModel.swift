//
//  NoteListNoteModel.swift
//  NoteList
//
//  Created by Александра Сергеева on 15.02.2024.
//

import Foundation

class NoteListNoteModel {
    let text: String
    let title: String
    let id: String
    
    init(text: String, title: String, id: String) {
        self.id = id
        self.text = text
        self.title = title
    }
}
