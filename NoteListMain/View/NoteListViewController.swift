//
//  ViewController.swift
//  NoteList
//
//  Created by Александра Сергеева on 14.02.2024.
//

import UIKit

class NoteListViewController: UIViewController {
    
    private var notes: [NoteListNoteModel] = []
    
    private let viewModel = NoteListViewModel()
    
    private lazy var layout: UICollectionViewCompositionalLayout = {
       let layout = UICollectionViewCompositionalLayout() { section, layoutEnvironment in
           var config = UICollectionLayoutListConfiguration(appearance: .sidebarPlain)
           config.trailingSwipeActionsConfigurationProvider = { indexPath in
               let del = UIContextualAction(style: .destructive, title: "Delete") {
                   [weak self] action, view, completion in
                   self?.viewModel.deleteNote(index: indexPath.item)
                   completion(true)
               }
               return UISwipeActionsConfiguration(actions: [del])
           }
            let layoutSection =  NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
            layoutSection.interGroupSpacing = 10
            return layoutSection
        }
        return layout
    }()
    
    private lazy var noteListCollectionView: UICollectionView = {
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
        label.text = "Error loading notes"
        label.font = .systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadNotes()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        viewModel.viewStateDidChange = { viewState in
            self.renderViewState(state: viewState)
        }
        
        viewModel.onAction = { action in
            self.processAction(action: action)
        }
    }
    
    private func processAction(action: NoteListAction) {
        switch action {
        case .openNoteEdit(let noteId):
            let editNoteVC = EditNoteViewController()
            editNoteVC.noteID = noteId
            self.navigationController?.pushViewController(editNoteVC, animated: true)
        case .showErrorDialog(let errorText):
            let alert = UIAlertController(title: "Error", message: errorText, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    
    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(noteListCollectionView)
        view.addSubview(errorLabel)
        navigationItem.title = "My notes"
        navigationItem.rightBarButtonItem = addNoteButton
        
        let constraints = [
            noteListCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            noteListCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            noteListCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            noteListCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func renderViewState(state: NoteListState) {
        switch state {
        case .success(let fetchedNotes):
            self.notes = fetchedNotes
            noteListCollectionView.reloadData()
            errorLabel.isHidden = true
            noteListCollectionView.isHidden = false
        case .error:
            noteListCollectionView.isHidden = true
            errorLabel.isHidden = false
        }
    }
    
    @objc private func addNoteButtonClicked() {
        viewModel.onAddNoteButtonTapped()
    }
    
}

extension NoteListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let clickedNoteId = notes[indexPath.row].id
        viewModel.onNoteClicked(id: clickedNoteId)
    }
}

extension NoteListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoteListCollectionViewCell.identifier, for: indexPath) as! NoteListCollectionViewCell
        let note = notes[indexPath.row]
        cell.fillCell(note: note)
        return cell
    }
    
    
}

