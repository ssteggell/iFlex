//
//  ComparisonViewController.swift
//  iFlex
//
//  Created by Spencer Steggell on 11/20/24.
//

import Foundation
import UIKit

class ComparisonViewController: UIViewController, UIScrollViewDelegate {
    
    //MARK: Properties
    var comparisonContainerView: UIView!
    
    var leftScrollView: UIScrollView!
    var rightScrollView: UIScrollView!
    
    var leftImageView: UIImageView!
    var rightImageView: UIImageView!
    
    var rightDateLabel: UILabel!
    var leftDateLabel: UILabel!
    
    var leftImage: UIImage?
    var rightImage: UIImage?
    
    var leftDate: Date?
    var rightDate: Date?
    
    //MARK: ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let gradientImage = ColorManager.shared.createGradientImage(size: view.bounds.size) {
            view.backgroundColor = UIColor(patternImage: gradientImage)
        }
        setupUI()
        setupShareButton()
    }
    
    //MARK: Set Up Methods
    
    private func setupUI() {
        // Create the container view to hold all components
        comparisonContainerView = UIView()
        comparisonContainerView.translatesAutoresizingMaskIntoConstraints = false
        comparisonContainerView.backgroundColor = .clear
        view.addSubview(comparisonContainerView)
        
        // Set up container view constraints
        NSLayoutConstraint.activate([
            comparisonContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            comparisonContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            comparisonContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20),  // Adds some padding on each side
            comparisonContainerView.heightAnchor.constraint(equalTo: view.heightAnchor, constant: -50)
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
        leftImageView.contentMode = .scaleAspectFit
        leftImageView.image = leftImage
        leftScrollView.addSubview(leftImageView)
        
        // Set up left date label
        leftDateLabel = UILabel()
        leftDateLabel.translatesAutoresizingMaskIntoConstraints = false
        leftDateLabel.textAlignment = .center
        leftDateLabel.textColor = .white
        leftDateLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
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
        rightImageView.contentMode = .scaleAspectFit
        rightImageView.image = rightImage
        rightScrollView.addSubview(rightImageView)
        
        // Set up right date label
        rightDateLabel = UILabel()
        rightDateLabel.translatesAutoresizingMaskIntoConstraints = false
        rightDateLabel.textAlignment = .center
        rightDateLabel.textColor = .white
        rightDateLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        if let date = rightDate {
            rightDateLabel.text = formattedDateString(from: date)
        }
        view.addSubview(rightDateLabel)
        
        // Calculate aspect ratios and dimensions for left and right images
        let leftImageAspectRatio = leftImage != nil ? leftImage!.size.width / leftImage!.size.height : 1.0
        let rightImageAspectRatio = rightImage != nil ? rightImage!.size.width / rightImage!.size.height : 1.0
        
        NSLayoutConstraint.activate([
            
            leftScrollView.leadingAnchor.constraint(equalTo: comparisonContainerView.leadingAnchor),
            leftScrollView.centerYAnchor.constraint(equalTo: comparisonContainerView.centerYAnchor),
            leftScrollView.trailingAnchor.constraint(equalTo: comparisonContainerView.centerXAnchor, constant: -5),
            leftScrollView.heightAnchor.constraint(equalTo: leftImageView.widthAnchor, multiplier: 1/leftImageAspectRatio),
            
            leftImageView.centerXAnchor.constraint(equalTo: leftScrollView.centerXAnchor),
            leftImageView.centerYAnchor.constraint(equalTo: leftScrollView.centerYAnchor),
            leftImageView.widthAnchor.constraint(equalTo: leftScrollView.widthAnchor),
            leftImageView.heightAnchor.constraint(equalTo: leftImageView.widthAnchor, multiplier: 1/leftImageAspectRatio),
            
            
            leftDateLabel.topAnchor.constraint(equalTo: leftScrollView.bottomAnchor, constant: 5),
            leftDateLabel.leadingAnchor.constraint(equalTo: leftScrollView.leadingAnchor),
            leftDateLabel.trailingAnchor.constraint(equalTo: leftScrollView.trailingAnchor),
            
            // Right Scroll View
            rightScrollView.leadingAnchor.constraint(equalTo: comparisonContainerView.centerXAnchor, constant: 5),
            
            rightScrollView.centerYAnchor.constraint(equalTo: comparisonContainerView.centerYAnchor),
            rightScrollView.trailingAnchor.constraint(equalTo: comparisonContainerView.trailingAnchor),
            rightScrollView.heightAnchor.constraint(equalTo: rightImageView.widthAnchor, multiplier: 1/rightImageAspectRatio),
            
            // Right Image View inside Scroll View
            rightImageView.centerXAnchor.constraint(equalTo: rightScrollView.centerXAnchor),
            rightImageView.centerYAnchor.constraint(equalTo: rightScrollView.centerYAnchor),
            rightImageView.widthAnchor.constraint(equalTo: rightScrollView.widthAnchor),
            rightImageView.heightAnchor.constraint(equalTo: rightImageView.widthAnchor, multiplier: 1/rightImageAspectRatio),
            
            // Right Date Label (directly below right scroll view)
            rightDateLabel.topAnchor.constraint(equalTo: rightScrollView.bottomAnchor, constant: 5),
            rightDateLabel.leadingAnchor.constraint(equalTo: rightScrollView.leadingAnchor),
            rightDateLabel.trailingAnchor.constraint(equalTo: rightScrollView.trailingAnchor)
        ])
    }
    
    //MARK: User Actions
    private func setupShareButton() {
        // Add a share button to the navigation bar
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareCombinedImage))
        navigationItem.rightBarButtonItem = shareButton
    }
    
    @objc func shareCombinedImage() {
        guard let leftImage = leftImage,
              let rightImage = rightImage,
              let leftDate = leftDate,
              let rightDate = rightDate else {
            print("Images or dates are nil.")
            return
        }
        
        if let combinedImage = combineImagesAndLabelsToImage(image1: leftImage, date1: leftDate, image2: rightImage, date2: rightDate) {
            let activityViewController = UIActivityViewController(activityItems: [combinedImage], applicationActivities: nil)
            
            // Setting up a popover presentation for iPad compatibility
            if let popoverController = activityViewController.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            
            present(activityViewController, animated: true, completion: nil)
        } else {
            print("Failed to create the combined image.")
        }
    }
    
    //MARK: Helper Functions
    
    func combineImagesAndLabelsToImage(image1: UIImage, date1: Date, image2: UIImage, date2: Date) -> UIImage? {
        
        let croppedImage1 = cropVisibleArea(from: leftScrollView, imageView: leftImageView)
        let croppedImage2 = cropVisibleArea(from: rightScrollView, imageView: rightImageView)
        
        // Create a container view to hold images and labels
        let containerView = UIView()
        if let gradientImage = ColorManager.shared.createGradientImage(size: UIScreen.main.bounds.size) {
            containerView.backgroundColor = UIColor(patternImage: gradientImage)
        }
        
        // First Image View
        let imageView1 = UIImageView(image: croppedImage1)
        imageView1.contentMode = .scaleAspectFit
        containerView.addSubview(imageView1)
        
        // First Label
        let label1 = UILabel()
        label1.text = DateFormatter.localizedString(from: date1, dateStyle: .medium, timeStyle: .none)
        label1.textAlignment = .center
        label1.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label1.textColor = .white
        containerView.addSubview(label1)
        
        // Second Image View
        let imageView2 = UIImageView(image: croppedImage2)
        imageView2.contentMode = .scaleAspectFit
        containerView.addSubview(imageView2)
        
        // Second Label
        let label2 = UILabel()
        label2.text = DateFormatter.localizedString(from: date2, dateStyle: .medium, timeStyle: .none)
        label2.textAlignment = .center
        label2.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label2.textColor = .white
        containerView.addSubview(label2)
        
        // iFlex Label (Label 3)
        let label3 = UILabel()
        label3.text = "Made with iFlex"
        label3.font = UIFont(name: "Black Ops One", size: 16)
        label3.textAlignment = .center
        label3.textColor = .white
        containerView.addSubview(label3)
        
        // Calculate the frame sizes and positions
        let containerWidth: CGFloat = UIScreen.main.bounds.width
        let imageWidth: CGFloat = containerWidth / 2
        let imageHeight: CGFloat = containerWidth * 0.75  // Adjust the height ratio as needed
        let labelHeight: CGFloat = 30
        let iFlexLabelHeight: CGFloat = 40
        let containerHeight: CGFloat = imageHeight + labelHeight + iFlexLabelHeight
        
        // Set the frames for images and labels side by side
        imageView1.frame = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
        label1.frame = CGRect(x: 0, y: imageView1.frame.maxY, width: imageWidth, height: labelHeight)
        
        imageView2.frame = CGRect(x: imageWidth, y: 0, width: imageWidth, height: imageHeight)
        label2.frame = CGRect(x: imageWidth, y: imageView2.frame.maxY, width: imageWidth, height: labelHeight)
        
        // Position the iFlex label below the two images
        label3.frame = CGRect(x: 0, y: max(label1.frame.maxY, label2.frame.maxY), width: containerWidth, height: iFlexLabelHeight)
        
        // Set the container view frame
        containerView.frame = CGRect(x: 0, y: 0, width: containerWidth, height: containerHeight)
        
        // Render the container view to an image
        UIGraphicsBeginImageContextWithOptions(containerView.bounds.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        containerView.layer.render(in: context)  // Use `layer.render` instead of `drawHierarchy`
        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return combinedImage
    }
    
    func cropVisibleArea(from scrollView: UIScrollView, imageView: UIImageView) -> UIImage? {
        guard let image = imageView.image else { return nil }
        
        // Calculate the visible rect in the coordinates of the UIImage
        let zoomScale = scrollView.zoomScale
        let offset = scrollView.contentOffset
        
        // Calculate the visible rect in terms of imageView's coordinate system
        let visibleRect = CGRect(
            x: offset.x / zoomScale,
            y: offset.y / zoomScale,
            width: scrollView.bounds.width / zoomScale,
            height: scrollView.bounds.height / zoomScale
        )
        
        // Calculate the scale between the UIImageView and the actual image
        let imageSize = image.size
        let imageViewSize = imageView.bounds.size
        
        let xScale = imageSize.width / imageViewSize.width
        let yScale = imageSize.height / imageViewSize.height
        
        // Apply the scaling to match the image coordinate system
        let scaledVisibleRect = CGRect(
            x: visibleRect.origin.x * xScale,
            y: visibleRect.origin.y * yScale,
            width: visibleRect.size.width * xScale,
            height: visibleRect.size.height * yScale
        )
        
        // Crop the image to the scaled visible rect
        guard let croppedCGImage = image.cgImage?.cropping(to: scaledVisibleRect) else { return nil }
        return UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
    }
  
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
    
//End of ComparisonViewController
}
