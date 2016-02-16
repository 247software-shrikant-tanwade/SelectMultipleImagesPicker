//
//  CustomImagePickerVC.swift
//  MyApartment
//
//  Created by Shrikant Tanwade on 05/02/16.
//  Copyright © 2016 Shrikant. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

protocol CustomImagePickerVCDelegate
{
    func selectedImagesArray(imageArray:NSMutableArray)
}

class CustomImagePickerVC: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate
{
    var delegate:CustomImagePickerVCDelegate! = nil
    
    var arrImages : NSMutableArray!
    var assetResults : PHFetchResult!
    var arrImageStateWithImage : NSMutableArray!
    
    var countAlreadySelectedImages : Int! = 0
    var countSelectedImages : Int! = 0
    var numberOfImagesWantSelect : Int! = 0
    
    @IBOutlet weak var collectionView : UICollectionView!
    @IBOutlet weak var lblImagesCount : UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        arrImages = NSMutableArray()
        arrImageStateWithImage = NSMutableArray()
        
        if(countAlreadySelectedImages==0)
        {
            countAlreadySelectedImages = numberOfImagesWantSelect
        }
        else
        {
            countAlreadySelectedImages = numberOfImagesWantSelect - countAlreadySelectedImages
        }
        
        self.displayImagesCount()
    }

    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        PHPhotoLibrary.requestAuthorization{
            [weak self](status: PHAuthorizationStatus) in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                switch status{
                case .Authorized:
                    self!.retrieveImage()
                default:
                    self!.displayAlertWithTitle("Access",
                        message: "I could not access the photo library")
                }
            })
        }
    }
    
    func displayAlertWithTitle(title: String, message: String)
    {
        let controller = UIAlertController(title: title,
            message: message,
            preferredStyle: .Alert)
        
        controller.addAction(UIAlertAction(title: "OK",
            style: .Default,
            handler: nil))
        
        presentViewController(controller, animated: true, completion: nil)
        
    }
    
    // MARK: - Set Navigation Tittle
    func displayImagesCount()
    {
        lblImagesCount.text = "Images ( \(countSelectedImages) / \(countAlreadySelectedImages))"
    }
    
    // MARK: - Get Images From Device Methods
    func retrieveImage()
    {
        /* Retrieve the items in order of modification date, ascending */
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "modificationDate",
            ascending: true)]
        
        /* Then get an object of type PHFetchResult that will contain
        all our image assets */
        assetResults = PHAsset.fetchAssetsWithMediaType(.Image,
            options: options)
        
        print("Found \(assetResults.count) results")
        
        let imageManager = PHCachingImageManager()
        
        
        assetResults.enumerateObjectsUsingBlock{(object: AnyObject,
            count: Int,
            stop: UnsafeMutablePointer<ObjCBool>) in
            
            if object is PHAsset{
                
                let asset = object as! PHAsset
                
                let imageSize = CGSize(width: asset.pixelWidth,
                    height: asset.pixelHeight)
                
                /* For faster performance, and maybe degraded image */
                let options = PHImageRequestOptions()
                options.deliveryMode = .FastFormat
                imageManager.requestImageForAsset(asset,
                    targetSize: imageSize,
                    contentMode: PHImageContentMode.AspectFill,
                    options: options,
                    resultHandler: {(image: UIImage?,
                        info: [NSObject : AnyObject]?) in
                        
                        self.arrImages.addObject(image!)
                        self.arrImageStateWithImage.addObject(0)
                        
                        if(count==self.assetResults.count-1)
                        {
                            self.collectionView.reloadData()
                        }
                        
                })
            }
        }
    }
    
    // MARK: - CollectionView Delegate Methods
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        return CGSizeMake(self.view.frame.size.width/4-20, self.view.frame.size.width/4-20)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if ((arrImages) != nil)
        {
            return arrImages.count
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        
        let imgView = cell.viewWithTag(10) as! UIImageView
        
        imgView.image=self.arrImages.objectAtIndex(indexPath.row) as? UIImage
        
        if(self.arrImageStateWithImage.objectAtIndex(indexPath.row) as! NSObject == 0)
        {
            self.changeSelectedImageView(imgView, state: false)
        }
        else
        {
            self.changeSelectedImageView(imgView, state: true)
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        
        let selectedImageView = collectionView.cellForItemAtIndexPath(indexPath)?.viewWithTag(10) as! UIImageView
        
        if(arrImageStateWithImage.objectAtIndex(indexPath.row) as! NSObject == 0)
        {
            if(countSelectedImages<countAlreadySelectedImages)
            {
                countSelectedImages = countSelectedImages+1
                self.displayImagesCount()
                self.changeSelectedImageView(selectedImageView, state: true)
                self.arrImageStateWithImage .replaceObjectAtIndex(indexPath.row, withObject: arrImages.objectAtIndex(indexPath.row))
            }
            else
            {
                let alert = UIAlertController(title: "Alert", message: "You can't select more than \(countAlreadySelectedImages) Images", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                let okAction = UIAlertAction(title: "Done", style: UIAlertActionStyle.Default) {
                    UIAlertAction in
                    self.done()
                }
                alert.addAction(okAction)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        else
        {
            countSelectedImages = countSelectedImages-1
            self.displayImagesCount()
            self.changeSelectedImageView(selectedImageView, state: false)
            self.arrImageStateWithImage .replaceObjectAtIndex(indexPath.row, withObject: 0)
        }
        
    }
    
    // MARK: - Image Selected Border & Animation Methods
    func changeSelectedImageView(selectedImageView : UIImageView, state : Bool)
    {
        if state {
            selectedImageView.layer.borderWidth = 4.0
            selectedImageView.layer.borderColor = UIColor(colorLiteralRed: 247/255, green: 156/255, blue: 51/255, alpha: 0.9).CGColor
        } else {
            selectedImageView.layer.borderWidth = 0
            selectedImageView.layer.borderColor = UIColor.clearColor().CGColor
        }
        
        UIView.animateWithDuration((0.3/1.5), animations: { () -> Void in
            selectedImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
            }) { (finish) -> Void in
                UIView.animateWithDuration((0.3/2), animations: { () -> Void in
                    selectedImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
                    }) { (finish) -> Void in
                        
                        UIView.animateWithDuration((0.3/2), animations: { () -> Void in
                            selectedImageView.transform = CGAffineTransformIdentity;
                            }) { (finish) -> Void in
                        }
                }
        }
        
    }
    
    // MARK: - Done Cancel Button
    @IBAction func btnCacelTapped(sender: UIButton)
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnDoneTapped(sender: UIButton)
    {
        self.done()
    }
    
    // MARK: - Pop
    func done()
    {
        delegate!.selectedImagesArray(arrImageStateWithImage)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
