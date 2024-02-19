//
//  SaveNoteCoreDataModel.swift
//  NoteList
//
//  Created by Александра Сергеева on 15.02.2024.
//

import Foundation

class SaveNoteCoreDataModel {
    let title: String?
    let attributedText: NSAttributedString?
    
    init(title: String?, attributedText: NSAttributedString?) {
        self.title = title
        self.attributedText = attributedText
    }
}
