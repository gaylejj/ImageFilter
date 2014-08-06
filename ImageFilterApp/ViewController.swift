//
//  ViewController.swift
//  ImageFilterApp
//
//  Created by Jeff Gayle on 8/4/14.
//  Copyright (c) 2014 Jeff Gayle. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, PHPhotoLibraryChangeObserver, SelectedPhotoDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var imageViewSize : CGSize!

    var selectedAsset : PHAsset?
    
    var context = CIContext(options: nil)
    
    let adjustmentFormatterIdentifier = "com.filterappdemo.cf"
    
    let imagePicker = UIImagePickerController()
    
    //Create Action Controller
    let actionController = UIAlertController(title: "Source Type", message: "Please Choose a Source Type", preferredStyle: UIAlertControllerStyle.ActionSheet)
    
    //Create Alert View
    let alertView = UIAlertController(title: "Alert!", message: "We are about to ask for your permission to access your Camera or Photo Library", preferredStyle: UIAlertControllerStyle.Alert)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.imagePicker.delegate = self
        self.imagePicker.allowsEditing = true
        
        self.setupAlertController()
        self.setupAlertView()
        
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
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
            self.checkAuthentication({ (status) -> Void in
                if status == PHAuthorizationStatus.Authorized {
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        self.performSegueWithIdentifier("ShowGrid", sender: self)
                    })
                }
                
            })
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
    
    func checkAuthentication(completionHandler: (PHAuthorizationStatus) -> Void) -> Void {
        
        switch PHPhotoLibrary.authorizationStatus() {
        case .NotDetermined:
            println("Not Determined")
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
                completionHandler(status)
            })
        default:
            println("Restricted")
            println("Denied")
            completionHandler(PHPhotoLibrary.authorizationStatus())
        }
        
    }
    
    //MARK: Selected Photo Delegate
    func selectedPhoto(asset: PHAsset) -> Void {
        println("Final step")
        
        self.selectedAsset = asset
        self.updateImage()
        
//        var targetSize = CGSize(width: CGRectGetWidth(self.imageView.frame), height: CGRectGetHeight(self.imageView.frame))
//        
//        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: targetSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (result: UIImage!, [NSObject : AnyObject]!) -> Void in
//            
//            self.imageView.image = result
//            
//        }
    }
    
    //MARK: Filter Methods
    @IBAction func handleSepiaPressed(sender: AnyObject) {
        
        var options = PHContentEditingInputRequestOptions()
        options.canHandleAdjustmentData = {(data : PHAdjustmentData!) -> Bool in
            
            return data.formatIdentifier == self.adjustmentFormatterIdentifier && data.formatVersion == "1.0"
            
            }
        
        self.selectedAsset!.requestContentEditingInputWithOptions(options, completionHandler: { (contentEditingInput : PHContentEditingInput!, info : [NSObject : AnyObject]!) -> Void in
            
            //Grabbing Image and converting to CIImage
            var url = contentEditingInput.fullSizeImageURL
            var orientation = contentEditingInput.fullSizeImageOrientation
            var inputImage = CIImage(contentsOfURL: url)
            inputImage = inputImage.imageByApplyingOrientation(orientation)
            
            //Creating Filter
            var filterName = "CISepiaTone"
            var filter = CIFilter(name: filterName)
            filter.setDefaults()
            filter.setValue(inputImage, forKey: kCIInputImageKey)
            var outputImage = filter.outputImage
            
            var cgImage = self.context.createCGImage(outputImage, fromRect: outputImage.extent())
            var finalImage = UIImage(CGImage: cgImage)
            var jpegData = UIImageJPEGRepresentation(finalImage, 1.0)
            
            //Create our adjustmentData
            var adjustmentData = PHAdjustmentData(formatIdentifier: self.adjustmentFormatterIdentifier, formatVersion: "1.0", data: jpegData)
            var contentEditingOutput = PHContentEditingOutput(contentEditingInput: contentEditingInput)
            jpegData.writeToURL(contentEditingOutput.renderedContentURL, atomically: true)
            contentEditingOutput.adjustmentData = adjustmentData
            
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            
                var request = PHAssetChangeRequest(forAsset: self.selectedAsset)
                request.contentEditingOutput = contentEditingOutput
                
                }, completionHandler: { (success : Bool, error : NSError!) -> Void in
                
                    if !success {
                        println(error.localizedDescription)
                    }
                    
            })
            
            
        })
    }
    
    func updateImage() {
        
        var targetSize = self.imageView.frame.size
        PHImageManager.defaultManager().requestImageForAsset(self.selectedAsset, targetSize: targetSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (result : UIImage!, info : [NSObject : AnyObject]!) -> Void in
            
            self.imageView.image = result
        }
        
    }
    
    func photoLibraryDidChange(changeInstance: PHChange!) {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            
            if self.selectedAsset != nil {
                var changeDetails = changeInstance.changeDetailsForObject(self.selectedAsset)
                
                if changeDetails != nil {
                    self.selectedAsset = changeDetails.objectAfterChanges as? PHAsset
                    
                    if changeDetails.assetContentChanged {
                        self.updateImage()
                    }
                }
            }
            
        }
    }
    
    //Noir Button
    @IBAction func handleNoirPressed(sender: AnyObject) {
        
        var options = PHContentEditingInputRequestOptions()
        options.canHandleAdjustmentData = {(data : PHAdjustmentData!) -> Bool in
            
            return data.formatIdentifier == self.adjustmentFormatterIdentifier && data.formatVersion == "1.0"
            
        }
        
        self.selectedAsset!.requestContentEditingInputWithOptions(options, completionHandler: { (contentEditingInput : PHContentEditingInput!, info : [NSObject : AnyObject]!) -> Void in
            
            //Grabbing Image and converting to CIImage
            var url = contentEditingInput.fullSizeImageURL
            var orientation = contentEditingInput.fullSizeImageOrientation
            var inputImage = CIImage(contentsOfURL: url)
            inputImage = inputImage.imageByApplyingOrientation(orientation)
            
            //Creating Filter
            var filterName = "CIPhotoEffectNoir"
            var filter = CIFilter(name: filterName)
            filter.setDefaults()
            filter.setValue(inputImage, forKey: kCIInputImageKey)
            var outputImage = filter.outputImage
            
            var cgImage = self.context.createCGImage(outputImage, fromRect: outputImage.extent())
            var finalImage = UIImage(CGImage: cgImage)
            var jpegData = UIImageJPEGRepresentation(finalImage, 1.0)
            
            //Create our adjustmentData
            var adjustmentData = PHAdjustmentData(formatIdentifier: self.adjustmentFormatterIdentifier, formatVersion: "1.0", data: jpegData)
            var contentEditingOutput = PHContentEditingOutput(contentEditingInput: contentEditingInput)
            jpegData.writeToURL(contentEditingOutput.renderedContentURL, atomically: true)
            contentEditingOutput.adjustmentData = adjustmentData
            
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                
                var request = PHAssetChangeRequest(forAsset: self.selectedAsset)
                request.contentEditingOutput = contentEditingOutput
                
                }, completionHandler: { (success : Bool, error : NSError!) -> Void in
                    
                    if !success {
                        println(error.localizedDescription)
                    }
                    
            })
            
            
        })
        
    }
    

}

