//
//  GifContentView.swift
//  JWRefreshControlDemo
//
//  Created by Jerry on 2017/12/6.
//  Copyright © 2017年 Jerry. All rights reserved.
//

import UIKit
import JWRefreshControl

class GifContentView: UIView {
    
    private let imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 160, height: 160))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.animationDuration = 1.0
        imageView.animationImages = (0..<FrameCount).map({ UIImage.init(named: "frame\($0)")!})
        addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.center = CGPoint.init(x: self.bounds.size.width * 0.5, y: self.bounds.size.height * 0.5)
    }
}

extension GifContentView : AnyRefreshContent {
    
    static var preferredHeight: CGFloat {
        return 160.0
    }
    
    func startLoading() {
        imageView.startAnimating()
    }
    
    func stopLoading() {
        imageView.stopAnimating()
    }
    
    func setProgress(_ progress: CGFloat) {
        imageView.stopAnimating()
        imageView.image = UIImage.init(named: "frame\(Int(progress * 25.0) % FrameCount)")
    }
}

private let FrameCount = 15
