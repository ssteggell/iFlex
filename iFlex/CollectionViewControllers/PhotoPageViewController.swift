//
//  PhotoPageViewController.swift
//  iFlex
//
//  Created by Spencer Steggell on 11/14/24.
//

import Foundation
import UIKit
import CoreData

class PhotoPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, NSFetchedResultsControllerDelegate {
    
    //MARK: Outlets/Variables
    var photos: [UIImage] = []
    var photoDates: [Date] = []
    var currentIndex: Int = 0
    var albums: FitnessAlbum!
    var fetchedResultsController: NSFetchedResultsController<ProgressPhotos>!
    var currentImage: UIImage?
    
    
    //MARK: ViewDidLoad
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refetch the photos to ensure we have the latest data
        do {
            try fetchedResultsController.performFetch()
            guard let fetchedPhotos = fetchedResultsController.fetchedObjects else {
                print("Failed to fetch updated photos.")
                return
            }
            
            // Update photos and photoDates arrays with the latest data
            photos = fetchedPhotos.compactMap { UIImage(data: $0.imageData!) }
            photoDates = fetchedPhotos.compactMap { $0.creationDate }
            
            print("Photo date \(photoDates)")
            
            // If the current index exceeds the count after update, adjust it to the latest available index
            if currentIndex >= photos.count {
                currentIndex = max(photos.count - 1, 0)
            }
            
            // Refresh the current view controller with the updated photo
            if let currentViewController = photoDetailViewController(forIndex: currentIndex) {
                setViewControllers([currentViewController], direction: .forward, animated: false, completion: nil)
                // updateTitle(for: currentIndex)
            }
            
        } catch {
            print("Failed to fetch updated photos: \(error)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBlurredBackground()
        
        dataSource = self
        delegate = self
        if let initialViewController = photoDetailViewController(forIndex: currentIndex) {
            setViewControllers([initialViewController], direction: .forward, animated: true, completion: nil)
        }
        
        setUpToolBar()
        setUpFetchResultsController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    //MARK: Set Up Methods
    func setUpToolBar() {
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonTapped))
        let cameraButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(cameraButtonTapped))
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteButtonTapped))
        deleteButton.tintColor = .red
        toolbarItems = [deleteButton, UIBarButtonItem.flexibleSpace(), cameraButton, UIBarButtonItem.flexibleSpace()]
        navigationItem.rightBarButtonItems = [shareButton]
        navigationController?.isToolbarHidden = false
        
    }
    
    func setUpFetchResultsController() {
        let fetchRequest: NSFetchRequest<ProgressPhotos> = ProgressPhotos.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "album == %@", albums) // Ensure it fetches photos only for this album
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)] // Use `creationDate` or appropriate key
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            print("Number of photos fetched: \(fetchedResultsController.fetchedObjects?.count ?? 0)")
        } catch {
            print("Failed to fetch photos: \(error)")
        }
    }
    
    func setupBlurredBackground() {
        guard let image = currentImage else { return }
        
        // Create an image view with the current image
        let backgroundImageView = UIImageView(image: image)
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundImageView)
        
        // Pin the image view to the edges of the view
        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Create a blur effect
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurEffectView)
        
        // Pin the blur effect view to the edges of the view
        NSLayoutConstraint.activate([
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    //MARK: User Actions
    @objc func shareButtonTapped() {
        guard currentIndex < photos.count else {
            print("Invalid index for sharing")
            return
        }
        
        let imageToShare = photos[currentIndex]
        let activityViewController = UIActivityViewController(activityItems: [imageToShare], applicationActivities: nil)
        
        // Setting up a popover presentation for iPad compatibility
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    @objc func cameraButtonTapped() {
        let cameraVC = CameraViewController()
        let selectedAlbum = self.albums
        cameraVC.albums = selectedAlbum
        cameraVC.overlayImage = photos[currentIndex]
        navigationController?.pushViewController(cameraVC, animated: true)
    }
    
    
    //MARK: Delete button
    @objc func deleteButtonTapped() {
        guard currentIndex < photos.count else {
            print("Invalid index for deletion")
            return
        }
        let alert = UIAlertController(title: "Delete Photo", message: "Are you sure you want to delete this photo?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deletePhoto()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func deletePhoto() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // Safely fetch the photo to delete using the fetchedResultsController
        guard let photoToDelete = fetchedResultsController.fetchedObjects?[currentIndex] else {
            print("Photo not found at the current index")
            return
        }
        
        // Delete from Core Data
        context.delete(photoToDelete)
        print("Deleting photo at index \(currentIndex)")
        
        do {
            try context.save()
            print("Photo successfully deleted.")
            // Refetch the data after deletion to update the fetchedResultsController
            try fetchedResultsController.performFetch()
            
            // Update the photos and photoDates arrays with the latest data
            if let updatedPhotos = fetchedResultsController.fetchedObjects {
                photos = updatedPhotos.compactMap { UIImage(data: $0.imageData!) }
                photoDates = updatedPhotos.compactMap { $0.creationDate }
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
            
            // Handle empty photos case
            if photos.isEmpty {
                navigationController?.popViewController(animated: true)
                //return
            }
            
            // Update the page view to show the next available photo
            var nextIndex = currentIndex
            var direction: UIPageViewController.NavigationDirection = .forward
            
            // If deleting the last photo, move to the previous photo
            if currentIndex == photos.count {
                nextIndex = max(0, currentIndex - 1)
                direction = .reverse
            }
            
            currentIndex = nextIndex
            if let newViewController = photoDetailViewController(forIndex: currentIndex) {
                setViewControllers([newViewController], direction: direction, animated: true, completion: nil)
            }
        } catch {
            print("Failed to delete photo: \(error)")
        }
    }
    
    
    //MARK: View Controller at index
    func viewControllerForPage(at index: Int) -> PhotoDetailViewController {
        let photoDetailVC = PhotoDetailViewController()
        photoDetailVC.selectedImage = photos[index]
        if index < photoDates.count {
            photoDetailVC.photoDate = photoDates[index]
        }
        return photoDetailVC
    }
    
    // Function to update the navigation title with the photo date
    func updateTitle(for index: Int) {
        guard index >= 0 && index < photos.count else { return }
        let date = photoDates[index]
        
        // Format the date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        // Set the formatted date as the navigation title
        navigationItem.title = dateFormatter.string(from: date)
        
        // Animate the title change for a smoother effect
        UIView.transition(with: navigationController!.navigationBar, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.navigationItem.title = dateFormatter.string(from: date)
        }, completion: nil)
    }
    
    
    // Helper method to create a PhotoDetailViewController for a specific index
    func photoDetailViewController(forIndex index: Int) -> PhotoDetailViewController? {
        guard index >= 0 && index < photos.count else {
            return nil
        }
        
        let detailVC = PhotoDetailViewController()
        detailVC.selectedImage = photos[index]
        detailVC.photoDate = photoDates[index]
        return detailVC
    }
    
    // MARK: - UIPageViewControllerDataSource Methods
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? PhotoDetailViewController,
              let currentIndex = photos.firstIndex(of: currentVC.selectedImage!) else {
            return nil
        }
        
        let previousIndex = currentIndex - 1
        return photoDetailViewController(forIndex: previousIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? PhotoDetailViewController,
              let currentIndex = photos.firstIndex(of: currentVC.selectedImage!) else {
            return nil
        }
        
        let nextIndex = currentIndex + 1
        return photoDetailViewController(forIndex: nextIndex)
    }
    // UIPageViewControllerDelegate method to handle transition preparation
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        // You can prepare for the transition if needed
    }
    
    // MARK: - UIPageViewControllerDelegate Methods
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let visibleViewController = viewControllers?.first as? PhotoDetailViewController,
           let index = photos.firstIndex(of: visibleViewController.selectedImage!) {
            currentIndex = index
            //updateTitle(for: currentIndex)
            print("Updated currentIndex: \(currentIndex)")
        }
    }
    
    
}
