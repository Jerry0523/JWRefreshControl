//
//  CollectionViewController.swift
//  JWRefreshControlDemo
//
//  Created by Jerry on 2017/11/9.
//  Copyright © 2017年 Jerry. All rights reserved.
//

import UIKit
import JWRefreshControl

private let reuseIdentifier = "default"
private let batchCount = 27

class CollectionViewController: UICollectionViewController {
    
    var data: [Int] = {
        var data: [Int]?
        FakeRequest.createMockData(forStartIndex: 1, batchCount: batchCount, callBack: { (output) in
            data = output
        }, delay: nil)
        return data!
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let flowlayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            let itemWidth = (view.frame.size.width - 40) / 3.0
            flowlayout.itemSize = CGSize.init(width: itemWidth, height: itemWidth)
        }
        
        
        let refreshHeader: RefreshHeaderControl<SegmentContentView>? = collectionView?.addCustomRefreshHeader { [weak self] (header) in
            if self == nil {
                return
            }
            
            FakeRequest.createMockData(forStartIndex: 1, batchCount: batchCount, callBack: { [weak self] (output) in
                self?.data = output
                header.success()
                self?.collectionView?.reloadData()
            })
        }
        refreshHeader?.progressHandler = progressHandler
    
        collectionView?.addRefreshFooter { [weak self] (footer) in
            if self == nil {
                return
            }
            
            if self!.data.count >= batchCount * 3 {
                footer.pause(withMsg: "No More Data")
            } else {
                FakeRequest.createMockData(forStartIndex: self!.data.count + 1, callBack: { [weak self] (output) in
                    self?.data.append(contentsOf: output)
                    footer.success()
                    self?.collectionView?.reloadData()
                })
            }
        }
    }
    
    func progressHandler(refreshHeader: RefreshHeaderControl<SegmentContentView>, progress: CGFloat) {
        if progress < 1.0 {
            refreshHeader.state = .idle
        } else if progress < SegmentContentView.SegmentThreshold {
            refreshHeader.state = .refreshing
        } else {
            let secondFloorVC = SecondFloorViewController()
            secondFloorVC.modalPresentationStyle = .custom
            secondFloorVC.transitioningDelegate = self
            self.present(secondFloorVC, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        if let label = cell.contentView.subviews.first as? UILabel {
            label.text = "\(data[indexPath.item])"
        }
        return cell
    }
}

extension CollectionViewController : UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presenter = SecondFloorPresentationController(presentedViewController: presented, presenting: presenting)
        presenter.contentViewController = self
        return presenter
    }
    
}
