//
//  SecondFloorPresentationController.swift
//  JWRefreshControlDemo
//
//  Created by Jerry on 2018/4/11.
//  Copyright © 2018年 Jerry. All rights reserved.
//

import UIKit

class SecondFloorPresentationController: UIPresentationController {
    
    var topMaskView: UIView?

    override func presentationTransitionWillBegin() {
        if let nc = presentingViewController as? UINavigationController,
            let collectionVC = nc.topViewController as? UICollectionViewController {
            presentedViewController.view.frame = containerView!.bounds
            presentedViewController.view.layoutIfNeeded()
            topMaskView = presentedViewController.view.resizableSnapshotView(from: CGRect(x: 0, y: 0, width: collectionVC.view.bounds.width, height: collectionVC.view.safeAreaInsets.top), afterScreenUpdates: true, withCapInsets: UIEdgeInsets.zero)
            containerView?.addSubview(topMaskView!)
            presentedViewController.view.alpha = 0
            topMaskView?.alpha = 0
            
            UIView.animate(withDuration: CATransaction.animationDuration()) {
                nc.navigationBar.alpha = 0
                collectionVC.collectionView?.setContentOffset(CGPoint(x: 0, y: -UIScreen.main.bounds.size.height), animated: false)
                self.topMaskView?.alpha = 1.0
            }
        }
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        UIView.animate(withDuration: CATransaction.animationDuration(), animations: {
            self.presentedViewController.view.alpha = 1.0
        }) { (completed) in
            self.topMaskView?.removeFromSuperview()
        }        
    }
    
    override func dismissalTransitionWillBegin() {
        presentedViewController.view.alpha = 0
        if let nc = presentingViewController as? UINavigationController,
            let collectionVC = nc.topViewController as? UICollectionViewController {
            collectionVC.collectionView?.setContentOffset(CGPoint(x: 0, y: -collectionVC.view.safeAreaInsets.top), animated: true)
            UIView.animate(withDuration: 0.25) {
                nc.navigationBar.alpha = 1.0
            }
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        presentedViewController.view.alpha = 1
    }
    
}
