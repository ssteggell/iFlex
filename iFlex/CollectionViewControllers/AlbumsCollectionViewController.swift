//
//  AlbumCollectionViewController.swift
//  iFlex
//
//  Created by Spencer Steggell on 11/6/24.
//

import Foundation
import UIKit
import CoreData


class AlbumsCollectionViewController:
    UICollectionViewController, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    
    
    //MARK: Properites
    
    @IBOutlet weak var albumCollectionView: UICollectionView!
    @IBOutlet weak var albumCollectionViewFlowLayout: UICollectionViewFlowLayout!
    var isAlbumEditing: Bool = false
    
    var fetchedResultsController: NSFetchedResultsController<FitnessAlbum>!
    
 
    
    //MARK: ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        albumCollectionView.delegate = self
        albumCollectionView.dataSource = self
        
        setUpFetchedResultsController()
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed to fetch albums: \(error)")
        }
        setViewLayout()
        albumCollectionView.reloadData()
        setUpToolBar()
        albumCollectionView.allowsMultipleSelection = false
        if let gradientImage = ColorManager.shared.createGradientImage(size: view.bounds.size) {
            albumCollectionView.backgroundColor = UIColor(patternImage: gradientImage)
        }
        
    }
    
    //MARK: Setup Methods
    
    lazy var editBtn: UIBarButtonItem = {
        let barBtnItem = UIBarButtonItem(title: "Select", style: .done, target: self, action: #selector(editAlbums))
        barBtnItem.tintColor = ColorManager.textColor
        return barBtnItem
    }()
    
    lazy var cancelBtn: UIBarButtonItem = {
        let barBtnItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelEditing))
        barBtnItem.tintColor = ColorManager.accentColor
        return barBtnItem
    }()
    
    lazy var deleteBtn: UIBarButtonItem = {
        let barBtnItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteAlbums))
        barBtnItem.tintColor = ColorManager.warningColor
        return barBtnItem
    }()
    
    lazy var addAlbumBtn: UIBarButtonItem = {
        let barBtnItem = UIBarButtonItem(title: "Add Album", style: .done, target: self, action: #selector(addAlbum))
        barBtnItem.tintColor = ColorManager.accentColor
        return barBtnItem
    }()
    
    func setUpFetchedResultsController() {
        let fetchRequest: NSFetchRequest<FitnessAlbum> = FitnessAlbum.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
    }
    
    func setUpToolBar() {
        navigationItem.leftBarButtonItem = addAlbumBtn
        navigationItem.rightBarButtonItem = editBtn
        navigationController?.isToolbarHidden = false
        if let toolbar = navigationController?.toolbar {
            toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
            toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
            toolbar.backgroundColor = .clear
            toolbar.isTranslucent = true
        }
    }
    
 
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(updateAlbumCoverPhoto), name: Notification.Name("update"), object: nil)
        navigationController?.isToolbarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK:  User Actions
    
    @objc func addAlbum() {
        print("addalbums button pressed")
        presentNewAlbumAlert()
    }
    
    @objc func editAlbums() {
        toolbarItems = [UIBarButtonItem.flexibleSpace(), deleteBtn]
        navigationItem.rightBarButtonItem = cancelBtn
        navigationController?.isToolbarHidden = false
        editBtn.isEnabled = false
        addAlbumBtn.isEnabled = false
        albumCollectionView.allowsMultipleSelection = true
        albumCollectionView.reloadData()
        print("Entered album editing mode")
    }
    
    @objc func cancelEditing() {
        print("Cancel pressed")
        exitEditMode()
        deselectAllItems(animated: true)
    }
    
    @objc func deleteAlbums() {
        print("Deleting Albums")
        
        guard let selectedIndexPaths = albumCollectionView.indexPathsForSelectedItems else {
            print("No items selected for deletion")
            return
        }
        
        print("Selected items for deletion: \(selectedIndexPaths)")
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        fetchedResultsController.delegate = nil
        let sortedIndexPaths = selectedIndexPaths.sorted { $0.item > $1.item }
        
        context.performAndWait {
            for indexPath in sortedIndexPaths {
                let albumToDelete = fetchedResultsController.object(at: indexPath)
                context.delete(albumToDelete)
            }
            
            do {
                try context.save()
                print("Successfully deleted albums")
            } catch {
                print("Failed to delete albums: \(error)")
            }
        }
        do {
            try fetchedResultsController.performFetch()
            albumCollectionView.reloadData()
        } catch {
            print("Failed to refetch after deletion: \(error)")
        }
        fetchedResultsController.delegate = self
        exitEditMode()
    }
    
    //MARK: Supporting methods
    
    func exitEditMode() {
        toolbarItems = nil
        navigationItem.rightBarButtonItem = editBtn
        navigationController?.isToolbarHidden = true
        editBtn.isEnabled = true
        addAlbumBtn.isEnabled = true
        albumCollectionView.allowsMultipleSelection = false
        albumCollectionView.reloadData()
        // Deselect all items to avoid UI inconsistencies
        deselectAllItems(animated: false)
    }
    
    @objc func updateAlbumCoverPhoto() {
        //delete function
        
    }
    
    func deselectAllItems(animated: Bool) {
        guard let selectedItems = albumCollectionView.indexPathsForSelectedItems else {
            print("No items selected")
            return }
        print("Selected items before deselecting: \(selectedItems)")
        for indexPath in selectedItems {
            albumCollectionView.deselectItem(at: indexPath, animated: animated)
            print(("Deselected item: \(indexPath)"))
        }
    }
    
    func presentNewAlbumAlert() {
        let alert = UIAlertController(title: "Add New Album", message: "Enter name for new album", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            NotificationCenter.default.removeObserver(self!, name: UITextField.textDidChangeNotification, object: alert.textFields?.first)
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] action in
            if let name = alert.textFields?.first?.text {
                self?.addAlbumToCoreData(name: name)
            }
            NotificationCenter.default.removeObserver(self!, name: UITextField.textDidChangeNotification, object: alert.textFields?.first)
        }
        saveAction.isEnabled = false
        
        alert.addTextField { textField in
            textField.placeholder = "Name"
            textField.autocapitalizationType = .words
            textField.translatesAutoresizingMaskIntoConstraints = false
            
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main) { [weak saveAction] _ in
                if let text = textField.text, !text.isEmpty {
                    saveAction?.isEnabled = true
                } else {
                    saveAction?.isEnabled = false
                }
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        present(alert, animated: true)
    }
    
    func addAlbumToCoreData(name: String) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let newAlbum = FitnessAlbum(context: context)
        
        newAlbum.name = name
        newAlbum.creationDate = Date()
        
        do {
            try context.save()
            
        } catch {
            print("Failed to save Album: \(error)")
        }
        
    }
    
    
    //MARK: Collection View Settings.
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let itemCount = fetchedResultsController.sections?[section].numberOfObjects ?? 0
        print("Number of items in section \(section): \(itemCount)")
        return itemCount
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let album = fetchedResultsController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionAlbumCell", for: indexPath) as! CollectionAlbumCell
        
        // Set album name
        cell.albumName.text = album.name
        
        // Set album photo or default image
        if let albumPhotoData = album.coverPhoto, let image = UIImage(data: albumPhotoData) {
            cell.albumPhoto.image = image
            print("Setting up first image!")
        } else {
            cell.albumPhoto.image = UIImage(named: "defaultImage")
            print("No photo found")
        }
        
        cell.allowsMultipleSelection = albumCollectionView.allowsMultipleSelection
        return cell
    }
    
    func setViewLayout() {
        
        albumCollectionViewFlowLayout.scrollDirection = .vertical
        albumCollectionViewFlowLayout.minimumLineSpacing = 5
        albumCollectionViewFlowLayout.minimumInteritemSpacing = 10
        albumCollectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        albumCollectionViewFlowLayout.collectionView?.backgroundView = UIView()
        albumCollectionView.sizeToFit()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalWidth = collectionView.bounds.width
        let numberOfCellsPerRow: CGFloat = 2
        let padding: CGFloat = 10 // This should match your `minimumInteritemSpacing`
        let totalPadding = (numberOfCellsPerRow + 1) * padding
        
        let individualWidth = (totalWidth - totalPadding) / numberOfCellsPerRow
        let individualHeight = individualWidth + 40 // Adding extra space for the label (adjust as needed)
        
        return CGSize(width: individualWidth, height: individualHeight)
    }
    
    //delete?
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // albumCollectionView.performBatchUpdates(nil, completion: nil)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                print("Inserting item at: \(newIndexPath)")
                albumCollectionView.insertItems(at: [newIndexPath])
            }
        case .delete:
            if let indexPath = indexPath {
                print("Deleting item at: \(indexPath)")
                albumCollectionView.deleteItems(at: [indexPath])
            }
        case .update:
            if let indexPath = indexPath {
                print("Updating item at: \(indexPath)")
                albumCollectionView.reloadItems(at: [indexPath])
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                print("Moving item from \(indexPath) to \(newIndexPath)")
                albumCollectionView.moveItem(at: indexPath, to: newIndexPath)
            }
        @unknown default:
            fatalError("Unknown change type in NSFetchedResultsController")
        }
    }
    
    //delete?
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //albumCollectionView.performBatchUpdates(nil, completion: nil)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if albumCollectionView.allowsMultipleSelection {
            print("Selected cell at indexPath \(indexPath)")
        } else {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
    
    
    //MARK: Segue
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "albumDetailSegue" {
            return !collectionView.allowsMultipleSelection && (collectionView.indexPathsForSelectedItems?.isEmpty == false)
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "albumDetailSegue",
              let vc = segue.destination as? PhotosCollectionViewController,
              let indexPath = collectionView.indexPathsForSelectedItems?.first else {
            return
        }
        
        if editBtn.isEnabled {
            vc.albums = fetchedResultsController.object(at: indexPath)
        }
    }
    
    //End of AlbumsCollectionViewController
}


