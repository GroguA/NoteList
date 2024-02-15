//
//  NoteSource.swift
//  NoteList
//
//  Created by Александра Сергеева on 15.02.2024.
//

import Foundation

class NoteSource {
    
    static let shared = NoteSource()
    
    private let noteStorageService = NoteStorageService.shared
    
    func getAllNotes(onSuccess: ([FetchNoteCoreDateModel]) -> (), onError: (Error) -> ()) {
        let coreDataNotes = noteStorageService.fetchNotes()
        if coreDataNotes.isEmpty {
            let notes = FetchNoteCoreDateModel(text: "Let start with your first note", title: "Hello world", id: nil)
            onSuccess([notes])
        } else {
            onSuccess(coreDataNotes)
        }
    }
    
    func createEmptyNote(note: () -> (SaveNoteCoreDataModel)) {
        let note = note()
        noteStorageService.saveNote(note: note)
    }
    
    func getNoteById(id: String?) -> FetchNoteCoreDateModel? {
        if let note = noteStorageService.getNoteById(id: id) {
            return FetchNoteCoreDateModel(text: note.text, title: note.title, id: note.id)
        } else {
            return nil
        }
    }
    
    func updateNoteById(id: String, title: String?, text: String?) {
        noteStorageService.updateNoteById(id: id, text: text, title: title)
    }
    
}
