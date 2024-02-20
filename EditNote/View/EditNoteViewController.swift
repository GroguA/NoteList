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
    
    private let textSize: CGFloat = 17
    
    private lazy var noteTitleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Fill title"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .whileEditing
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.textAlignment = .justified
        textField.font = .systemFont(ofSize: 18, weight: .medium)
        textField.delegate = self
        return textField
    }()
    
    private lazy var noteTextTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.1).cgColor
        textView.layer.borderWidth = 2
        textView.layer.cornerRadius = 8
        textView.layer.masksToBounds = true
        textView.font = .systemFont(ofSize: 17, weight: .regular)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.autocapitalizationType = .none
        textView.autocorrectionType = .no
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
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Fill note"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .lightGray.withAlphaComponent(0.7)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = !noteTextTextView.text.isEmpty
        return label
    }()
    
    private lazy var boldStyleButton: UIBarButtonItem = {
        return UIBarButtonItem(
            image: UIImage(systemName: "bold"),
            style: .plain,
            target: self,
            action: #selector(makeTextBold)
        )
    }()
    
    private lazy var cursiveStyleButton: UIBarButtonItem = {
        return UIBarButtonItem(
            image: UIImage(systemName: "italic"),
            style: .plain,
            target: self,
            action: #selector(makeTextCursive)
        )
    }()
    
    private lazy var underlineStyleButton: UIBarButtonItem = {
        return UIBarButtonItem(
            image: UIImage(systemName: "underline"),
            style: .plain,
            target: self,
            action: #selector(makeTextUnderline)
        )
    }()
    
    private lazy var defaultStyleButton: UIBarButtonItem = {
        return UIBarButtonItem(
            image: UIImage(systemName: "character"),
            style: .plain,
            target: self,
            action: #selector(makeSelectedTextDefault)
        )
    }()
    
    private var currentEnabledAttribute: [NSAttributedString.Key : Any]? = nil
    
    private let boldAttribute: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)]
    private let cursiveAttribute: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 17)]
    
    private let underlineAttribute: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 17),
        .underlineStyle: NSUnderlineStyle.thick.rawValue
    ]
    
    private let defaultAttribute: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)]
    
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
        positiveSeparator.width = view.bounds.width/4 - 16
        toolBar.items = [defaultStyleButton, positiveSeparator, boldStyleButton, positiveSeparator, cursiveStyleButton, positiveSeparator, underlineStyleButton]
        
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
        case .success(let title, let attributedText):
            noteTitleTextField.text = title
            noteTextTextView.delegate = nil
            noteTextTextView.attributedText = attributedText
            noteTextTextView.delegate = self
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
        processAttributeClicked(clickedAttribute: cursiveAttribute)
    }
    
    @objc private func makeTextBold() {
        processAttributeClicked(clickedAttribute: boldAttribute)
    }
    
    @objc private func makeTextUnderline() {
        processAttributeClicked(clickedAttribute: underlineAttribute)
    }
    
    @objc private func makeSelectedTextDefault() {
        changeSelectedRangeTextAttribute(attribute: defaultAttribute)
    }
    
    private func processAttributeClicked(clickedAttribute: [NSAttributedString.Key : Any]) {
        if noteTextTextView.selectedRange.length == 0 {
            toggleStyleButtons(clickedAttribute: clickedAttribute)
        } else {
            changeSelectedRangeTextAttribute(attribute: clickedAttribute)
        }
    }
    
    
    private func toggleStyleButtons(clickedAttribute: [NSAttributedString.Key : Any]) {
        if currentEnabledAttribute == clickedAttribute {
            self.currentEnabledAttribute = nil
        } else {
            self.currentEnabledAttribute = clickedAttribute
        }
        
        boldStyleButton.isSelected = false
        underlineStyleButton.isSelected = false
        cursiveStyleButton.isSelected = false
        
        if currentEnabledAttribute == boldAttribute {
            boldStyleButton.isSelected = true
        } else if currentEnabledAttribute == underlineAttribute {
            underlineStyleButton.isSelected = true
        } else if currentEnabledAttribute == cursiveAttribute {
            cursiveStyleButton.isSelected = true
        }
        
    }
    
    private func changeSelectedRangeTextAttribute(attribute: [NSAttributedString.Key : Any]) {
        let range = noteTextTextView.selectedRange
        let text = noteTextTextView.attributedText
        guard let text else { return }
        let attrText = NSMutableAttributedString(attributedString: text)
        attrText.setAttributes(attribute, range: range)
        viewModel.textChanged(title: noteTitleTextField.text, attributedText: attrText)
    }
}

extension EditNoteViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let currentString = textField.text as? NSString {
            let newString = currentString.replacingCharacters(in: range, with: string)
            viewModel.textChanged(title: newString, attributedText: noteTextTextView.attributedText)
        }
        return false
    }
}

extension EditNoteViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentAttributedText = NSMutableAttributedString(attributedString: textView.attributedText)
        let mutableAttributedText = NSMutableAttributedString(string: text)
        if let currentEnabledAttribute {
            mutableAttributedText.setAttributes(currentEnabledAttribute, range: NSRange(text.startIndex..., in: text))
        } else {
            mutableAttributedText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont (ofSize: textSize), range: NSRange(text.startIndex..., in: text))
        }
        currentAttributedText.replaceCharacters(in: range, with: mutableAttributedText)
        viewModel.textChanged(title: noteTitleTextField.text, attributedText: currentAttributedText)
        return false
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

private func ==(lhs: [NSAttributedString.Key : Any]?, rhs: [NSAttributedString.Key : Any]? ) -> Bool {
    guard let lhs = lhs, let rhs = rhs else {
        return false
    }
    return NSDictionary(dictionary: lhs).isEqual(to: rhs)
}
