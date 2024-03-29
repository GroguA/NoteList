//
//  NoteStorageService.swift
//  NoteList
//
//  Created by Александра Сергеева on 15.02.2024.
//

import CoreData
import UIKit

class NoteStorageService {
    
    static let shared = NoteStorageService()
    
    private init() {}
    
    private let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    func fetchNotes() throws -> [FetchNoteCoreDataModel] {
        
        var notes = [FetchNoteCoreDataModel]()
        
        guard let appDelegate = appDelegate else {
            throw NoteListErrors.runtimeError("no app delegate")
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Note")
        
        let notesManagedObjects = try managedContext.fetch(fetchRequest)
        notesManagedObjects.forEach({ managedNote in
            guard let title = managedNote.value(forKey: "title") as? String,
                  let attributedText = managedNote.value(forKey: "attributedText") as? NSAttributedString
            else {
                return
            }
            let note = FetchNoteCoreDataModel(title: title, id: managedNote.objectID.uriRepresentation().absoluteString, attributedText: attributedText)
            notes.append(note)
        })
        return notes
    }
    
    func getNoteById(id: String) throws -> FetchNoteCoreDataModel {
        guard let appDelegate = appDelegate else {
            throw NoteListErrors.runtimeError("no app delegate")
        }
        var note: FetchNoteCoreDataModel
        let managedContext = appDelegate.persistentContainer.viewContext
        guard let url = URL(string: id), let storageCoordinator = managedContext.persistentStoreCoordinator else { throw NoteListErrors.runtimeError("failed to convert id to url")
        }
        let noteID = storageCoordinator.managedObjectID(forURIRepresentation: url)
        guard let noteID else {
            throw NoteListErrors.runtimeError("no such note")
        }
        
        let noteManagedObj = managedContext.object(with: noteID)
        
        guard let text = noteManagedObj.value(forKey: "attributedText") as? NSAttributedString,
              let title = noteManagedObj.value(forKey: "title") as? String
        else {
            throw NoteListErrors.runtimeError("faild to fetch note text and title")
        }
        note = FetchNoteCoreDataModel(title: title, id: noteManagedObj.objectID.uriRepresentation().absoluteString, attributedText: text)
        return note
    }
    
    func updateNoteById(id: String, title: String?, attributedText: NSAttributedString?) throws {
        guard let appDelegate = appDelegate else {
            throw NoteListErrors.runtimeError("no app delegate")
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        guard let url = URL(string: id), let storageCoordinator = managedContext.persistentStoreCoordinator else { throw NoteListErrors.runtimeError("failed to convert id to url")
        }
        let noteID = storageCoordinator.managedObjectID(forURIRepresentation: url)
        guard let noteID else {
            throw NoteListErrors.runtimeError("no such note")
        }
        
        let noteManagedObj = managedContext.object(with: noteID)
        
        if let title {
            noteManagedObj.setValue(title, forKey: "title")
        }
        if let attributedText {
            noteManagedObj.setValue(attributedText, forKey: "attributedText")
        }
        
        do {
            try managedContext.save()
        } catch {
            throw NoteListErrors.runtimeError("could not update note")
        }
        
    }
    
    func createNote(title: String, attributedText: NSAttributedString?) throws -> String {
        guard let appDelegate = appDelegate else {
            throw NoteListErrors.runtimeError("no app delegate")
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Note", in: managedContext) else {
            throw NoteListErrors.runtimeError("no entity")
        }
        
        let noteNSManagedObj = NSManagedObject(entity: entity, insertInto: managedContext)
        
        let note = SaveNoteCoreDataModel(title: title, attributedText: attributedText)
        
        noteNSManagedObj.setValue(note.title, forKey: "title")
        noteNSManagedObj.setValue(note.attributedText, forKey: "attributedText")
        
        do {
            try managedContext.save()
        } catch {
            throw NoteListErrors.runtimeError("could not save note")
        }
        return noteNSManagedObj.objectID.uriRepresentation().absoluteString
    }
    
    func deleteNote(id: String) throws  {
        guard let appDelegate = appDelegate else {
            throw NoteListErrors.runtimeError("no app delegate")
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        guard let url = URL(string: id), let storageCoordinator = managedContext.persistentStoreCoordinator else {       throw NoteListErrors.runtimeError("no entity")
            
        }
        let noteId = storageCoordinator.managedObjectID(forURIRepresentation: url)
        guard let noteId else {
            throw NoteListErrors.runtimeError("no such note")
        }
        let noteManagedObj = managedContext.object(with: noteId)
        
        managedContext.delete(noteManagedObj)
        
        do {
            try managedContext.save()
        } catch {
            throw NoteListErrors.runtimeError("could not delete this note")
        }
    }
    
}
