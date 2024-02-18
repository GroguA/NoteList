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
        textField.font = .systemFont(ofSize: 17, weight: .medium)
        textField.delegate = self
        return textField
    }()
    
    private lazy var noteTextTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.1).cgColor
        textView.layer.borderWidth = 2
        textView.layer.cornerRadius = 8
        textView.layer.masksToBounds = true
        textView.font = .systemFont(ofSize: 16, weight: .regular)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.autocapitalizationType = .sentences
        textView.autocorrectionType = .default
        textView.textAlignment = .justified
        textView.delegate = self
        return textView
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Error loading note"
        label.font = .systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private let toolBar: UIToolbar = {
        let bar = UIToolbar()
        bar.sizeToFit()
        return bar
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Fill note"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .lightGray.withAlphaComponent(0.7)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = !noteTextTextView.text.isEmpty
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupToolBar()
        
        viewModel.viewStateDidChange = { state in
            self.renderViewState(state: state)
        }
        
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(noteTitleTextField)
        view.addSubview(noteTextTextView)
        view.addSubview(errorLabel)
        view.addSubview(placeholderLabel)
        noteTextTextView.inputAccessoryView = toolBar
        
        guard let noteID else { return }
        viewModel.loadNote(id: noteID)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        let constraints = [
            noteTitleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            noteTitleTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            noteTitleTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            noteTextTextView.topAnchor.constraint(equalTo: noteTitleTextField.bottomAnchor, constant: 16),
            noteTextTextView.leadingAnchor.constraint(equalTo: noteTitleTextField.leadingAnchor),
            noteTextTextView.trailingAnchor.constraint(equalTo: noteTitleTextField.trailingAnchor),
            noteTextTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            placeholderLabel.topAnchor.constraint(equalTo: noteTextTextView.topAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: noteTextTextView.leadingAnchor, constant: 8),
            
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupToolBar() {
        let positiveSeparator = UIBarButtonItem(barButtonSystemItem:.fixedSpace, target: nil, action: nil)
        positiveSeparator.width = view.bounds.width/4
        let boldText = UIBarButtonItem(image: UIImage(systemName: "bold"), style: .plain, target: self, action: #selector(makeTextBold))
        let cursiveText = UIBarButtonItem(image: UIImage(systemName: "italic"), style: .plain, target: self, action: #selector(makeTextCursive))
        let underlineText = UIBarButtonItem(image: UIImage(systemName: "underline"), style: .plain, target: self, action: #selector(makeTextUnderline))
        toolBar.items = [boldText, positiveSeparator, cursiveText, positiveSeparator, underlineText]
        
    }
    
    @objc private func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            noteTextTextView.contentInset = .zero
        } else {
            noteTextTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        noteTextTextView.scrollIndicatorInsets = noteTextTextView.contentInset
        
        let selectedRange = noteTextTextView.selectedRange
        noteTextTextView.scrollRangeToVisible(selectedRange)
    }
    
    private func renderViewState(state: EditNoteState) {
        switch state {
        case .success(let text, let title, let attributedText):
            noteTextTextView.text = text
            noteTitleTextField.text = title
            noteTextTextView.attributedText = attributedText
            errorLabel.isHidden = true
            placeholderLabel.isHidden = !noteTextTextView.text.isEmpty
        case .error:
            noteTextTextView.isHidden = true
            noteTitleTextField.isHidden = true
            errorLabel.isHidden = false
            placeholderLabel.isHidden = true
            
        }
    }
    
    @objc private func makeTextCursive() {
        let range = noteTextTextView.selectedRange
        let text = noteTextTextView.text
        guard let text else { return }
        let attributedString = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16.0)])
        let italicFontAttribute = [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 16.0)]
        noteTextTextView.textStorage.addAttribute(NSAttributedString.Key.font, value: italicFontAttribute, range: range)
        attributedString.addAttributes(italicFontAttribute, range: range)
        noteTextTextView.attributedText = attributedString
    }
    
    @objc private func makeTextBold() {
        let range = noteTextTextView.selectedRange
        let text = noteTextTextView.text
        guard let text else { return }
        let attributedString = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16.0)])
        let boldFontAttribute = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16.0)]
        attributedString.addAttributes(boldFontAttribute, range: range)
        noteTextTextView.attributedText = attributedString
    }
    
    @objc private func makeTextUnderline() {
        let range = noteTextTextView.selectedRange
        let text = noteTextTextView.text
        guard let text else { return }
        let attributedString = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16.0)])
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
        attributedString.addAttributes(underlineAttribute, range: range)
        noteTextTextView.attributedText = attributedString
    }
}

extension EditNoteViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let currentString = textField.text as? NSString {
            let newString = currentString.replacingCharacters(in: range, with: string)
            viewModel.textChanged(title: newString, text: nil, attributedText: textField.attributedText)
        }
        return true
    }
}

extension EditNoteViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let currentString = textView.text as? NSString {
            let newString = currentString.replacingCharacters(in: range, with: text)
            viewModel.textChanged(title: nil, text: newString, attributedText: textView.attributedText)
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = true
    }
    
}
