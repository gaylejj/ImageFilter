//
//  Filter.swift
//  ImageFilterApp
//
//  Created by Jeff Gayle on 8/7/14.
//  Copyright (c) 2014 Jeff Gayle. All rights reserved.
//

import Foundation
import UIKit

class Filter {
    
    var name : String
    var thumbnailImage : UIImage?
    
    init(name: String) {
        self.name = name
    }
    
    func createFilterThumbnailFromImage(image: UIImage, completionHandler: (image: UIImage) -> Void) {
        let inputImage = CIImage(image: image)
        var filter = CIFilter(name: self.name)
        filter.setDefaults()
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        var outputImage = filter.outputImage
        
        var finalImage = UIImage(CIImage: outputImage)
        completionHandler(image: finalImage)
    }
}