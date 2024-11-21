//
//  PhotosCollectionViewController.swift
//  iFlex
//
//  Created by Spencer Steggell on 11/11/24.
//

import Foundation
import UIKit
import CoreData

class PhotosCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    //MARK: OUTLETS
    weak var albums: FitnessAlbum!
    @IBOutlet weak var photosCollectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet var photosCollectionView: UICollectionView!
    let numberOfColumns: CGFloat = 3
    let cellSpacing: CGFloat = 10
    var photoThumbnail: UIImage!
    var photoDate = Date()
    var fetchedResultsController: NSFetchedResultsController<ProgressPhotos>!
    
    //MARK: FETCH Request
    
    func setUpFetchedResultsController() {
        let fetchRequest: NSFetchRequest<ProgressPhotos> = ProgressPhotos.fetchRequest()
        
        // Sort by creation date descending to get the latest photos first
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Add a predicate to only fetch photos for the current album
        fetchRequest.predicate = NSPredicate(format: "album == %@", albums)
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        print("Number of photos in album: \(fetchedResultsController.fetchedObjects?.count ?? 0)")
    }
    
    
    // MARK: Bar Button Items.
    
    lazy var editBtn: UIBarButtonItem = {
        let barBtnItem = UIBarButtonItem(title: "Select", style: .done, target: self, action: #selector(editPhotos))
        barBtnItem.tintColor = ColorManager.textColor
        return barBtnItem
    }()
    
    lazy var cancelBtn: UIBarButtonItem = {
        let barBtnItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelEditing))
        barBtnItem.tintColor = ColorManager.accentColor
        return barBtnItem
    }()
    
    lazy var deleteBtn: UIBarButtonItem = {
        let barBtnItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deletePhotos))
        barBtnItem.tintColor = .red
        return barBtnItem
    }()
    
    lazy var cameraBtn: UIBarButtonItem = {
        let barBtnItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(cameraSegue))
        barBtnItem.tintColor = ColorManager.accentColor
        return barBtnItem
    }()
    
    lazy var compareBtn: UIBarButtonItem = {
        let barBtnItem = UIBarButtonItem(title: "Compare", style: .done, target: self, action: #selector(comparePhotos))
        barBtnItem.tintColor = ColorManager.accentColor
        return barBtnItem
    }()
    
    func setUpToolBar() {
        
        navigationItem.rightBarButtonItem = editBtn
        toolbarItems = [.flexibleSpace(), cameraBtn, .flexibleSpace()]
        navigationController?.isToolbarHidden = false
        
        
    }
    
    
    //MARK: ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpToolBar()
        setUpFetchedResultsController()
        setViewLayout()
        updateAlbumCoverPhoto()
        navigationItem.title = albums?.name
        print("Current album: \(albums?.name ?? "No album selected")")
        let backImage = UIImage(systemName: "chevron.backward")
        let backButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
        
        if let gradientImage = ColorManager.shared.createGradientImage(size: view.bounds.size) {
            photosCollectionView.backgroundColor = UIColor(patternImage: gradientImage)
        }
        
        print("Current album: \(albums?.name ?? "No album selected")")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            try fetchedResultsController.performFetch()
            self.collectionView.reloadData()
            print("Number of photos in album: \(fetchedResultsController.fetchedObjects?.count ?? 0)")
        } catch {
            print("Failed to fetch photos: \(error)")
        }
        NotificationCenter.default.addObserver(self, selector: #selector(contextObjectsDidChange), name: Notification.Name("load"), object: nil)
    }
    
    
    
    //MARK: Editing Photos
    
    @objc func editPhotos() {
        editBtn.isEnabled = false
        navigationItem.rightBarButtonItem = cancelBtn
        navigationItem.leftBarButtonItem?.isEnabled = false
        toolbarItems = [compareBtn, .flexibleSpace(), deleteBtn]
        //compareBtn.isEnabled = false
        photosCollectionView.allowsMultipleSelection = true
        photosCollectionView.reloadData()
    }
    
    @objc func cancelEditing() {
        exitEditMode()
    }
    
    //MARK: Deleting photos
    
    @objc func deletePhotos() {
        print("Deleting Albums")
        
        guard let selectedIndexPaths = photosCollectionView.indexPathsForSelectedItems else {
            print("No items selected for deletion")
            return
        }
        
        print("Selected items for deletion: \(selectedIndexPaths)")
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // Temporarily disable delegate to prevent automatic UI updates
        fetchedResultsController.delegate = nil
        
        // Sort the selected index paths in descending order to delete safely
        let sortedIndexPaths = selectedIndexPaths.sorted { $0.item > $1.item }
        
        context.performAndWait {
            for indexPath in sortedIndexPaths {
                let photosToDelete = fetchedResultsController.object(at: indexPath)
                context.delete(photosToDelete)
            }
            
            do {
                try context.save()
                print("Successfully deleted albums")
            } catch {
                print("Failed to delete albums: \(error)")
            }
        }
        
        // Manually refetch data and reload collection view
        do {
            try fetchedResultsController.performFetch()
            photosCollectionView.reloadData()
            updateAlbumCoverPhoto()
        } catch {
            print("Failed to refetch after deletion: \(error)")
        }
        
        // Re-enable the delegate
        fetchedResultsController.delegate = self
        
        // Exit editing mode after deletion
        exitEditMode()
    }
    
    @objc func comparePhotos() {
        guard let selectedIndexPaths = photosCollectionView.indexPathsForSelectedItems, selectedIndexPaths.count == 2 else {
                print("Please select exactly two photos to compare.")
                return
            }


            // Fetch the selected photos from the fetchedResultsController
            let firstPhoto = fetchedResultsController.object(at: selectedIndexPaths[0])
            let secondPhoto = fetchedResultsController.object(at: selectedIndexPaths[1])

            // Ensure both photos have image data
            guard let firstImageData = firstPhoto.imageData, let secondImageData = secondPhoto.imageData,
                  let firstImage = UIImage(data: firstImageData), let secondImage = UIImage(data: secondImageData) else {
                print("Error fetching selected photos.")
                return
            }

            // Instantiate the ComparisonViewController
            let comparisonVC = ComparisonViewController()
            comparisonVC.leftImage = firstImage
        comparisonVC.leftDate = firstPhoto.creationDate
        comparisonVC.rightImage = secondImage
        comparisonVC.rightDate = secondPhoto.creationDate

            // Push the comparison view controller to the navigation stack
            navigationController?.pushViewController(comparisonVC, animated: true)
        
    }
    
    func exitEditMode() {
        
        navigationItem.rightBarButtonItem = editBtn
        navigationItem.leftBarButtonItem?.isEnabled = true
        editBtn.isEnabled = true
        toolbarItems = [.flexibleSpace(), cameraBtn, .flexibleSpace()]
        photosCollectionView.allowsMultipleSelection = false
        photosCollectionView.reloadData()
        deselectAllItems(animated: false)
    }
    
    func deselectAllItems(animated: Bool) {
        guard let selectedItems = photosCollectionView.indexPathsForSelectedItems else {
            print("No items selected")
            return }
        print("Selected items before deselecting: \(selectedItems)")
        for indexPath in selectedItems {
            photosCollectionView.deselectItem(at: indexPath, animated: animated)
            print(("Deselected item: \(indexPath)"))
            // }
        }
    }
    
    //MARK: Camera Segue
    
    @objc func cameraSegue() {
        performSegue(withIdentifier: "showCameraView", sender: self)
    }
    
    @objc func contextObjectsDidChange(_ notification: Notification) {
        print("Updating Collection View")
        DispatchQueue.main.async {
            do {
                try self.fetchedResultsController.performFetch()
                self.photosCollectionView.reloadData()
                self.updateAlbumCoverPhoto()
            } catch {
                print("Failed to fetch updated photos after save: \(error)")
            }
        }
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    
    func updateAlbumCoverPhoto() {
        print("Updating Album Cover Photo in Function")
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // Fetch the latest photo in the album
        let fetchRequest: NSFetchRequest<ProgressPhotos> = ProgressPhotos.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "album == %@", albums)
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchLimit = 1
        
        do {
            let latestPhoto = try context.fetch(fetchRequest).first
            if let imageData = latestPhoto?.imageData {
                albums.coverPhoto = imageData
                print("Updated cover photo is non-nil: \(albums.coverPhoto != nil)")
                try context.save()
                print("Album cover photo updated")
            } else {
                albums.coverPhoto = nil
                print("No photos found in album to update cover photo.")
            }
        } catch {
            print("Failed to fetch latest photo or save album cover: \(error)")
        }
    }
    
    
    
    
    
    
    //MARK: Set Up Collection View
    
    
    //Functioning Code:
    func setViewLayout() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width
        layout.sectionInset = UIEdgeInsets(top:5, left: 0, bottom: 5, right: 0)
        layout.itemSize = CGSize(width: width / 3, height: width / 3)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView!.collectionViewLayout = layout
    }
    
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let totalwidth = collectionView.bounds.size.width;
        let numberOfCellsPerRow = 3
        let oddEven = indexPath.row / numberOfCellsPerRow % 2
        let dimensions = CGFloat(Int(totalwidth) / numberOfCellsPerRow)
        if (oddEven == 0) {
            return CGSize(width: dimensions, height: dimensions)
        } else {
            return CGSize(width: dimensions, height: dimensions / 2)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photos = fetchedResultsController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionPhotoCell", for: indexPath) as! CollectionPhotoCell
        
        print("Printing Photos Data: \(photos.imageData!)")
        
        // Set album name
        cell.img.image = UIImage(data: photos.imageData! as Data)
        cell.photoDate = photos.creationDate!
        cell.allowsMultipleSelection = photosCollectionView.allowsMultipleSelection
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates(nil, completion: nil)
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                collectionView.insertItems(at: [newIndexPath])
            }
        case .delete:
            if let indexPath = indexPath {
                collectionView.deleteItems(at: [indexPath])
            }
        case .update:
            if let indexPath = indexPath {
                collectionView.reloadItems(at: [indexPath])
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                collectionView.moveItem(at: indexPath, to: newIndexPath)
            }
        @unknown default:
            fatalError("Unknown change type in NSFetchedResultsController")
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates(nil, completion: nil)
    }

    //MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)  {
         if (segue.identifier == "showCameraView") {
             let destViewController : CameraViewController = segue.destination as! CameraViewController
             destViewController.albums = self.albums
             print("prepare ran for Camera View")
         }
        
        else if segue.identifier == "showPhotoPage" {
                 
                }
            }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           if editBtn.isEnabled == false {
               let cell = collectionView.cellForItem(at: indexPath)
                   cell?.layer.borderColor = UIColor.blue.cgColor
                   cell?.layer.borderWidth = 3
                   cell?.isSelected = true
           } else {
               // Instantiate the PhotoPageViewController and present it
                       let pageVC = PhotoPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)

                       // Pass the photo data to the page view controller
               if let fetchedObjects = fetchedResultsController.fetchedObjects {
                   let photos = fetchedObjects.compactMap { UIImage(data: $0.imageData!) }
                   let photoDates = fetchedObjects.compactMap { $0.creationDate }
                   let selectedAlbum = self.albums
                   
                   pageVC.albums = selectedAlbum
                   pageVC.photos = photos
                   pageVC.photoDates = photoDates
                   pageVC.currentIndex = indexPath.item // Start from the tapped photo
                   navigationController?.pushViewController(pageVC, animated: true)
               }
           }
        }
    
    
//End of PhotosCollectionViewController
}
