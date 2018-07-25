//
//  CustomImagePickerVC.swift
//  MyApartment
//
//  Created by Shrikant Tanwade on 25/07/17.
//  Copyright © 2016 Shrikant. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

protocol CustomImagePickerVCDelegate {
    func selectedImagesArray(imageArray:NSMutableArray)
}

class CustomImagePickerVC: UIViewController {
    
    var delegate:CustomImagePickerVCDelegate! = nil
    
    var arrImages : NSMutableArray!
    var assetResults : PHFetchResult<AnyObject>!
    var arrImageStateWithImage : NSMutableArray!
    
    var countAlreadySelectedImages : Int! = 0
    var countSelectedImages : Int! = 0
    var numberOfImagesWantSelect : Int! = 0
    
    @IBOutlet weak var collectionView : UICollectionView!
    @IBOutlet weak var lblImagesCount : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arrImages = NSMutableArray()
        arrImageStateWithImage = NSMutableArray()
        
        if(countAlreadySelectedImages==0) {
            countAlreadySelectedImages = numberOfImagesWantSelect!
        } else {
            countAlreadySelectedImages = numberOfImagesWantSelect! - countAlreadySelectedImages!
        }
        
        self.displayImagesCount()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        PHPhotoLibrary.requestAuthorization { [weak self](status: PHAuthorizationStatus) in
            DispatchQueue.global(qos: .userInitiated).async {
                switch status{
                case .authorized:
                    self!.retrieveImage()
                default:
                    self!.displayAlertWithTitle(title: "Access", message: "I could not access the photo library")
                }
            }
        }
    }
}
// MARK: - Actions
extension CustomImagePickerVC {
    // MARK: - Set Navigation Tittle
    func displayImagesCount() {
        lblImagesCount.text = "Images ( \(countSelectedImages!) / \(countAlreadySelectedImages!))"
    }
    
    // MARK: - Done Cancel Button
    @IBAction func btnCacelTapped(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnDoneTapped(sender: UIButton) {
        self.done()
    }
    
    // MARK: - Pop
    func done() {
        delegate!.selectedImagesArray(imageArray: arrImageStateWithImage)
        self.navigationController?.popViewController(animated: true)
    }
    
    func displayAlertWithTitle(title: String, message: String) {
        let controller = UIAlertController(title: title,message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(controller, animated: true, completion: nil)
    }
}

// MARK: - Get Images From Device Methods
extension CustomImagePickerVC {
    
    func retrieveImage() {
        /* Retrieve the items in order of modification date, ascending */
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: true)]
        
        /* Then get an object of type PHFetchResult that will contain
         all our image assets */
        assetResults = PHAsset.fetchAssets(with: .image, options: options) as! PHFetchResult<AnyObject>
        
        print("Found \(assetResults.count) results")
        let imageManager = PHCachingImageManager()
        
        assetResults.enumerateObjects{(object: AnyObject, count: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            if object is PHAsset {
                let asset = object as! PHAsset
                let imageSize = CGSize(width: asset.pixelWidth,height: asset.pixelHeight)
                
                /* For faster performance, and maybe degraded image */
                let options = PHImageRequestOptions()
                options.deliveryMode = .fastFormat
                imageManager.requestImage(for: asset, targetSize: imageSize, contentMode: PHImageContentMode.aspectFit, options: options, resultHandler: { (image: UIImage?, info:[AnyHashable:Any]?) in
                    
                    self.arrImages.add(image!)
                    self.arrImageStateWithImage.add(0)
                    if(count==self.assetResults.count-1) {
                        self.collectionView.reloadData()
                    }
                })
            }
        }
    }
}

// MARK: - CollectionView Delegate Methods
extension CustomImagePickerVC: UICollectionViewDataSource,UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: self.view.frame.size.width/4-20, height: self.view.frame.size.width/4-20)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if ((arrImages) != nil) {
            return arrImages.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let imgView = cell.viewWithTag(10) as! UIImageView
        imgView.image=self.arrImages.object(at: indexPath.row) as? UIImage
        
        if self.arrImageStateWithImage.object(at: indexPath.row) is Int {
            self.changeSelectedImageView(selectedImageView: imgView, state: false)
        } else {
            self.changeSelectedImageView(selectedImageView: imgView, state: true)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedImageView = collectionView.cellForItem(at: indexPath)?.viewWithTag(10) as! UIImageView
        if arrImageStateWithImage.object(at: indexPath.row) is Int {
            if(countSelectedImages!<countAlreadySelectedImages!) {
                countSelectedImages = countSelectedImages!+1
                self.displayImagesCount()
                self.changeSelectedImageView(selectedImageView: selectedImageView, state: true)
                self.arrImageStateWithImage .replaceObject(at: indexPath.row, with: arrImages.object(at: indexPath.row))
            } else {
                let alert = UIAlertController(title: "Alert", message: "You can't select more than \(countAlreadySelectedImages!) Images", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                let okAction = UIAlertAction(title: "Done", style: UIAlertActionStyle.default) { UIAlertAction in
                    self.done()
                }
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            countSelectedImages = countSelectedImages!-1
            self.displayImagesCount()
            self.changeSelectedImageView(selectedImageView: selectedImageView, state: false)
            self.arrImageStateWithImage .replaceObject(at: indexPath.row, with: 0)
        }
    }
    
    // MARK: - Image Selected Border & Animation Methods
    func changeSelectedImageView(selectedImageView : UIImageView, state : Bool) {
        if state {
            selectedImageView.layer.borderWidth = 4.0
            selectedImageView.layer.borderColor = UIColor(red: 247/255, green: 156/255, blue: 51/255, alpha: 0.9).cgColor
        } else {
            selectedImageView.layer.borderWidth = 0
            selectedImageView.layer.borderColor = UIColor.clear.cgColor
        }
        
        UIView.animate(withDuration: (0.3/1.5), animations: { () -> Void in
            selectedImageView.transform = CGAffineTransform.init(scaleX: 1.1, y: 1.1)
        }) { (finish) -> Void in
            UIView.animate(withDuration: (0.3/2), animations: { () -> Void in
                selectedImageView.transform = CGAffineTransform.init(scaleX: 0.9, y: 0.9);
            }) { (finish) -> Void in
                
                UIView.animate(withDuration: (0.3/2), animations: { () -> Void in
                    selectedImageView.transform = CGAffineTransform.identity;
                }) { (finish) -> Void in
                }
            }
        }
    }
}
