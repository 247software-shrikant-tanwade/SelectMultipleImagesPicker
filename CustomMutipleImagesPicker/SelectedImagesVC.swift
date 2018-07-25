//
//  SelectedImagesVC.swift
//  CustomMutipleImagesPicker
//
//  Created by Shrikant Tanwade on 25/07/17.
//  Copyright © 2016 Shrikant. All rights reserved.
//

import UIKit

class SelectedImagesVC: UIViewController {
    
    @IBOutlet weak var txtNumberOfImagesWantSelect : UITextField!
    @IBOutlet weak var collectionView : UICollectionView!
    var arrImages : NSMutableArray!
    var countSelectedImages : Int! = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden=true
        arrImages = NSMutableArray()
    }
}

// MARK: - CustomImagePickerVC Delegate Methods
extension SelectedImagesVC : CustomImagePickerVCDelegate {
    
    func selectedImagesArray(imageArray: NSMutableArray) {
        self.view.endEditing(true)
        for obj in imageArray {
            if !(obj is Int) {
                arrImages.add(obj)
                countSelectedImages = countSelectedImages + 1
            }
        }
        collectionView.reloadData()
    }
}

// MARK: - CollectionView Delegate Methods
extension SelectedImagesVC : UICollectionViewDataSource,UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImages.count+1;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath)
        
        let imgView = cell.viewWithTag(10) as! UIImageView
        let lblDelete = cell.viewWithTag(11) as! UILabel
        
        if(indexPath.row == arrImages.count) {
            imgView.image = UIImage(named: "add@3x.png")
            lblDelete.isHidden=true
        } else {
            imgView.image = arrImages.object(at: indexPath.row) as? UIImage
            lblDelete.layer.masksToBounds=true
            lblDelete.layer.cornerRadius = lblDelete.frame.size.width / 2
            lblDelete.isHidden=false
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if(indexPath.row == arrImages.count) {
            if txtNumberOfImagesWantSelect.text! != "" {
                if(Int(countSelectedImages)<Int(txtNumberOfImagesWantSelect.text!)!) {
                    let vc = storyboard?.instantiateViewController(withIdentifier: "CustomImagePickerVC") as! CustomImagePickerVC
                    vc.delegate = self
                    vc.countAlreadySelectedImages=self.countSelectedImages
                    let txtTemp = Int(txtNumberOfImagesWantSelect.text!)
                    if((txtTemp) != nil) {
                        vc.numberOfImagesWantSelect=Int(txtNumberOfImagesWantSelect.text!)
                    }
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        } else {
            countSelectedImages = countSelectedImages-1
            arrImages.removeObject(at: indexPath.row)
            collectionView.reloadData()
        }
    }
}

// MARK: - Convert Image to Base64String
extension SelectedImagesVC {
    
    func imageBase64String(image : UIImage!)->NSString {
        var base64String : String!
        if (image != nil) {
            let imageData = UIImageJPEGRepresentation(image!, 0.5) as NSData?
            base64String = imageData!.base64EncodedString(options: .lineLength64Characters)
        }
        return base64String! as NSString
    }
}
