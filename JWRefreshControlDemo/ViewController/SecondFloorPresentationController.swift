//
//  SecondFloorPresentationController.swift
//  JWRefreshControlDemo
//
//  Created by Jerry on 2018/4/11.
//  Copyright © 2018年 Jerry. All rights reserved.
//

import UIKit

class SecondFloorPresentationController: UIPresentationController {

    var maskViews: [UIView] = [UIView]()
    
    weak var contentViewController: UIViewController?

    override func presentationTransitionWillBegin() {
        if let collectionVC = contentViewController as? UICollectionViewController {
            
            presentedViewController.view.frame = containerView!.bounds
            presentedViewController.view.layoutIfNeeded()
            
            maskViews.removeAll()
            
            if !(collectionVC.navigationController?.isNavigationBarHidden ?? false) {
                if let topMaskView = presentedViewController.view.resizableSnapshotView(from: CGRect(x: 0, y: 0, width: collectionVC.view.bounds.width, height: collectionVC.view.safeAreaInsets.top), afterScreenUpdates: true, withCapInsets: UIEdgeInsets.zero) {
                    maskViews.append(topMaskView)
                    containerView?.addSubview(topMaskView)
                }
            }
            
            if !(collectionVC.tabBarController?.tabBar.isHidden ?? false) {
                let frame = CGRect(x: 0, y: collectionVC.view.bounds.height - collectionVC.view.safeAreaInsets.bottom, width: collectionVC.view.bounds.width, height: collectionVC.view.safeAreaInsets.bottom)
                if let bottomMaskView = presentedViewController.view.resizableSnapshotView(from: frame, afterScreenUpdates: true, withCapInsets: UIEdgeInsets.zero) {
                    maskViews.append(bottomMaskView)
                    bottomMaskView.frame = frame
                    containerView?.addSubview(bottomMaskView)
                }
            }
            
            maskViews.forEach { $0.alpha = 0 }
            
            presentedViewController.view.alpha = 0
            
            UIView.animate(withDuration: CATransaction.animationDuration()) {
                collectionVC.navigationController?.navigationBar.alpha = 0
                collectionVC.tabBarController?.tabBar.alpha = 0
                collectionVC.collectionView?.setContentOffset(CGPoint(x: 0, y: -UIScreen.main.bounds.size.height), animated: false)
                self.maskViews.forEach { $0.alpha = 1.0 }
            }
        }
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        UIView.animate(withDuration: CATransaction.animationDuration(), animations: {
            self.presentedViewController.view.alpha = 1.0
        }) { (completed) in
            self.maskViews.forEach { $0.removeFromSuperview() }
        }        
    }
    
    override func dismissalTransitionWillBegin() {
        presentedViewController.view.alpha = 0
        if let collectionVC = contentViewController as? UICollectionViewController {
            UIView.animate(withDuration: 0.25) {
                collectionVC.navigationController?.navigationBar.alpha = 1.0
                collectionVC.tabBarController?.tabBar.alpha = 1.0
                collectionVC.collectionView?.setContentOffset(CGPoint(x: 0, y: -collectionVC.view.safeAreaInsets.top), animated: false)
            }
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        presentedViewController.view.alpha = 1
    }
    
}
