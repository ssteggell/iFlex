//
//  ColorManager.swift
//  iFlex
//
//  Created by Spencer Steggell on 11/19/24.
//

import Foundation
import UIKit


struct ColorManager {
    static let shared = ColorManager()
    
    static let backgroundColor = UIColor(named: "BackgroundColor") ?? UIColor.systemGray6
    static let primaryColor = UIColor(named: "PrimaryColor") ?? UIColor.blue
    static let secondaryColor = UIColor(named: "SecondaryColor") ?? UIColor.red
    static let accentColor = UIColor(named: "AccentColor") ?? UIColor.orange
    static let textColor = UIColor(named: "TextColor") ?? UIColor.white
    static let secondaryTextColor = UIColor(named: "SecondaryText") ?? UIColor.lightGray
    static let highlightColor = UIColor(named: "Highlight") ?? UIColor.blue
    static let warningColor = UIColor(named: "Warning") ?? UIColor.red
    
    private init() {}
    
    func createGradientImage(size: CGSize) -> UIImage? {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            ColorManager.secondaryTextColor.cgColor,
            ColorManager.primaryColor.cgColor,
            ColorManager.secondaryTextColor.cgColor
            
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = CGRect(origin: .zero, size: size)

        // Create the gloss effect layer
        let glossLayer = CAGradientLayer()
        glossLayer.colors = [
            
            ColorManager.backgroundColor.withAlphaComponent(0.4).cgColor,
            UIColor.clear.cgColor,
            UIColor.clear.cgColor,
            ColorManager.backgroundColor.withAlphaComponent(0.4).cgColor
        ]
        glossLayer.startPoint = CGPoint(x: 1.0, y: 0.0)
        glossLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
        glossLayer.frame = CGRect(origin: .zero, size: size)

        // Render both the gradient and gloss layers into a UIImage
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        // Render the gradient layer
        gradientLayer.render(in: context)

        // Render the gloss layer on top of it
        glossLayer.render(in: context)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
    
}


