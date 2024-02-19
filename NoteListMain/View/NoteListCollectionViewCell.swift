//
//  NoteListCollectionViewCell.swift
//  NoteList
//
//  Created by Александра Сергеева on 15.02.2024.
//

import UIKit

class NoteListCollectionViewCell: UICollectionViewCell {
    static let identifier = "NoteListCollectionViewCell"
    
    private lazy var noteTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var noteTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.numberOfLines = 2
        label.textAlignment = .justified
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        contentView.addSubview(noteTextLabel)
        contentView.addSubview(noteTitleLabel)
        
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.gray.withAlphaComponent(0.2).cgColor
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        
        let constraints = [
            noteTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            noteTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            noteTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            noteTextLabel.topAnchor.constraint(equalTo: noteTitleLabel.bottomAnchor, constant: 8),
            noteTextLabel.leadingAnchor.constraint(equalTo: noteTitleLabel.leadingAnchor),
            noteTextLabel.trailingAnchor.constraint(equalTo: noteTitleLabel.trailingAnchor),
            noteTextLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ]
        
        NSLayoutConstraint.activate(constraints)

    }
    
    func fillCell(note: NoteListNoteModel) {
        noteTitleLabel.text = note.title
        noteTextLabel.text = note.text
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

