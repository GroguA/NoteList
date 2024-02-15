//
//  NoteListViewModel.swift
//  NoteList
//
//  Created by Александра Сергеева on 15.02.2024.
//

import Foundation

class NoteListViewModel {
    
    private let noteSource = NoteSource.shared
    
    func onAddNoteButtonTapped() {
        noteSource.createEmptyNote {
            let note = SaveNoteCoreDataModel(text: nil, title: nil)
            return note
        }
    }
}
