//
//  ViewController.swift
//  NoteList
//
//  Created by Александра Сергеева on 14.02.2024.
//

import UIKit

class NoteListViewController: UIViewController {
    
    var notes: [FetchNoteCoreDateModel] = []
    
    private let viewModel = NoteListViewModel()
    
    private let itemsPerRow: CGFloat = 1
    private let itemsPerView: CGFloat = 7
    private let sectionInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    
    private lazy var noteListCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.register(NoteListCollectionViewCell.self, forCellWithReuseIdentifier: NoteListCollectionViewCell.identifier)
        return collectionView
    }()
    
    private lazy var addNoteButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "plus.circle.fill"), style: .plain, target: self, action: #selector(addNoteButtonClicked))
        return button
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    override func viewWillAppear(_ animated: Bool) {
        NoteSource.shared.getAllNotes(onSuccess: { notes in
            self.notes = notes
        }, onError: { error in
            errorLabel.text = "\(error.localizedDescription)"
            errorLabel.isHidden = false
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    
    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(noteListCollectionView)
        view.addSubview(errorLabel)
        navigationItem.title = "My notes"
        navigationItem.rightBarButtonItem = addNoteButton
        
        errorLabel.isHidden = true
        
        let constraints = [
            noteListCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            noteListCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            noteListCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            noteListCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc private func addNoteButtonClicked() {
        navigationController?.pushViewController(EditNoteViewController(), animated: true)
        viewModel.onAddNoteButtonTapped()
    }
    
}

extension NoteListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let clickedNote = notes[indexPath.row]
        let editNoteVC = EditNoteViewController()
        editNoteVC.noteID = clickedNote.id
        navigationController?.pushViewController(editNoteVC, animated: true)
    }
}

extension NoteListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoteListCollectionViewCell.identifier, for: indexPath) as! NoteListCollectionViewCell
        let note = notes[indexPath.row]
        cell.setupViews(noteSetting: note)
        return cell
    }
    
    
}

extension NoteListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingWidht = sectionInsets.left * (itemsPerRow + 1)
        let paddingHeight = sectionInsets.top * itemsPerView
        let availableWidht = collectionView.bounds.width - paddingWidht
        let itemWidht = availableWidht/itemsPerRow
        let availibleHeight = collectionView.bounds.height - paddingHeight
        let itemHeight = availibleHeight/itemsPerView
        
        return CGSize(width: itemWidht, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.top
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.top
    }
}
