//
//  CollectionViewContentViewController.swift
//  JWRefreshControlDemo
//
//  Created by Jerry on 2017/11/9.
//  Copyright © 2017年 Jerry. All rights reserved.
//

import UIKit

private let reuseIdentifier = "default"
private let batchCount = 27

class CollectionViewContentViewController: UICollectionViewController {
    
    var data: [Int] = {
        var data: [Int]?
        FakeRequest.createMockData(forStartIndex: 1, batchCount: batchCount, callBack: { (output) in
            data = output
        }, delay: nil)
        return data!
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let flowlayout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            let itemWidth = (self.view.frame.size.width - 40) / 3.0
            flowlayout.itemSize = CGSize.init(width: itemWidth, height: itemWidth)
        }
        
        self.collectionView?.addRefreshHeader { [weak self] (header) in
            if self == nil {
                return
            }
            
            FakeRequest.createMockData(forStartIndex: 1, batchCount: batchCount, callBack: { [weak self] (output) in
                self?.data = output
                header.loadedSuccess()
                self?.collectionView?.reloadData()
            })
        }
        
        self.collectionView?.addRefreshFooter { [weak self] (footer) in
            if self == nil {
                return
            }
            
            if self!.data.count >= batchCount * 3 {
                footer.loadedPause(withMsg: "No More Data")
            } else {
                FakeRequest.createMockData(forStartIndex: self!.data.count + 1, callBack: { [weak self] (output) in
                    self?.data.append(contentsOf: output)
                    footer.loadedSuccess()
                    self?.collectionView?.reloadData()
                })
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        if let label = cell.contentView.subviews.first as? UILabel {
            label.text = "\(data[indexPath.item])"
        }
        return cell
    }
}
