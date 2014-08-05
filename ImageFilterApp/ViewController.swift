//
//  ViewController.swift
//  ImageFilterApp
//
//  Created by Jeff Gayle on 8/4/14.
//  Copyright (c) 2014 Jeff Gayle. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, SelectedPhotoDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    //Create Action Controller
    let actionController = UIAlertController(title: "Source Type", message: "Please Choose a Source Type", preferredStyle: UIAlertControllerStyle.ActionSheet)
    
    //Create Alert View
    let alertView = UIAlertController(title: "Alert!", message: "We are about to ask for your permission to access your Camera or Photo Library", preferredStyle: UIAlertControllerStyle.Alert)
    
    var imageViewSize : CGSize!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.imagePicker.delegate = self
        self.imagePicker.allowsEditing = true
        
        self.setupAlertController()
        self.setupAlertView()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        self.imageViewSize = self.imageView.frame.size
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: Button Action
    @IBAction func handleButtonPressed(sender: AnyObject) {
        
        if self.actionController.popoverPresentationController {
            self.actionController.popoverPresentationController.sourceView = sender as UIButton
        }
        //Handle First Time Permissions
        if NSUserDefaults.standardUserDefaults().boolForKey("First Permission") {
            self.presentViewController(actionController, animated: true, completion: nil)

        } else {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "First Permission")
            self.presentViewController(alertView, animated: true, completion: nil)
        }
        
    }
    
    //MARK: Alert View/Action Controller
    //Setup AlertController Options
    func setupAlertController() {
        let cameraOption = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
            
            })
        
        let photoOption = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            
//            self.imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
//            self.presentViewController(self.imagePicker, animated: true, completion: nil)
            
            //Segue to Collection View
            self.performSegueWithIdentifier("ShowGrid", sender: self)             
            })
        
        let cancelOption = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction!) -> Void in
            
               //cancel action here
            
            })
        
        self.actionController.addAction(cameraOption)
        self.actionController.addAction(photoOption)
        self.actionController.addAction(cancelOption)
    }
    
    //Setup AlertView Options
    func setupAlertView() {
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            
            self.presentViewController(self.actionController, animated: true, completion: nil)
            
            })
        
        self.alertView.addAction(okAction)
    }
    
    //MARK: UIImagePicker
    //ImagePickerController
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!) {
        
        var editedImage = info[UIImagePickerControllerEditedImage] as UIImage
        self.imageView.image = editedImage
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //MARK: Segue
    
    //Segue Method
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "ShowGrid" {
            let gridVC = segue.destinationViewController as GridViewController
            gridVC.assetsFetchedResult = PHAsset.fetchAssetsWithOptions(nil)
            gridVC.delegate = self
        }
    }
    
    //MARK: Selected Photo Delegate
    func selectedPhoto(asset: PHAsset) -> Void {
        println("Final step")
        
        var targetSize = CGSize(width: CGRectGetWidth(self.imageView.frame), height: CGRectGetHeight(self.imageView.frame))
        
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: targetSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (result: UIImage!, [NSObject : AnyObject]!) -> Void in
            
            self.imageView.image = result
            
        }
    }
    
    

}

