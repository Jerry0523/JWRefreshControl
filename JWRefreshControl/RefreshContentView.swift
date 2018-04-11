//
// RefreshContentView.swift
//
// Copyright (c) 2015 Jerry Wong
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

open class DefaultRefreshHeaderContentView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    open override var intrinsicContentSize: CGSize { return CGSize(width: UIViewNoIntrinsicMetric, height: 70.0) }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        arrowView.center = CGPoint.init(x: frame.size.width * 0.5, y: frame.size.height * 0.5 - 11.0)
        successView.center = CGPoint.init(x: frame.size.width * 0.5, y: frame.size.height * 0.5 - 11.0)
        progressView.center = CGPoint.init(x: frame.size.width * 0.5, y: frame.size.height * 0.5 - 11.0)
        loadingView.center = CGPoint.init(x: frame.size.width * 0.5, y: frame.size.height * 0.5 - 11.0)
        errorLabel.center = CGPoint.init(x: frame.size.width * 0.5, y: frame.size.height * 0.5 - 11.0)
        statusLabel.center = CGPoint.init(x: frame.size.width * 0.5, y: frame.size.height * 0.5 + 11.0)
    }
    
    private func setup() {
        arrowView.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleRightMargin]
        arrowView.lineWidth = 2.0
        arrowView.type = .arrow
        arrowView.subType = .arrowBottom
        arrowView.isHidden = true
        addSubview(arrowView)
        
        successView.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleRightMargin]
        successView.lineWidth = 2.0
        successView.type = .yes
        successView.isHidden = true
        addSubview(successView)
        
        progressView.drawBackground = false
        progressView.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleRightMargin]
        progressView.lineWidth = 2.0
        addSubview(progressView)
        
        loadingView.drawBackground = false
        loadingView.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleRightMargin]
        loadingView.style = .cumulative
        loadingView.lineWidth = 2.0
        addSubview(loadingView)
        
        var frame = errorLabel.frame
        frame.size.width = frame.size.width

        errorLabel.frame = frame
        errorLabel.textColor = UIColor.init(white: 80.0 / 255.0, alpha: 1.0)
        errorLabel.textAlignment = .center
        errorLabel.font = UIFont.systemFont(ofSize: 12.0)
        errorLabel.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleRightMargin, .flexibleWidth]
        addSubview(errorLabel)
        
        frame = statusLabel.frame
        frame.size.width = frame.size.width
        statusLabel.frame = frame
        statusLabel.textColor = UIColor.init(white: 80.0 / 255.0, alpha: 1.0)
        statusLabel.textAlignment = .center
        statusLabel.font = UIFont.systemFont(ofSize: 12.0)
        statusLabel.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
        addSubview(statusLabel)
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(didTapContentView(sender:)))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func didTapContentView(sender: Any?) {
        if let refreshable = superview as? RefreshHeaderControl<DefaultRefreshHeaderContentView> {
            refreshable.refreshingBlock?(refreshable)
            start()
        }
    }
    
    private func reset() {
        loadingView.isHidden = true
        successView.isHidden = true
        errorLabel.isHidden = true
        arrowView.isHidden = true
        progressView.isHidden = true
        isUserInteractionEnabled = false
    }
    
    private let arrowView = SimpleShapeView.init(frame: CGRect.init(x: 0, y: 0, width: 10, height: 10))
    private let successView = SimpleShapeView.init(frame: CGRect.init(x: 0, y: 0, width: 10, height: 10))
    private let progressView = CircleProgressView.init(frame: CGRect.init(x: 0, y: 0, width: 22, height: 22))
    private let loadingView = CircleLoadingView.init(frame: CGRect.init(x: 0, y: 0, width: 22, height: 22))
    private let errorLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 22))
    private let statusLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 22))
}

extension DefaultRefreshHeaderContentView : AnyRefreshContent {
    
    open static var isPinnedToEdge = true
    
    open func setProgress(_ progress: CGFloat) {
        reset()
        
        arrowView.isHidden = false
        progressView.isHidden = false
        
        let progress = max(min(progress, 1), 0)
        
        progressView.progress = progress
        if progress == 1 {
            arrowView.subType = .arrowTop
            statusLabel.text = MsgReleaseToRefresh
        } else {
            arrowView.subType = .arrowBottom
            statusLabel.text = MsgPullToRefresh
        }
    }
    
    open func start() {
        reset()
        
        loadingView.isHidden = false
        loadingView.startAnimating()
        statusLabel.text = MsgLoading
        
    }
    
    open func stop() {
        reset()
        loadingView.stopAnimating()
        statusLabel.text = nil
    }
    
    open func success() {
        reset()
        successView.isHidden = false
        progressView.isHidden = false
        progressView.progress = 1.0
        statusLabel.text = MsgSuccess
        loadingView.stopAnimating()
        successView.beginSimpleAnimation()

    }
    
    open func error(withMsg msg: String) {
        reset()
        errorLabel.isHidden = false
        errorLabel.text = msg
        statusLabel.text = MsgClickToRetry
        loadingView.stopAnimating()
        isUserInteractionEnabled = true
    }
}

open class DefaultRefreshFooterContentView : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    open override var intrinsicContentSize: CGSize { return CGSize(width: UIViewNoIntrinsicMetric, height: 50.0) }
    
    private func setup() {
        
        var frame = centerLabel.frame
        frame.size.width = frame.size.width
        
        centerLabel.frame = frame
        centerLabel.textColor = UIColor.init(white: 80.0 / 255.0, alpha: 1.0)
        centerLabel.textAlignment = .center
        centerLabel.font = UIFont.systemFont(ofSize: 12.0)
        centerLabel.autoresizingMask = .flexibleWidth
        addSubview(centerLabel)
        
        frame = errorLabel.frame
        frame.size.width = frame.size.width
        
        errorLabel.frame = frame
        errorLabel.textColor = UIColor.init(white: 80.0 / 255.0, alpha: 1.0)
        errorLabel.textAlignment = .center
        errorLabel.font = UIFont.systemFont(ofSize: 12.0)
        errorLabel.autoresizingMask = .flexibleWidth
        addSubview(errorLabel)
        
        frame = statusLabel.frame
        frame.size.width = frame.size.width
        
        statusLabel.frame = frame
        statusLabel.textColor = UIColor.init(white: 80.0 / 255.0, alpha: 1.0)
        statusLabel.textAlignment = .center
        statusLabel.font = UIFont.systemFont(ofSize: 12.0)
        statusLabel.autoresizingMask = .flexibleWidth
        addSubview(statusLabel)
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(didTapContentView(sender:)))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func didTapContentView(sender: Any?) {
        if let refreshable = superview as? RefreshFooterControl<DefaultRefreshFooterContentView> {
            refreshable.refreshingBlock?(refreshable)
            start()
        }
    }
    
    private func reset() {
        errorLabel.isHidden = true
        centerLabel.isHidden = true
        statusLabel.isHidden = true
        isUserInteractionEnabled = false
    }
    
    private let centerLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 50))
    private let errorLabel = UILabel.init(frame: CGRect.init(x: 0, y: 8, width: 0, height: 17))
    private let statusLabel = UILabel.init(frame: CGRect.init(x: 0, y: 25, width: 0, height: 17))
}

extension DefaultRefreshFooterContentView : AnyRefreshContent {
    
    open func start() {
        reset()
        centerLabel.isHidden = false
        centerLabel.text = MsgLoading
    }
    
    open func stop() {
        reset()
        statusLabel.text = nil
    }
    
    open func error(withMsg msg: String) {
        reset()
        errorLabel.isHidden = false
        statusLabel.isHidden = false
        errorLabel.text = msg
        statusLabel.text = MsgClickToRetry
        isUserInteractionEnabled = true
    }
    
    open func pause(withMsg msg: String) {
        reset()
        centerLabel.isHidden = false
        centerLabel.text = msg
    }
    
    open func success() {
        reset()
    }
}

fileprivate extension String {
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
}

private let MsgReleaseToRefresh = "Release to Refresh".localized
private let MsgPullToRefresh = "Pull to Refresh".localized
private let MsgLoading = "Loading".localized
private let MsgSuccess = "Success".localized
private let MsgClickToRetry = "Click to Retry".localized
