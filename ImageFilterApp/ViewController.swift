//
//  ViewController.swift
//  ImageFilterApp
//
//  Created by Jeff Gayle on 8/4/14.
//  Copyright (c) 2014 Jeff Gayle. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, PHPhotoLibraryChangeObserver, UICollectionViewDataSource, UICollectionViewDelegate, SelectedPhotoDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var imageViewSize : CGSize!

    var selectedAsset : PHAsset?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var context = CIContext(options: nil)
    
    let adjustmentFormatterIdentifier = "com.filterappdemo.cf"
    
    let imagePicker = UIImagePickerController()
    
    let filterNames = ["CISepia Tone", "CIPhotoEffectNoir", "CIColorInvert", "CIComicEffect"]
    
    var filters = [Filter]()
    
    var filter : CIFilter?
    
    var filterThumbnail : UIImage?
    
    @IBOutlet weak var filterImageView: UIImageView!
    
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
        
        
        self.resetFilters()
        
        let cameraButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Camera, target: self, action: "handleButtonPressed:")
        
        self.navigationItem.rightBarButtonItem = cameraButton
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        self.imageViewSize = self.imageView.frame.size
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func resetFilters () {
        let sepia = Filter(name: "CISepiaTone")
        let noir = Filter(name: "CIPhotoEffectNoir")
        let invert = Filter(name: "CIColorInvert")
        let posterize = Filter(name: "CIColorPosterize")
        self.filters = [sepia, noir, invert, posterize]
    }

    //MARK: Button Action
    func handleButtonPressed(sender: AnyObject) {
        
        if self.actionController.popoverPresentationController {
            self.actionController.popoverPresentationController.barButtonItem = sender as UIBarButtonItem
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
        self.fetchThumbnailImage()
        self.resetFilters()
        self.updateImage()
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
    

    
    //MARK: UICollectionView Data Source
    func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("filterCell", forIndexPath: indexPath) as FilterCollectionViewCell
        
        let filter = self.filters[indexPath.item] as Filter
        
        if self.filterThumbnail != nil {
            cell.filterImageView.image = filterThumbnail
            if filter.thumbnailImage != nil {
                cell.filterImageView.image = filter.thumbnailImage
            } else {
                filter.createFilterThumbnailFromImage(self.filterThumbnail!, completionHandler: { (image) -> Void in
                    cell.filterImageView.image = image
                })
            }
        }
        cell.filterLabel.text = filter.name
        
        return cell
    }

    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        return self.filters.count
    }
    
    func fetchThumbnailImage() {
        if self.selectedAsset != nil {
            PHImageManager.defaultManager().requestImageForAsset(self.selectedAsset, targetSize: self.imageViewSize, contentMode: PHImageContentMode.AspectFill, options: nil, resultHandler: { (result: UIImage!, info: [NSObject : AnyObject]!) -> Void in
                
                self.filterThumbnail = result
                
            })
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                self.collectionView.reloadData()
            })
        }
    }
    
    //MARK: New Filter method
    
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
        
        let filter = self.filters[indexPath.item] as Filter

        self.switchFilter(filter.name)

    }
    
    func switchFilter(filter: String) {
        
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
//            var filterName = "CISepiaTone"
            var filter = CIFilter(name: filter)
            filter.setDefaults()
            filter.setValue(inputImage, forKey: kCIInputImageKey)
            var outputImage = filter.outputImage
            
            var cgImage = self.context.createCGImage(outputImage, fromRect: outputImage.extent())
            var finalImage = UIImage(CGImage: cgImage)
            var jpegData = UIImageJPEGRepresentation(finalImage, 0.7)
            
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
    
    
    
    
    //MARK: Filter Methods
//    @IBAction func handleSepiaPressed(sender: AnyObject) {
//        
//        var options = PHContentEditingInputRequestOptions()
//        options.canHandleAdjustmentData = {(data : PHAdjustmentData!) -> Bool in
//            
//            return data.formatIdentifier == self.adjustmentFormatterIdentifier && data.formatVersion == "1.0"
//            
//        }
//        
//        self.selectedAsset!.requestContentEditingInputWithOptions(options, completionHandler: { (contentEditingInput : PHContentEditingInput!, info : [NSObject : AnyObject]!) -> Void in
//            
//            //Grabbing Image and converting to CIImage
//            var url = contentEditingInput.fullSizeImageURL
//            var orientation = contentEditingInput.fullSizeImageOrientation
//            var inputImage = CIImage(contentsOfURL: url)
//            inputImage = inputImage.imageByApplyingOrientation(orientation)
//            
//            //Creating Filter
//            var filterName = "CISepiaTone"
//            var filter = CIFilter(name: filterName)
//            filter.setDefaults()
//            filter.setValue(inputImage, forKey: kCIInputImageKey)
//            var outputImage = filter.outputImage
//            
//            var cgImage = self.context.createCGImage(outputImage, fromRect: outputImage.extent())
//            var finalImage = UIImage(CGImage: cgImage)
//            var jpegData = UIImageJPEGRepresentation(finalImage, 0.7)
//            
//            //Create our adjustmentData
//            var adjustmentData = PHAdjustmentData(formatIdentifier: self.adjustmentFormatterIdentifier, formatVersion: "1.0", data: jpegData)
//            var contentEditingOutput = PHContentEditingOutput(contentEditingInput: contentEditingInput)
//            jpegData.writeToURL(contentEditingOutput.renderedContentURL, atomically: true)
//            contentEditingOutput.adjustmentData = adjustmentData
//            
//            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
//                
//                var request = PHAssetChangeRequest(forAsset: self.selectedAsset)
//                request.contentEditingOutput = contentEditingOutput
//                
//                }, completionHandler: { (success : Bool, error : NSError!) -> Void in
//                    
//                    if !success {
//                        println(error.localizedDescription)
//                    }
//                    
//            })
//            
//            
//        })
//    }
//
//    
//    //Noir Button
//    @IBAction func handleNoirPressed(sender: AnyObject) {
//        
//        var options = PHContentEditingInputRequestOptions()
//        options.canHandleAdjustmentData = {(data : PHAdjustmentData!) -> Bool in
//            
//            return data.formatIdentifier == self.adjustmentFormatterIdentifier && data.formatVersion == "1.0"
//            
//        }
//        
//        self.selectedAsset!.requestContentEditingInputWithOptions(options, completionHandler: { (contentEditingInput : PHContentEditingInput!, info : [NSObject : AnyObject]!) -> Void in
//            
//            //Grabbing Image and converting to CIImage
//            var url = contentEditingInput.fullSizeImageURL
//            var orientation = contentEditingInput.fullSizeImageOrientation
//            var inputImage = CIImage(contentsOfURL: url)
//            inputImage = inputImage.imageByApplyingOrientation(orientation)
//            
//            //Creating Filter
//            var filterName = "CIPhotoEffectNoir"
//            var filter = CIFilter(name: filterName)
//            filter.setDefaults()
//            filter.setValue(inputImage, forKey: kCIInputImageKey)
//            var outputImage = filter.outputImage
//            
//            var cgImage = self.context.createCGImage(outputImage, fromRect: outputImage.extent())
//            var finalImage = UIImage(CGImage: cgImage)
//            var jpegData = UIImageJPEGRepresentation(finalImage, 0.7)
//            
//            //Create our adjustmentData
//            var adjustmentData = PHAdjustmentData(formatIdentifier: self.adjustmentFormatterIdentifier, formatVersion: "1.0", data: jpegData)
//            var contentEditingOutput = PHContentEditingOutput(contentEditingInput: contentEditingInput)
//            jpegData.writeToURL(contentEditingOutput.renderedContentURL, atomically: true)
//            contentEditingOutput.adjustmentData = adjustmentData
//            
//            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
//                
//                var request = PHAssetChangeRequest(forAsset: self.selectedAsset)
//                request.contentEditingOutput = contentEditingOutput
//                
//                }, completionHandler: { (success : Bool, error : NSError!) -> Void in
//                    
//                    if !success {
//                        println(error.localizedDescription)
//                    }
//            })
//        })
//    }

}

