//
//  DetailPhotoViewController.swift
//  myPhotoLibrary
//
//  Created by Leonnardo Benjamin Hutama on 18/06/20.
//  Copyright © 2020 Leonnardo Benjamin Hutama. All rights reserved.
//

import UIKit

class DetailPhotoViewController: UIViewController {
    
    @IBOutlet var detailPhotoCollectionView: UICollectionView!
    
    var libraries = [Library]()
    var imageArray = [UIImage]()
    var selectedContentIndex = IndexPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        detailPhotoCollectionView.delegate = self
        detailPhotoCollectionView.dataSource = self
        
        setupCollectionViewLayout()
        
        setUpCollectionView()
    }

    func setUpCollectionView() {
        
        detailPhotoCollectionView.scrollToItem(at: selectedContentIndex, at: .left, animated: true)
    }
    
    func setupCollectionViewLayout() {
        let layout = UICollectionViewFlowLayout()
        
        layout.itemSize = detailPhotoCollectionView.frame.size
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing=0
        layout.minimumLineSpacing=0
        layout.scrollDirection = .horizontal
        
        detailPhotoCollectionView.collectionViewLayout = layout
    }

}

extension DetailPhotoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageCollectionViewCell
            cell.imgView.image = libraries[indexPath.section].photos![indexPath.item]
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageCollectionViewCell
        
        cell.imgView.image = imageArray[indexPath.item]
        
        return cell
    }
    
    
}
