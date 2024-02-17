//
//  NoteListViewModel.swift
//  NoteList
//
//  Created by Александра Сергеева on 15.02.2024.
//

import Foundation

class NoteListViewModel {
        
    var viewStateDidChange: (NoteListState) -> () = { _ in } {
        didSet {
            guard let currentState = currentState else {
                return
            }
            viewStateDidChange(currentState)
        }
    }
    
    var onAction: (NoteListAction) -> ()  = { _ in }
    
    private var currentState: NoteListState? = nil  {
        didSet {
            if let currentState = currentState {
                viewStateDidChange(currentState)
            }
        }
    }
        
    private let noteSource = NoteSource.shared

    
    func loadNotes() {
        noteSource.getAllNotes(onSuccess: { notes in
            let mappedNotes = notes.map({ note in
                let title = note.title.isEmpty ?  "No title" : note.title
                let text = note.text.isEmpty ?  "No text" : note.text
                return NoteListNoteModel(text: text, title: title, id: note.id)

            })
            self.currentState = .success(mappedNotes)
        }, onError: { _ in
            self.currentState = .error
        })
    }
    
    func onAddNoteButtonTapped() {
        noteSource.createEmptyNote (onSuccess: { id in
            self.onAction(NoteListAction.openNoteEdit(noteId: id))
        }, onError: ({ error in
            self.onAction(NoteListAction.showErrorDialog(errorText: "Error creating new note" ))
        }))
    }
        
    
    func onNoteClicked(id: String) {
        if id != "9999" {
            onAction(NoteListAction.openNoteEdit(noteId: id))
        } else {
            return
        }
    }
}
