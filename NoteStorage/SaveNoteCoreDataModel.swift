//
//  SaveNoteCoreDataModel.swift
//  NoteList
//
//  Created by Александра Сергеева on 15.02.2024.
//

import Foundation

class SaveNoteCoreDataModel {
    let title: String?
    let attributedText: NSMutableAttributedString?
    
    init(title: String?, attributedText: NSMutableAttributedString?) {
        self.title = title
        self.attributedText = attributedText
    }
}
