//
//  ViewController.swift
//  ImageFilterApp
//
//  Created by Jeff Gayle on 8/4/14.
//  Copyright (c) 2014 Jeff Gayle. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    let actionController = UIAlertController(title: "Source Type", message: "Please Choose a Source Type", preferredStyle: UIAlertControllerStyle.ActionSheet)
    
    let alertView = UIAlertController(title: "Alert!", message: "We are about to ask for your permission to access your Camera or Photo Library", preferredStyle: UIAlertControllerStyle.Alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.imagePicker.delegate = self
        self.imagePicker.allowsEditing = true
        
        self.setupAlertController()
        self.setupAlertView()
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func handleButtonPressed(sender: AnyObject) {
        
        if NSUserDefaults.standardUserDefaults().boolForKey("First Permission") {
            self.presentViewController(actionController, animated: true, completion: nil)

        } else {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "First Permission")
            self.presentViewController(alertView, animated: true, completion: nil)
        }
        
    }
    
    func setupAlertController() {
        let cameraOption = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
            
            })
        
        let photoOption = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
            
            })
        
        let cancelOption = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction!) -> Void in
            
               //cancel action here
            
            })
        
        self.actionController.addAction(cameraOption)
        self.actionController.addAction(photoOption)
        self.actionController.addAction(cancelOption)
    }
    
    func setupAlertView() {
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            
            self.presentViewController(self.actionController, animated: true, completion: nil)
            
            })
        
        self.alertView.addAction(okAction)
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!) {
        
        var editedImage = info[UIImagePickerControllerEditedImage] as UIImage
        self.imageView.image = editedImage
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    

}

