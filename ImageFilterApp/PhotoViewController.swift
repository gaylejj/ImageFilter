//
//  PhotoViewController.swift
//  ImageFilterApp
//
//  Created by Jeff Gayle on 8/5/14.
//  Copyright (c) 2014 Jeff Gayle. All rights reserved.
//

import UIKit
import Photos

protocol SelectedPhotoDelegate {
    
    func selectedPhoto(asset: PHAsset) -> Void
}

class PhotoViewController: UIViewController {
    
    var asset : PHAsset!
    var delegate : SelectedPhotoDelegate?

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //Target Size for Image Requested
        var targetSize = CGSize(width: CGRectGetWidth(self.imageView.frame), height: CGRectGetHeight(self.imageView.frame))
        
        //Request an image
        PHImageManager.defaultManager().requestImageForAsset(self.asset, targetSize: targetSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (result: UIImage!, [NSObject : AnyObject]!) -> Void in
            self.imageView.image = result
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Button Action
    @IBAction func handleButtonPressed(sender: AnyObject) {
        
        //Send delegate message to other VCs that match delegate -> All those times setting delegate to self. So VC.delegate = gridVC.delegate = PhotoVC.delegate 
        //PhotoVC.delegate sends an asset to the method, it passes down the chain to the original ViewController (in this case the root view controller)
        self.delegate!.selectedPhoto(self.asset)
        self.navigationController.popToRootViewControllerAnimated(true)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
