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
    let attributedText: NSMutableAttributedString
    
    init( title: String, id: String, attributedText: NSMutableAttributedString) {
        self.id = id
        self.title = title
        self.attributedText = attributedText
    }
}
