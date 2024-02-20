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
    
    private let defaultNoteProvider = DefaultNoteProvider()
    
    func getAllNotes(onSuccess: @escaping ([FetchNoteCoreDataModel]) -> (), onError: @escaping (Error) -> ()) {
        DispatchQueue.global(qos: .utility).async {
            do {
                let coreDataNotes = try self.noteStorageService.fetchNotes()
                if coreDataNotes.isEmpty {
                    do {
                        let defaultText = self.defaultNoteProvider.provideDefaultNoteText()
                        let defaultTitle = self.defaultNoteProvider.provideDefaultNoteTitle()
                        let noteId = try self.noteStorageService.createNote(title: defaultTitle, attributedText: defaultText)
                        let defaultNote = self.defaultNoteProvider.provideDefaultNote(noteId: noteId)
                        self.callResultOnMain {
                            onSuccess([defaultNote])
                        }
                    } catch {
                        self.callResultOnMain {
                            onError(error)
                        }
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
                let noteID = try self.noteStorageService.createNote(title: "", attributedText: NSAttributedString(string: ""))
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
    
    func updateNoteById(id: String, title: String?, attributedText: NSAttributedString?) {
        DispatchQueue.global(qos: .utility).async {
            do {
                try self.noteStorageService.updateNoteById(id: id, title: title, attributedText: attributedText)
            } catch {
                //ignore
            }
        }
    }
    
    func deleteNote(id: String) {
        do {
            try self.noteStorageService.deleteNote(id: id)
        } catch {
            //ignore
        }
        
    }
    
    private func callResultOnMain(result: @escaping () -> Void) {
        DispatchQueue.main.async {
            result()
        }
    }

}
