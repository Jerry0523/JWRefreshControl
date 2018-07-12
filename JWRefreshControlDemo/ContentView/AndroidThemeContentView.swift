//
//  AndroidThemeContentView.swift
//  JWRefreshControlDemo
//
//  Created by Jerry on 2017/12/6.
//  Copyright © 2017年 Jerry. All rights reserved.
//

import UIKit
import JWRefreshControl

class AndroidThemeContentView: UIView {
    
    private let imageView = UIImageView(image: UIImage(named: "loading")?.withRenderingMode(.alwaysTemplate))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.tintColor = UIColor.red
        addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override var intrinsicContentSize: CGSize { return CGSize(width: UIViewNoIntrinsicMetric, height: 70.0) }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.center = CGPoint(x: self.bounds.size.width * 0.5, y: self.bounds.size.height * 0.5)
    }
}

extension AndroidThemeContentView : AnyRefreshContent {
    
    static var behaviour = RefreshContentBehaviour.android
    
    func start() {
        layer.speed = 1.0
    }
    
    func stop() {
        layer.removeAnimation(forKey: AnimKey)
    }
    
    func setProgress(_ progress: CGFloat) {
        let anim = layer.animation(forKey: AnimKey)
        if anim == nil {
            let anim = CABasicAnimation(keyPath: "transform.rotation.z")
            anim.toValue = Double.pi * 2.0
            anim.duration = 1.0
            anim.repeatCount = Float.greatestFiniteMagnitude
            layer.add(anim, forKey: AnimKey)
        }
        layer.speed = 0
        layer.timeOffset = (anim?.duration ?? 0) * Double(progress)
    }
}

private let AnimKey = "j_rotate"
