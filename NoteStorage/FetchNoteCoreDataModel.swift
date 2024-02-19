//
//  FetchNoteCoreDateModel.swift
//  NoteList
//
//  Created by Александра Сергеева on 15.02.2024.
//

import Foundation

class FetchNoteCoreDataModel {
    let title: String
    let id: String
    let attributedText: NSAttributedString
    
    init( title: String, id: String, attributedText: NSAttributedString) {
        self.id = id
        self.title = title
        self.attributedText = attributedText
    }
}
