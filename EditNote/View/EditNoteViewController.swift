//
//  EditNoteViewController.swift
//  NoteList
//
//  Created by Александра Сергеева on 15.02.2024.
//

import UIKit

class EditNoteViewController: UIViewController {
    
    var noteID: String? = nil
    
    private lazy var noteTitleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Fill title"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .whileEditing
        textField.autocapitalizationType = .sentences
        textField.autocorrectionType = .default
        textField.delegate = self
        return textField
    }()
    
    private lazy var noteTextTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Fill note text"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .whileEditing
        textField.autocapitalizationType = .sentences
        textField.autocorrectionType = .default
        textField.delegate = self
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(noteTitleTextField)
        view.addSubview(noteTextTextField)
        
        let noteFields = NoteSource.shared.getNoteById(id: noteID)
        
        if noteFields != nil {
            noteTextTextField.text = noteFields?.text
            noteTitleTextField.text = noteFields?.title
        }
        
        let constraints = [
            noteTitleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            noteTitleTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            noteTitleTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            noteTextTextField.topAnchor.constraint(equalTo: noteTitleTextField.bottomAnchor, constant: 16),
            noteTextTextField.leadingAnchor.constraint(equalTo: noteTitleTextField.leadingAnchor),
            noteTextTextField.trailingAnchor.constraint(equalTo: noteTitleTextField.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    
}

extension EditNoteViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let noteID {
            if textField == noteTitleTextField {
                NoteSource.shared.updateNoteById(id: noteID, title: textField.text, text: nil)
            } else {
                NoteSource.shared.updateNoteById(id: noteID, title: nil, text: textField.text)
            }
        }
    }
}
