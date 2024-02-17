//
//  EditNoteViewModel.swift
//  NoteList
//
//  Created by Александра Сергеева on 15.02.2024.
//

import Foundation

class EditNoteViewModel {
        
    var viewStateDidChange: (EditNoteState) -> () = { _ in } {
        didSet {
            guard let currentState = currentState else {
                return
            }
            viewStateDidChange(currentState)
        }
    }
    
    private var noteId = ""
    
    private let noteSource = NoteSource.shared
    
    private var currentState: EditNoteState? = nil  {
        didSet {
            if let currentState = currentState {
                viewStateDidChange(currentState)
            }
        }
    }
    
    func loadNote(id: String) {
        self.noteId = id
        noteSource.getNoteById(id: id, onSuccess: { note in
            self.currentState = .success(text: note.text, title: note.title)
        }, onError: { _ in
            self.currentState = .error
        })
    }
    
    func textChanged(title: String?, text: String?) {
        noteSource.updateNoteById(id: noteId, title: title, text: text)
    }
    
    
}
