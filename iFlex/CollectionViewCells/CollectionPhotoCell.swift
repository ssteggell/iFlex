//
//  CollectionPhotoCell.swift
//  iFlex
//
//  Created by Spencer Steggell on 11/13/24.
//

import Foundation
import UIKit

class CollectionPhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var img: UIImageView!
    var photoDate = Date()
    var allowsMultipleSelection: Bool = false
    
    override var isSelected: Bool {
        didSet {
            if allowsMultipleSelection {
            layer.borderColor = isSelected ? ColorManager.highlightColor.cgColor : UIColor.clear.cgColor
            layer.borderWidth = isSelected ? 5 : 0
            layer.cornerRadius = isSelected ? 8 : 0
            } else {
                layer.borderColor = UIColor.clear.cgColor
                layer.borderWidth = 0
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.img.layer.cornerRadius = 5
        self.img.layer.masksToBounds = true
    }
    
    
}
