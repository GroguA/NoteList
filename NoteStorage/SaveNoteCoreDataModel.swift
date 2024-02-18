//
//  SaveNoteCoreDataModel.swift
//  NoteList
//
//  Created by Александра Сергеева on 15.02.2024.
//

import Foundation

class SaveNoteCoreDataModel {
    let text: String?
    let title: String?
    let attributedText: NSAttributedString?
    
    init(text: String?, title: String?, attributedText: NSAttributedString?) {
        self.text = text
        self.title = title
        self.attributedText = attributedText
    }
}
