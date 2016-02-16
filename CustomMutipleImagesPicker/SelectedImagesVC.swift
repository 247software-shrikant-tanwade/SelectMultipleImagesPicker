//
//  SelectedImagesVC.swift
//  CustomMutipleImagesPicker
//
//  Created by Shrikant Tanwade on 16/02/16.
//  Copyright © 2016 Shrikant. All rights reserved.
//

import UIKit

class SelectedImagesVC: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,CustomImagePickerVCDelegate
{
    @IBOutlet weak var txtNumberOfImagesWantSelect : UITextField!
    @IBOutlet weak var collectionView : UICollectionView!
    var arrImages : NSMutableArray!
    var countSelectedImages : Int! = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden=true
        arrImages = NSMutableArray()
    }
    
    // MARK: - CustomImagePickerVC Delegate Methods
    func selectedImagesArray(imageArray: NSMutableArray)
    {
        
        for obj in imageArray {
            if obj as! NSObject != 0 {
                arrImages.addObject(obj)
                countSelectedImages = countSelectedImages + 1
            }
        }
        
        collectionView.reloadData()
    }
    
    
    // MARK: - CollectionView Delegate Methods
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return arrImages.count+1;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        
        let imgView = cell.viewWithTag(10) as! UIImageView
        let lblDelete = cell.viewWithTag(11) as! UILabel
        
        if(indexPath.row == arrImages.count)
        {
            imgView.image = UIImage(imageLiteral: "add@3x.png")
            lblDelete.hidden=true
        }
        else
        {
            imgView.image = arrImages.objectAtIndex(indexPath.row) as? UIImage
            lblDelete.layer.masksToBounds=true
            lblDelete.layer.cornerRadius = lblDelete.frame.size.width / 2
            lblDelete.hidden=false
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        if(indexPath.row == arrImages.count)
        {
            if(countSelectedImages<Int(txtNumberOfImagesWantSelect.text!))
            {
                self.performSegueWithIdentifier("SegueCustomImagePicker", sender: self)
            }
        }
        else
        {
            countSelectedImages = countSelectedImages-1
            arrImages.removeObjectAtIndex(indexPath.row)
            collectionView.reloadData()
        }
    }
    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        self.view.endEditing(true)
        if segue.identifier == "SegueCustomImagePicker"
        {
            let vc = segue.destinationViewController as! CustomImagePickerVC
            vc.delegate = self
            vc.countAlreadySelectedImages=self.countSelectedImages
            
            let txtTemp = Int(txtNumberOfImagesWantSelect.text!)
            if((txtTemp) != nil)
            {
                vc.numberOfImagesWantSelect=Int(txtNumberOfImagesWantSelect.text!)
            }
        }
    }
    
    // MARK: - Convert Image to Base64String
    func imageBase64String(image : UIImage!)->NSString
    {
        var base64String : String!
        
        if (image != nil)
        {
            let imageData = UIImageJPEGRepresentation(image!, 0.5)
            base64String = imageData!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        }
        
        return base64String
    }
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
