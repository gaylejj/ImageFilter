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
        
        var context = CIContext(options: nil)
        
        //Cache so not getting filter every time Cell Dequeued
        let inputImage = CIImage(image: image)
        var filter = CIFilter(name: self.name)
        filter.setDefaults()
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        var outputImage = filter.outputImage
        
        var testImage = UIImage(CGImage: context.createCGImage(outputImage, fromRect: outputImage.extent()))
        
//        var finalImage = UIImage(CIImage: outputImage)
        self.thumbnailImage = testImage
        println(testImage.size)
        completionHandler(image: testImage)
    }
}