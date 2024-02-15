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
    
    func saveNote(note: SaveNoteCoreDataModel) {
        
        guard let appDelegate = appDelegate else { return  }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Note", in: managedContext) else {
            return
        }
        
        let noteNSManagedObj = NSManagedObject(entity: entity, insertInto: managedContext)
        
        noteNSManagedObj.setValue(note.text, forKey: "text")
        noteNSManagedObj.setValue(note.title, forKey: "title")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
    func fetchNotes() -> [FetchNoteCoreDateModel] {
        
        var notes = [FetchNoteCoreDateModel]()
        
        guard let appDelegate = appDelegate else {
            return []
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Note")
        
        do {
            let notesManagedObjects = try managedContext.fetch(fetchRequest)
            notesManagedObjects.forEach({ managedNote in
                guard let text = managedNote.value(forKey: "text") as? String,
                      let title = managedNote.value(forKey: "title") as? String
                else {
                    return
                }
                let note = FetchNoteCoreDateModel(text: text, title: title, id: managedNote.objectID.uriRepresentation().absoluteString)
                notes.append(note)
            })
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return notes
    }
    
    func getNoteById(id: String?) -> FetchNoteCoreDateModel? {
        guard let appDelegate = appDelegate else {
            return nil
        }
        var note: FetchNoteCoreDateModel? = nil
        let managedContext = appDelegate.persistentContainer.viewContext
        guard let id else { return nil}
        guard let url = URL(string: id), let storageCoordinator = managedContext.persistentStoreCoordinator else { return nil }
        let noteID = storageCoordinator.managedObjectID(forURIRepresentation: url)
        guard let noteID else { return nil }
        
        let noteManagedObj = managedContext.object(with: noteID)
        
        guard let text = noteManagedObj.value(forKey: "text") as? String,
              let title = noteManagedObj.value(forKey: "title") as? String
        else {
            return nil
        }
        note = FetchNoteCoreDateModel(text: text, title: title, id: noteManagedObj.objectID.uriRepresentation().absoluteString)
        return note
    }
    
    func updateNoteById(id: String, text: String?, title: String?) {
        guard let appDelegate = appDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        guard let url = URL(string: id), let storageCoordinator = managedContext.persistentStoreCoordinator else { return  }
        let noteID = storageCoordinator.managedObjectID(forURIRepresentation: url)
        guard let noteID else { return }
        
        let noteManagedObj = managedContext.object(with: noteID)
        
        if let text {
            noteManagedObj.setValue(text, forKey: "text")
        }
        if let title {
            noteManagedObj.setValue(title, forKey: "title")
        }

        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not update. \(error), \(error.userInfo)")
        }
        
    }
    
}
