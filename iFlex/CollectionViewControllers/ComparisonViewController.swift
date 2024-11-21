//
//  ComparisonViewController.swift
//  iFlex
//
//  Created by Spencer Steggell on 11/20/24.
//

import Foundation
import UIKit

class ComparisonViewController: UIViewController, UIScrollViewDelegate {
    
    // UI elements to display the two images
    // UI elements to display the two images in scroll views for zooming
    var comparisonContainerView: UIView!
      var leftScrollView: UIScrollView!
      var rightScrollView: UIScrollView!
    var leftImageView: UIImageView!
    var rightImageView: UIImageView!
    var rightDateLabel: UILabel!
    var leftDateLabel: UILabel!
    
    
    
    // Properties to store the images to be compared
    var leftImage: UIImage?
    var rightImage: UIImage?
    var leftDate: Date?
    var rightDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let gradientImage = ColorManager.shared.createGradientImage(size: view.bounds.size) {
            view.backgroundColor = UIColor(patternImage: gradientImage)
        }
        setupUI()
        setupShareButton()
    }
    
    private func setupUI() {
        // Create the container view to hold all components
               comparisonContainerView = UIView()
               comparisonContainerView.translatesAutoresizingMaskIntoConstraints = false
               comparisonContainerView.backgroundColor = .clear
               view.addSubview(comparisonContainerView)
               
               // Set up container view constraints
               NSLayoutConstraint.activate([
                   comparisonContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
                   comparisonContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
                   comparisonContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                   comparisonContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
               ])
           // Set up left scroll view
           leftScrollView = UIScrollView()
           leftScrollView.translatesAutoresizingMaskIntoConstraints = false
           leftScrollView.delegate = self
           leftScrollView.minimumZoomScale = 1.0
           leftScrollView.maximumZoomScale = 4.0
           view.addSubview(leftScrollView)
           
           // Set up left image view
           leftImageView = UIImageView()
           leftImageView.translatesAutoresizingMaskIntoConstraints = false
           leftImageView.contentMode = .scaleAspectFill
           leftImageView.image = leftImage
           leftScrollView.addSubview(leftImageView)

           // Set up left date label
           leftDateLabel = UILabel()
           leftDateLabel.translatesAutoresizingMaskIntoConstraints = false
           leftDateLabel.textAlignment = .center
           leftDateLabel.textColor = .white
           leftDateLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
           if let date = leftDate {
               leftDateLabel.text = formattedDateString(from: date)
           }
           view.addSubview(leftDateLabel)

           // Set up right scroll view
           rightScrollView = UIScrollView()
           rightScrollView.translatesAutoresizingMaskIntoConstraints = false
           rightScrollView.delegate = self
           rightScrollView.minimumZoomScale = 1.0
           rightScrollView.maximumZoomScale = 4.0
           view.addSubview(rightScrollView)
           
           // Set up right image view
           rightImageView = UIImageView()
           rightImageView.translatesAutoresizingMaskIntoConstraints = false
           rightImageView.contentMode = .scaleAspectFill
           rightImageView.image = rightImage
           rightScrollView.addSubview(rightImageView)

           // Set up right date label
           rightDateLabel = UILabel()
           rightDateLabel.translatesAutoresizingMaskIntoConstraints = false
           rightDateLabel.textAlignment = .center
           rightDateLabel.textColor = .white
           rightDateLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
           if let date = rightDate {
               rightDateLabel.text = formattedDateString(from: date)
           }
           view.addSubview(rightDateLabel)

           // Constraints for left and right image views and labels
           NSLayoutConstraint.activate([
               // Left Scroll View
               leftScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
               leftScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
               leftScrollView.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -5),
               leftScrollView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7),

               // Left Image View inside Scroll View
               leftImageView.leadingAnchor.constraint(equalTo: leftScrollView.leadingAnchor),
               leftImageView.trailingAnchor.constraint(equalTo: leftScrollView.trailingAnchor),
               leftImageView.topAnchor.constraint(equalTo: leftScrollView.topAnchor),
               leftImageView.bottomAnchor.constraint(equalTo: leftScrollView.bottomAnchor),
               leftImageView.widthAnchor.constraint(equalTo: leftScrollView.widthAnchor),
               leftImageView.heightAnchor.constraint(equalTo: leftScrollView.heightAnchor),

               // Left Date Label (directly below left scroll view)
               leftDateLabel.topAnchor.constraint(equalTo: leftScrollView.bottomAnchor, constant: 5),
               leftDateLabel.leadingAnchor.constraint(equalTo: leftScrollView.leadingAnchor),
               leftDateLabel.trailingAnchor.constraint(equalTo: leftScrollView.trailingAnchor),

               // Right Scroll View
               rightScrollView.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 5),
               rightScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
               rightScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
               rightScrollView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7),

               // Right Image View inside Scroll View
               rightImageView.leadingAnchor.constraint(equalTo: rightScrollView.leadingAnchor),
               rightImageView.trailingAnchor.constraint(equalTo: rightScrollView.trailingAnchor),
               rightImageView.topAnchor.constraint(equalTo: rightScrollView.topAnchor),
               rightImageView.bottomAnchor.constraint(equalTo: rightScrollView.bottomAnchor),
               rightImageView.widthAnchor.constraint(equalTo: rightScrollView.widthAnchor),
               rightImageView.heightAnchor.constraint(equalTo: rightScrollView.heightAnchor),

               // Right Date Label (directly below right scroll view)
               rightDateLabel.topAnchor.constraint(equalTo: rightScrollView.bottomAnchor, constant: 5),
               rightDateLabel.leadingAnchor.constraint(equalTo: rightScrollView.leadingAnchor),
               rightDateLabel.trailingAnchor.constraint(equalTo: rightScrollView.trailingAnchor)
           ])
       }
    
    private func setupShareButton() {
            // Add a share button to the navigation bar
            let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareComparison))
            navigationItem.rightBarButtonItem = shareButton
        }
    @objc func shareComparison() {
        // Make sure the view layout is complete before capturing
        comparisonContainerView.layoutIfNeeded()

        // Render the comparison container view to an image
        UIGraphicsBeginImageContextWithOptions(comparisonContainerView.bounds.size, false, UIScreen.main.scale)
        
        // Make sure the container view is properly drawn into the context
        let success = comparisonContainerView.drawHierarchy(in: comparisonContainerView.bounds, afterScreenUpdates: true)

        guard success, let comparisonImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            print("Failed to render comparison view.")
            return
        }
        UIGraphicsEndImageContext()

        // Share the rendered image
        let activityVC = UIActivityViewController(activityItems: [comparisonImage], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        present(activityVC, animated: true, completion: nil)
    }
    
//    private func setupUI() {
//        // Set up left image view
//        leftImageView = UIImageView()
//        leftImageView.translatesAutoresizingMaskIntoConstraints = false
//        leftImageView.contentMode = .scaleAspectFit
//        leftImageView.image = leftImage
//        view.addSubview(leftImageView)
//        
//        // Set up right image view
//        rightImageView = UIImageView()
//        rightImageView.translatesAutoresizingMaskIntoConstraints = false
//        rightImageView.contentMode = .scaleAspectFit
//        rightImageView.image = rightImage
//        view.addSubview(rightImageView)
//        
//        // Set up left date label
//                leftDateLabel = UILabel()
//                leftDateLabel.translatesAutoresizingMaskIntoConstraints = false
//                leftDateLabel.textAlignment = .center
//                leftDateLabel.textColor = .white
//                leftDateLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
//                if let date = leftDate {
//                    leftDateLabel.text = formattedDateString(from: date)
//                }
//                view.addSubview(leftDateLabel)
//        
//        // Set up right date label
//                rightDateLabel = UILabel()
//                rightDateLabel.translatesAutoresizingMaskIntoConstraints = false
//                rightDateLabel.textAlignment = .center
//                rightDateLabel.textColor = .white
//                rightDateLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
//                if let date = rightDate {
//                    rightDateLabel.text = formattedDateString(from: date)
//                }
//                view.addSubview(rightDateLabel)
//        
//               
//        
//        // Constraints for left and right image views
//        NSLayoutConstraint.activate([
//            // Left Image View
//                     leftImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
//                     leftImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//                     leftImageView.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -5),
//                     leftImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7),
//
//                     // Left Date Label (directly below left image view)
//                     leftDateLabel.topAnchor.constraint(equalTo: leftImageView.bottomAnchor, constant: 0),
//                     leftDateLabel.leadingAnchor.constraint(equalTo: leftImageView.leadingAnchor),
//                     leftDateLabel.trailingAnchor.constraint(equalTo: leftImageView.trailingAnchor),
//
//                     // Right Image View
//                     rightImageView.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 5),
//                     rightImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//                     rightImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
//                     rightImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7),
//
//                     // Right Date Label (directly below right image view)
//                     rightDateLabel.topAnchor.constraint(equalTo: rightImageView.bottomAnchor, constant: 5),
//                     rightDateLabel.leadingAnchor.constraint(equalTo: rightImageView.leadingAnchor),
//                     rightDateLabel.trailingAnchor.constraint(equalTo: rightImageView.trailingAnchor),
//             
//        ])
//    }
    
    // Helper method to format the date as a string
       private func formattedDateString(from date: Date) -> String {
           let dateFormatter = DateFormatter()
           dateFormatter.dateStyle = .medium
           dateFormatter.timeStyle = .none
           return dateFormatter.string(from: date)
       }
    
    // UIScrollViewDelegate method to return the view to zoom
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            if scrollView == leftScrollView {
                return leftImageView
            } else if scrollView == rightScrollView {
                return rightImageView
            }
            return nil
        }
}
