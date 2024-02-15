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
    
    init(text: String?, title: String?) {
        self.text = text
        self.title = title
    }
}
