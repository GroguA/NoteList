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
                    do {
                        let noteId = try self.noteStorageService.createNote(title: "Hello world", text: "Let start with your first note", attributedText: nil)
                        let note = FetchNoteCoreDataModel(text: "Let start with your first note", title: "Hello world", id: noteId, attributedText: nil)
                        self.callResultOnMain {
                            onSuccess([note])
                        }
                    } catch {
                        onError(error)
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
                let noteID = try self.noteStorageService.createNote(title: "", text: "", attributedText: nil)
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
    
    func updateNoteById(id: String, title: String?, text: String?, attributedText: NSAttributedString?) {
        DispatchQueue.global(qos: .utility).async {
            do {
                try self.noteStorageService.updateNoteById(id: id, text: text, title: title, attributedText: attributedText)
            } catch {
                //ignore
            }
        }
    }
    
    func deleteNote(id: String) throws {
        DispatchQueue.global(qos: .utility).async {
            do {
                try self.noteStorageService.deleteNote(id: id)
            } catch {
                
            }
        }
    }
    
    private func callResultOnMain(result: @escaping () -> Void) {
        DispatchQueue.main.async {
            result()
        }
    }
}
