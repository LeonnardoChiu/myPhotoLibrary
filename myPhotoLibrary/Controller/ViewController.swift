//
//  ViewController.swift
//  myPhotoLibrary
//
//  Created by Leonnardo Benjamin Hutama on 15/06/20.
//  Copyright © 2020 Leonnardo Benjamin Hutama. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {

    @IBOutlet var photoCollectionView: UICollectionView!
    
    @IBOutlet var dateSegmentedControl: UISegmentedControl!
   
    var imageArray = [UIImage]()
        
    var libraries = [Library]() {
        didSet {
            photoCollectionView.reloadData()
        }
    }
    var arrayOfAsset = [PHAsset]()
    
    let formatter = DateFormatter()
    
    var selectedIndex = IndexPath()

    var allDaysSelected = false
    
    let waitAlert = UIAlertController(title: "Please Wait", message: "\n", preferredStyle: .alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpAlertView()
        
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        
        setUpSegmentedControl()
        
        setupCollectionViewLayout()
        
        checkAuthorizationStatus()
    }
    
    func setUpSegmentedControl() {
        dateSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
        dateSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.label], for: .selected)
        dateSegmentedControl.selectedSegmentIndex = 3
    }
    
    func setUpAlertView() {
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: waitAlert.view.frame.width/2-100, y: 30,width: 50, height: 50)) as UIActivityIndicatorView
        
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()
        
        waitAlert.view.addSubview(loadingIndicator)
    }
    
    func setupCollectionViewLayout() {
        
        let itemSize = UIScreen.main.bounds.width/3 - 3
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 0, bottom:  20, right: 0)
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 30)
        
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 3
        
        layout.sectionHeadersPinToVisibleBounds = true
        
        photoCollectionView.collectionViewLayout = layout
    }
    
    func checkAuthorizationStatus() {
        
        let authPhotos = PHPhotoLibrary.authorizationStatus()
        
        if authPhotos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                self.checkAuthorizationStatus()
            })
        }
        else {
            
            if authPhotos == .authorized {
                self.present(waitAlert, animated: true) {
                    self.getImages()
                }
            }
                
            else if authPhotos == .denied {
                
                let alert = UIAlertController(title: "Photos Access Denied", message: "App needs access to photos library.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            
            }
        }
    }
    
    func getImages() {
        
        let assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
        assets.enumerateObjects({ (object, count, stop) in
            self.arrayOfAsset.append(object)
        })
        
        self.arrayOfAsset.reverse()
        
        getAssetThumbnail(assets: arrayOfAsset)
    }
    
    func getAssetThumbnail(assets: [PHAsset]) {
        
        libraries.removeAll()
        imageArray.removeAll()
        
        var dateTemp = ""
        
        for asset in assets {
            
            let manager = PHImageManager.default()
            let option = PHImageRequestOptions()
            var image = UIImage()
            
            option.isSynchronous = true
//            option.deliveryMode = .highQualityFormat
            option.deliveryMode = .fastFormat
            
            manager.requestImage(for: asset, targetSize: CGSize(width: 500, height: 500), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
                image = result!
                
                if self.allDaysSelected {
                    self.imageArray.append(image)
                }
                else {
                    if dateTemp == "" {
                        dateTemp = self.formatter.string(from: asset.creationDate!)
                    }
                    
                    if dateTemp != self.formatter.string(from: asset.creationDate!) {
                        
                        var newLibrary = Library()
                        newLibrary.creationDate = dateTemp
                        newLibrary.photos = self.imageArray
                        self.libraries.append(newLibrary)
                        
                        self.imageArray.removeAll()
                        
                        dateTemp = self.formatter.string(from: asset.creationDate!)
                        
                        self.imageArray.append(image)
                        
                    }
                    else {
                        
                        self.imageArray.append(image)
                    }
                    
                    
                    self.photoCollectionView.reloadData()
                    
                }
            })
            
        }
        
        var newLibrary = Library()
        newLibrary.creationDate = dateTemp
        newLibrary.photos = self.imageArray
        self.libraries.append(newLibrary)

        self.imageArray.removeAll()
        
        DispatchQueue.main.async {
//            self.photoCollectionView.reloadData()
            
            self.waitAlert.dismiss(animated: true, completion: nil)
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToDetail" {
            let nextVC = segue.destination as! DetailPhotoViewController
            nextVC.libraries.append(contentsOf: self.libraries)
            nextVC.imageArray.append(contentsOf: self.imageArray)
            nextVC.selectedContentIndex = selectedIndex
        }
    }
    
    @IBAction func dateSegmentChanged(_ sender: Any) {
        if dateSegmentedControl.selectedSegmentIndex == 0 {
            allDaysSelected = false
            formatter.dateFormat = "yyyy"
        }
        else if dateSegmentedControl.selectedSegmentIndex == 1 {
            allDaysSelected = false
            formatter.dateFormat = "MMMM yyyy"
        }
        else if dateSegmentedControl.selectedSegmentIndex == 2 {
            allDaysSelected = false
            formatter.dateFormat = "dd MMMM, yyyy"
        }
        else {
            allDaysSelected = true
        }
        
        self.present(waitAlert, animated: true) {

            self.getAssetThumbnail(assets: self.arrayOfAsset)
        }
        
    }

}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if libraries.count != 0 {
            return libraries.count
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if libraries.count != 0 {
            return libraries[section].photos!.count
        }
        return imageArray.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if libraries.count != 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoCollectionViewCell
            cell.photoImgView.image = libraries[indexPath.section].photos![indexPath.item]
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoCollectionViewCell
        
//        cell.photoImgView.image = imageArray[indexPath.item]
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? HeaderCollectionReusableView {
            
            if libraries.count != 0 {
                sectionHeader.titleLabel.text = libraries[indexPath.section].creationDate ?? ""
            }
            else {
                sectionHeader.titleLabel.text = ""
            }
            
            return sectionHeader
        }
        
        return UICollectionReusableView()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedIndex = indexPath
        
        performSegue(withIdentifier: "segueToDetail", sender: self)
    }
    
}
