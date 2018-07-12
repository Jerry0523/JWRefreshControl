//
//  SegmentContentView.swift
//  JWRefreshControlDemo
//
//  Created by Jerry on 2018/4/11.
//  Copyright © 2018年 Jerry. All rights reserved.
//

import UIKit
import JWRefreshControl

class SegmentContentView: UIView {

    static let SegmentThreshold = CGFloat(1.5)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(backgroundImageView)
        addSubview(titleLabel)
        
        backgroundImageView.autoresizingMask = .flexibleWidth
        
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.darkText
        titleLabel.font = UIFont.systemFont(ofSize: 14.0)
        titleLabel.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect(x: 0, y: frame.size.height - 30.0, width: frame.size.width, height: 30.0)
        backgroundImageView.frame = CGRect(x: 0, y: frame.size.height - UIScreen.main.bounds.size.height, width: frame.size.width, height: UIScreen.main.bounds.size.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize { return CGSize(width: UIViewNoIntrinsicMetric, height: 100.0) }
    
    private let titleLabel = UILabel()
    private let backgroundImageView = UIImageView(image: UIImage(named: "background"))
    
}

extension SegmentContentView : AnyRefreshContent {    
    
    func start() {
        titleLabel.text = MsgLoading
    }
    
    func stop() {
        titleLabel.text = MsgPullToRefresh
    }
    
    func setProgress(_ progress: CGFloat) {
        if progress < 1.0 {
            titleLabel.text = MsgPullToRefresh
        } else if progress < SegmentContentView.SegmentThreshold {
            titleLabel.text = MsgReleaseToRefresh
        } else {
            titleLabel.text = MsgGoToSecondFloor
        }
    }
    
}

private let MsgReleaseToRefresh = "Release to Refresh"
private let MsgPullToRefresh = "Pull to Refresh"
private let MsgGoToSecondFloor = "Keep dragging to Second Floor"
private let MsgLoading = "Loading"
