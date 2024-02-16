//
//  EditNoteViewController.swift
//  NoteList
//
//  Created by Александра Сергеева on 15.02.2024.
//

import UIKit

class EditNoteViewController: UIViewController {
    
    var noteID: String? = nil
    
    private let viewModel = EditNoteViewModel()
    
    private lazy var noteTitleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Fill title"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .whileEditing
        textField.autocapitalizationType = .sentences
        textField.autocorrectionType = .default
        textField.textAlignment = .justified
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
        textField.textAlignment = .justified
        textField.delegate = self
        return textField
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Error loading note"
        label.font = .systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        viewModel.viewStateDidChange = { state in
            self.renderViewState(state: state)
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(noteTitleTextField)
        view.addSubview(noteTextTextField)
        view.addSubview(errorLabel)
        
        guard let noteID else { return }
        viewModel.loadNote(id: noteID)
        
                
        let constraints = [
            noteTitleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            noteTitleTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            noteTitleTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            noteTextTextField.topAnchor.constraint(equalTo: noteTitleTextField.bottomAnchor, constant: 16),
            noteTextTextField.leadingAnchor.constraint(equalTo: noteTitleTextField.leadingAnchor),
            noteTextTextField.trailingAnchor.constraint(equalTo: noteTitleTextField.trailingAnchor),
            
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func renderViewState(state: EditNoteState) {
        switch state {
        case .success(let text, let title):
            noteTextTextField.text = text
            noteTitleTextField.text = title
        case .error:
            errorLabel.isHidden = true
            
        }
    }
    
    
}

extension EditNoteViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let currentString = textField.text as? NSString {
            let newString = currentString.replacingCharacters(in: range, with: string)
            if textField == noteTitleTextField {
                viewModel.textChanged(title: newString, text: nil)
            } else {
                viewModel.textChanged(title: nil, text: newString)
            }
        }
        return true
    }
}
