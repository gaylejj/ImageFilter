//
//  GridViewController.swift
//  ImageFilterApp
//
//  Created by Jeff Gayle on 8/5/14.
//  Copyright (c) 2014 Jeff Gayle. All rights reserved.
//

import UIKit
import Photos

class GridViewController: UIViewController, UICollectionViewDataSource, SelectedPhotoDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var delegate : SelectedPhotoDelegate?
    
    var assetsFetchedResult: PHFetchResult!
    var imageManager : PHCachingImageManager!
    var assetGridThumbnailSize : CGSize!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        
        self.imageManager = PHCachingImageManager()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //Cell Size
        var scale = UIScreen.mainScreen().scale
        var flowLayout = self.collectionView.collectionViewLayout as UICollectionViewFlowLayout
        var cellSize = flowLayout.itemSize
        self.assetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UICollection View Data Source
    
    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        return self.assetsFetchedResult.count
    }
    
    func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as PhotoCell
        
        var currentTag = cell.tag + 1
        println("Cell has been used \(currentTag) times")
        cell.tag = currentTag
        
        var asset = self.assetsFetchedResult[indexPath.item] as PHAsset
        
        //Request an image for each cell
        self.imageManager.requestImageForAsset(asset, targetSize: self.assetGridThumbnailSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (result: UIImage!, [NSObject : AnyObject]!) -> Void in
            
            if cell.tag == currentTag {
                cell.imageView.image = result
            }
            
        }
        
        return cell
    }
    
    //MARK: Segue to Photo VC
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "ShowPhoto" {
            var cell = sender as PhotoCell
            var indexPath = self.collectionView.indexPathForCell(cell)
            
            let photoVC = segue.destinationViewController as PhotoViewController
            photoVC.asset = self.assetsFetchedResult[indexPath.item] as PHAsset
            photoVC.delegate = self
        }
    }
    
    //MARK: Selected Photo Delegate
    func selectedPhoto(asset : PHAsset) -> Void {
        println("Doing Something for the delegate")
        self.delegate!.selectedPhoto(asset)
    }

}
