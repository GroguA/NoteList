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
    
    func getAllNotes(onSuccess: @escaping ([FetchNoteCoreDataModel]) -> (), onError: @escaping (Error) -> ()) {
        DispatchQueue.global(qos: .utility).async {
            do {
                let coreDataNotes = try self.noteStorageService.fetchNotes()
                if coreDataNotes.isEmpty {
                    let notes = FetchNoteCoreDataModel(text: "Let start with your first note", title: "Hello world", id: "9999")
                    self.callResultOnMain {
                        onSuccess([notes])
                    }
                } else {
                    self.callResultOnMain {
                        onSuccess(coreDataNotes)
                    }
                }
            } catch {
                self.callResultOnMain {
                    onError(error)
                }
            }
        }
    }
    
    func createEmptyNote(onSuccess: (String) -> (), onError: (Error) -> ()) {
        do {
            let noteID = try noteStorageService.saveEmptyNote()
            onSuccess(noteID)
        } catch {
            onError(error)
        }
    }
    
    func getNoteById(id: String?) -> FetchNoteCoreDataModel? {
        if let note = noteStorageService.getNoteById(id: id) {
            return FetchNoteCoreDataModel(text: note.text, title: note.title, id: note.id)
        } else {
            return nil
        }
    }
    
    func updateNoteById(id: String, title: String?, text: String?) {
        noteStorageService.updateNoteById(id: id, text: text, title: title)
    }
    
    private func callResultOnMain(result: @escaping () -> Void) {
        DispatchQueue.main.async {
            result()
        }
    }
}
