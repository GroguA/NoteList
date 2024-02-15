//
//  NoteListViewModel.swift
//  NoteList
//
//  Created by Александра Сергеева on 15.02.2024.
//

import Foundation

class NoteListViewModel {
    
    private let noteSource = NoteSource.shared
    
    var viewStateDidChange: (NoteListState) -> () = { _ in } {
        didSet {
            guard let currentState = currentState else {
                return
            }
            viewStateDidChange(currentState)
        }
    }
    
    private var currentState: NoteListState? = nil  {
        didSet {
            if let currentState = currentState {
                viewStateDidChange(currentState)
            }
        }
    }
    
    var onAction: (NoteListAction) -> ()  = { _ in }
    
    func loadNotes() {
        noteSource.getAllNotes(onSuccess: { notes in
            let notes = notes.map({ note in
                return NoteListNoteModel(text: note.text, title: note.title, id: note.id)
            })
            self.currentState = .success(notes)
        }, onError: { _ in
            self.currentState = .error
        })
    }
    
    func onAddNoteButtonTapped() {
        noteSource.createEmptyNote { id in
            onAction(NoteListAction.openNoteEdit(noteId: id))
        } onError: { error in
            onAction(NoteListAction.showErrorDialog(errorText: error.localizedDescription ))
        }
    }
}
