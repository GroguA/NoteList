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
    
    func createEmptyNote(onSuccess: @escaping (String) -> (), onError: @escaping (Error) -> ()) {
        DispatchQueue.global(qos: .utility).async {
            do {
                let noteID = try self.noteStorageService.createEmptyNote()
                self.callResultOnMain {
                    onSuccess(noteID)
                }
            } catch {
                self.callResultOnMain {
                    onError(error)
                }
            }
        }
    }
    
    func getNoteById(id: String, onSuccess: @escaping (FetchNoteCoreDataModel) -> (), onError: @escaping (Error) -> ()) {
        DispatchQueue.global(qos: .utility).async {
            do {
                let note = try self.noteStorageService.getNoteById(id: id)
                self.callResultOnMain {
                    onSuccess(note)
                }
            } catch {
                self.callResultOnMain {
                    onError(error)
                }
            }
        }
    }
    
    func updateNoteById(id: String, title: String?, text: String?) {
        DispatchQueue.global(qos: .utility).async {
            do {
                try self.noteStorageService.updateNoteById(id: id, text: text, title: title)
            } catch {
                //ignore
            }
        }
    }
    
    func deleteNote(id: String, onSuccess: @escaping () -> (), onError: @escaping (Error) -> ()) {
        DispatchQueue.global(qos: .utility).async {
            do {
                try self.noteStorageService.deleteNote(id: id)
                self.callResultOnMain {
                    onSuccess()
                }
            } catch {
                self.callResultOnMain {
                    onError(error)
                }
            }
        }
    }
    
    private func callResultOnMain(result: @escaping () -> Void) {
        DispatchQueue.main.async {
            result()
        }
    }
}
