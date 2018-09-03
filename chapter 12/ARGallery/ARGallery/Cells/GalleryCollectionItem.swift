//
//  GalleryCollectionItem.swift
//  AugmentedRealityGallery
//
//  Created by Donny Wals on 29/07/2017.
//  Copyright © 2017 DonnyWals. All rights reserved.
//

import UIKit

class GalleryCollectionItem: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}
