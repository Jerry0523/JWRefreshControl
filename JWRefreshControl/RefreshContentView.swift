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

public enum PullRefreshState {
    case idle
    case refreshing
    case pause
}

@objc public protocol AnyRefreshContent {
    
    static var preferredHeight: CGFloat { get }
    
    @objc optional func setProgress(progress: CGFloat)
    @objc optional func startLoading()
    @objc optional func stopLoading()
    @objc optional func loadedSuccess()
    @objc optional func loadedError(withMsg msg: String)
    @objc optional func loadedPause(withMsg msg: String)
}

open class DefaultRefreshHeaderContentView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.arrowView.center = CGPoint.init(x: self.frame.size.width * 0.5, y: self.frame.size.height * 0.5 - 11.0)
        self.successView.center = CGPoint.init(x: self.frame.size.width * 0.5, y: self.frame.size.height * 0.5 - 11.0)
        self.progressView.center = CGPoint.init(x: self.frame.size.width * 0.5, y: self.frame.size.height * 0.5 - 11.0)
        self.loadingView.center = CGPoint.init(x: self.frame.size.width * 0.5, y: self.frame.size.height * 0.5 - 11.0)
        self.errorLabel.center = CGPoint.init(x: self.frame.size.width * 0.5, y: self.frame.size.height * 0.5 - 11.0)
        self.statusLabel.center = CGPoint.init(x: self.frame.size.width * 0.5, y: self.frame.size.height * 0.5 + 11.0)
    }
    
    private func setup() {
        self.arrowView.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleRightMargin]
        self.arrowView.lineWidth = 2.0
        self.arrowView.type = .arrow
        self.arrowView.subType = .arrowBottom
        self.arrowView.isHidden = true
        self.addSubview(self.arrowView)
        
        self.successView.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleRightMargin]
        self.successView.lineWidth = 2.0
        self.successView.type = .yes
        self.successView.isHidden = true
        self.addSubview(self.successView)
        
        self.progressView.drawBackground = false
        self.progressView.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleRightMargin]
        self.progressView.lineWidth = 2.0
        self.addSubview(self.progressView)
        
        self.loadingView.drawBackground = false
        self.loadingView.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleRightMargin]
        self.loadingView.style = .cumulative
        self.loadingView.lineWidth = 2.0
        self.addSubview(self.loadingView)
        
        var frame = self.errorLabel.frame
        frame.size.width = self.frame.size.width

        self.errorLabel.frame = frame
        self.errorLabel.textColor = UIColor.init(white: 80.0 / 255.0, alpha: 1.0)
        self.errorLabel.textAlignment = .center
        self.errorLabel.font = UIFont.systemFont(ofSize: 12.0)
        self.errorLabel.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleRightMargin, .flexibleWidth]
        self.addSubview(self.errorLabel)
        
        frame = self.statusLabel.frame
        frame.size.width = self.frame.size.width
        self.statusLabel.frame = frame
        self.statusLabel.textColor = UIColor.init(white: 80.0 / 255.0, alpha: 1.0)
        self.statusLabel.textAlignment = .center
        self.statusLabel.font = UIFont.systemFont(ofSize: 12.0)
        self.statusLabel.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
        self.addSubview(self.statusLabel)
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(didTapContentView(sender:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc private func didTapContentView(sender: Any?) {
        if let refreshable = self.superview as? RefreshHeaderControl<DefaultRefreshHeaderContentView> {
            refreshable.refreshingBlock?(refreshable)
            self.startLoading()
        }
    }
    
    private func reset() {
        self.loadingView.isHidden = true
        self.successView.isHidden = true
        self.errorLabel.isHidden = true
        self.arrowView.isHidden = true
        self.progressView.isHidden = true
        self.isUserInteractionEnabled = false
    }
    
    private let arrowView = SimpleShapeView.init(frame: CGRect.init(x: 0, y: 0, width: 10, height: 10))
    private let successView = SimpleShapeView.init(frame: CGRect.init(x: 0, y: 0, width: 10, height: 10))
    private let progressView = CircleProgressView.init(frame: CGRect.init(x: 0, y: 0, width: 22, height: 22))
    private let loadingView = CircleLoadingView.init(frame: CGRect.init(x: 0, y: 0, width: 22, height: 22))
    private let errorLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 22))
    private let statusLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 22))
}

extension DefaultRefreshHeaderContentView : AnyRefreshContent {
    open static var preferredHeight: CGFloat {
        return 70.0
    }
    
    open func setProgress(progress: CGFloat) {
        self.reset()
        
        self.arrowView.isHidden = false
        self.progressView.isHidden = false
        
        let progress = max(min(progress, 1), 0)
        
        self.progressView.progress = progress
        if progress == 1 {
            arrowView.subType = .arrowTop
            statusLabel.text = "Release to Refresh"
        } else {
            arrowView.subType = .arrowBottom
            statusLabel.text = "Pull to Refresh"
        }
    }
    
    open func startLoading() {
        self.reset()
        
        self.loadingView.isHidden = false
        self.loadingView.startAnimating()
        self.statusLabel.text = "Loading"
        
    }
    
    open func stopLoading() {
        self.reset()
        loadingView.stopAnimating()
        self.statusLabel.text = nil
    }
    
    open func loadedSuccess() {
        self.reset()
        self.successView.isHidden = false
        self.progressView.isHidden = false
        self.progressView.progress = 1.0
        self.statusLabel.text = "Success"
        self.loadingView.stopAnimating()
        self.successView.beginSimpleAnimation()

    }
    
    open func loadedError(withMsg msg: String) {
        self.reset()
        self.errorLabel.isHidden = false
        self.errorLabel.text = msg
        self.statusLabel.text = "Click to Retry"
        self.loadingView.stopAnimating()
        self.isUserInteractionEnabled = true
    }
}

open class DefaultRefreshFooterContentView : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        
        var frame = self.centerLabel.frame
        frame.size.width = self.frame.size.width
        
        self.centerLabel.frame = frame
        self.centerLabel.textColor = UIColor.init(white: 80.0 / 255.0, alpha: 1.0)
        self.centerLabel.textAlignment = .center
        self.centerLabel.font = UIFont.systemFont(ofSize: 12.0)
        self.centerLabel.autoresizingMask = .flexibleWidth
        self.addSubview(self.centerLabel)
        
        frame = self.errorLabel.frame
        frame.size.width = self.frame.size.width
        
        self.errorLabel.frame = frame
        self.errorLabel.textColor = UIColor.init(white: 80.0 / 255.0, alpha: 1.0)
        self.errorLabel.textAlignment = .center
        self.errorLabel.font = UIFont.systemFont(ofSize: 12.0)
        self.errorLabel.autoresizingMask = .flexibleWidth
        self.addSubview(self.errorLabel)
        
        frame = self.statusLabel.frame
        frame.size.width = self.frame.size.width
        
        self.statusLabel.frame = frame
        self.statusLabel.textColor = UIColor.init(white: 80.0 / 255.0, alpha: 1.0)
        self.statusLabel.textAlignment = .center
        self.statusLabel.font = UIFont.systemFont(ofSize: 12.0)
        self.statusLabel.autoresizingMask = .flexibleWidth
        self.addSubview(self.statusLabel)
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(didTapContentView(sender:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc private func didTapContentView(sender: Any?) {
        if let refreshable = self.superview as? RefreshFooterControl<DefaultRefreshFooterContentView> {
            refreshable.refreshingBlock?(refreshable)
            self.startLoading()
        }
    }
    
    private func reset() {
        self.errorLabel.isHidden = true
        self.centerLabel.isHidden = true
        self.statusLabel.isHidden = true
        self.isUserInteractionEnabled = false
    }
    
    private let centerLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 50))
    private let errorLabel = UILabel.init(frame: CGRect.init(x: 0, y: 8, width: 0, height: 17))
    private let statusLabel = UILabel.init(frame: CGRect.init(x: 0, y: 25, width: 0, height: 17))
}

extension DefaultRefreshFooterContentView : AnyRefreshContent {
    open static var preferredHeight: CGFloat {
        return 50.0
    }
    
    open func startLoading() {
        self.reset()
        self.centerLabel.isHidden = false
        self.centerLabel.text = "Loading"
    }
    
    open func stopLoading() {
        self.reset()
        self.statusLabel.text = nil
    }
    
    open func loadedError(withMsg msg: String) {
        self.reset()
        self.errorLabel.isHidden = false
        self.statusLabel.isHidden = false
        self.errorLabel.text = msg
        self.statusLabel.text = "Click to Retry"
        self.isUserInteractionEnabled = true
    }
    
    open func loadedPause(withMsg msg: String) {
        self.reset()
        self.centerLabel.isHidden = false
        self.centerLabel.text = msg
    }
    
    open func loadedSuccess() {
        self.reset()
    }
}
