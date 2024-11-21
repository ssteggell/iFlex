//
//  CollectionAlbumCell.swift
//  iFlex
//
//  Created by Spencer Steggell on 11/7/24.
//

import Foundation
import UIKit


class CollectionAlbumCell: UICollectionViewCell {
    
    @IBOutlet weak var albumPhoto: UIImageView!
    
    @IBOutlet weak var albumName: UILabel!
    
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
        self.albumPhoto.layer.cornerRadius = 15
        self.albumPhoto.layer.masksToBounds = true
        self.albumName.textColor = ColorManager.textColor
        self.albumName.font = UIFont(name: "Black Ops One", size: 20)
    }
    
    
}
