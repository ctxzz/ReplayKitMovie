//
//  TabAllViewController.swift
//  ReplayKitMovie
//
//  Created by Atsushi OMATA on 2017/11/14.
//  Copyright © 2017 Atsushi OMATA. All rights reserved.
//

import Foundation
import UIKit
import Photos

class TabAllViewController: UIViewController {
    var collectionView: UICollectionView!
//    var playerViewController: PlayerViewController!
    
    var videoAssets = [PHAsset]()
    var videoThumbnails = [UIImage?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "動画一覧"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setVideoCollection()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setVideoCollection() {
        videoAssets = []
        videoThumbnails = []
        
        let manager = PHImageManager()
        
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        options.fetchLimit = 100
        
        let assets = PHAsset.fetchAssets(with: PHAssetMediaType.video, options: options)
        assets.enumerateObjects({ (asset, index, stop) -> Void in
            self.videoAssets.append(asset)
            manager.requestImage(for: asset, targetSize: CGSize(width: 160, height: 120), contentMode: .aspectFill, options: nil, resultHandler: { (image, info) -> Void in
                self.videoThumbnails.append(image)
            })
        })
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsetsMake(20, 10, 20, 10)
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "MyCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white
        
        var topOffset:CGFloat = 60
        if #available(iOS 11, *) {
            topOffset = 0
        }
        let edgeInsets = UIEdgeInsets(top: topOffset, left: 0, bottom: 0, right: 0)
        collectionView.contentInset = edgeInsets
        collectionView.scrollIndicatorInsets = edgeInsets
        
        view.addSubview(collectionView)
    }
}

extension TabAllViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // イベント：cell選択
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    // リクエスト：アイテム総数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoAssets.count
    }
    
    // リクエスト：cell内容
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = self.videoAssets[(indexPath as NSIndexPath).row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath)
        if let thumbnail = self.videoThumbnails[(indexPath as NSIndexPath).row] {
            let uiImageView = UIImageView.init(image: thumbnail)
            cell.contentView.addSubview(uiImageView)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width / 5 - 20
        let height:CGFloat = 230
        return CGSize(width: width, height: height)
    }
}

