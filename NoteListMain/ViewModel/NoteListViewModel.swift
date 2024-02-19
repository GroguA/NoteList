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
    
    private var notes = [NoteListNoteModel]()
    
    func loadNotes() {
        noteSource.getAllNotes(onSuccess: { notes in
            var mappedNotes = notes.map({ note in
                let title = note.title.isEmpty ?  "No title" : note.title
                let text = note.attributedText.string
                let attrText = text.isEmpty ? "No text" : text
                return NoteListNoteModel(text: attrText, title: title, id: note.id)
                
            })
            if mappedNotes.count > 1 && mappedNotes.contains(where: { $0.title == "Hello world"}) {
                let defaultNote = mappedNotes.first(where: { $0.title == "Hello world"})
                mappedNotes.removeAll(where: { $0.title == "Hello world" })
                if let defaultNote {
                    self.noteSource.deleteNote(id: defaultNote.id)
                }
            }
            self.currentState = .success(mappedNotes)
            self.notes = mappedNotes
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
        onAction(NoteListAction.openNoteEdit(noteId: id))
    }
    
    func deleteNote(index: Int) {
        noteSource.deleteNote(id: notes[index].id)
        notes.remove(at: index)
        currentState = .success(self.notes)
    }
}
