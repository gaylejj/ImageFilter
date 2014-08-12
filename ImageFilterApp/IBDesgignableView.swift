//
//  IBDesgignableView.swift
//  ImageFilterApp
//
//  Created by Jeff Gayle on 8/11/14.
//  Copyright (c) 2014 Jeff Gayle. All rights reserved.
//

import UIKit

@IBDesignable class IBDesgignableView: UIImageView {

    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = borderWidth
            self.layer.masksToBounds = true
            self.layer.needsDisplay()
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.blackColor() {
        didSet {
            self.layer.borderColor = borderColor.CGColor
            self.layer.needsDisplay()
        }
    }

}