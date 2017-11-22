//
// RefreshControl.swift
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

public enum RefreshHeaderInteraction {
    case still
    case follow
    
    fileprivate func update<T>(content: T, context: UIView) where T: UIView & AnyRefreshContent {
        let viewHeight = T.preferredHeight
        switch self {
        case .still:
            content.frame = CGRect.init(x: 0, y: 0, width: context.frame.size.width, height: viewHeight)
            content.autoresizingMask = .flexibleWidth
            
        case .follow:
            content.frame = CGRect.init(x: 0, y: context.frame.size.height - viewHeight, width: context.frame.size.width, height: viewHeight)
            content.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        }
    }
}

public protocol AnyRefreshContext : NSObjectProtocol where ContentType : AnyRefreshContent {
    
    associatedtype ContentType
    
    var contentView: ContentType { get }
    
    var state: PullRefreshState { get set }
}

public protocol RefreshControl {
    
    func startLoading()
    
    func stopLoading()
    
    func loadedSuccess(withDelay: TimeInterval?)
    
    func loadedPause(withMsg msg: String)
    
    func loadedError(withMsg msg: String)
    
}

public extension RefreshControl where Self : AnyRefreshContext {
    
    public func loadedPause(withMsg msg: String) {
        self.contentView.loadedPause?(withMsg: msg)
        self.state = .pause
    }
    
    public func loadedError(withMsg msg: String) {
        self.contentView.loadedError?(withMsg: msg)
        self.state = .pause
    }
    
    public func startLoading() {
        self.state = .refreshing
    }
    
    public func stopLoading() {
        self.state = .idle
    }
    
    public func loadedSuccess(withDelay: TimeInterval? = 0.6) {
        self.contentView.loadedSuccess?()
        DispatchQueue.main.asyncAfter(deadline: .now() + (withDelay ?? 0.6)) {[weak self] in
            self?.state = .idle
        }
    }
}

open class RefreshHeaderControl<T>: UIView, AnyRefreshContext, RefreshControl where T: AnyRefreshContent, T: UIView {
    
    open var style: RefreshHeaderInteraction = .still {
        didSet {
            if style != oldValue {
                style.update(content: self.contentView, context: self)
            }
        }
    }
    
    public var state = PullRefreshState.idle {
        didSet {
            if state != oldValue {
                self.updateContentViewByStateChanged()
            }
        }
    }
    
    open var refreshingBlock: ((RefreshHeaderControl<T>) -> ())?
    
    open let contentView = T.init() //init(frame: CGRect.zero)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        guard let scrollView = newSuperview as? UIScrollView else {
            return
        }
        self.removeKVO()
        self.scrollView = scrollView
        scrollView.alwaysBounceVertical = true
        self.scrollViewOriginalInset = scrollView.contentInset
        self.panGestureRecognizer = scrollView.panGestureRecognizer
        self.registKVO()
    }
    
    private func setup() {
        self.autoresizingMask = .flexibleWidth
        self.clipsToBounds = true
        self.addSubview(self.contentView)
        self.style.update(content: self.contentView, context: self)
    }
    
    private func removeKVO() {
        self.keyPathObservations = []
        self.scrollView = nil
        self.panGestureRecognizer = nil
    }
    
    private func registKVO() {
        guard let scrollView = self.scrollView, let panGestureRecognizer = self.panGestureRecognizer else {
            return
        }
        
        var observations: [NSKeyValueObservation] = []
        observations.append(
            scrollView.observe(\.contentOffset, changeHandler: { [weak self] (scrollView, change) in
                self?.scrollViewContentOffsetDidChange()
            })
        )
        
        observations.append(
            panGestureRecognizer.observe(\.state, changeHandler: { [weak self] (scrollView, change) in
                self?.scrollViewPanGestureStateDidChange()
            })
        )
        self.keyPathObservations = observations
    }
    
    private func scrollViewContentOffsetDidChange() {
        var insets = self.scrollView!.contentInset
        if self.state != .idle {
            insets.top -= self.contentView.frame.size.height
        }
        
        self.scrollViewOriginalInset = insets
        var offsetY = -self.scrollView!.contentOffset.y
        if #available(iOS 11.0, *) {
            offsetY -= (self.scrollView!.adjustedContentInset.top - (self.state != .idle ? T.preferredHeight : 0))
        } else {
            offsetY -= self.scrollViewOriginalInset.top
        }
        
        if offsetY < 0 {
            return
        }
        self.frame = CGRect.init(x: 0, y: -offsetY, width: self.scrollView!.frame.size.width, height: offsetY)
        
        if self.state == .idle {
            self.contentView.setProgress?(progress: self.frame.size.height / self.contentView.frame.size.height)
        }
    }
    
    private func scrollViewPanGestureStateDidChange() {
        if self.scrollView!.panGestureRecognizer.state == .ended {
            if self.state != .idle {
                return
            }
            var offsetY = -(self.scrollView!.contentInset.top + self.scrollView!.contentOffset.y)
            if #available(iOS 11.0, *) {
                offsetY -= (self.scrollView!.adjustedContentInset.top - self.scrollView!.contentInset.top)
            }
            if (offsetY >= self.contentView.frame.size.height) {
                self.state = .refreshing
            } else {
                self.state = .idle
            }
        }
    }
    
    private func updateContentViewByStateChanged() {
        guard let scrollView = self.scrollView else {
            return
        }
        
        switch state {
        case .idle:
            self.contentView.stopLoading?()
            UIView.animate(withDuration: 0.25, animations: {
                scrollView.contentInset = self.scrollViewOriginalInset
            })
            
        case .refreshing:
            self.contentView.startLoading?()
            UIView.animate(withDuration: 0.25, animations: {
                let newInsets = UIEdgeInsets.init(top: self.scrollViewOriginalInset.top + self.contentView.frame.size.height, left: self.scrollViewOriginalInset.left, bottom: self.scrollViewOriginalInset.bottom, right: self.scrollViewOriginalInset.right)
                scrollView.contentInset = newInsets
            }, completion: { (finished) in
                self.refreshingBlock?(self)
                self.scrollView?.refreshFooter?.stopLoading()
            })
        default:
            break
        }
    }
    
    private weak var scrollView: UIScrollView?
    
    private weak var panGestureRecognizer: UIPanGestureRecognizer?
    
    private var scrollViewOriginalInset = UIEdgeInsets.zero
    
    private var keyPathObservations: [NSKeyValueObservation] = []
}

open class RefreshFooterControl<T>: UIView , AnyRefreshContext, RefreshControl where T: AnyRefreshContent, T: UIView {
    
    open var state = PullRefreshState.idle {
        didSet {
            if state != oldValue {
                self.updateContentViewByStateChanged()
            }
        }
    }
    
    open var refreshingBlock: ((RefreshFooterControl<T>) -> ())?
    
    open var preFetchedDistance: CGFloat = 0
    
    open let contentView = T.init()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        guard let scrollView = newSuperview as? UIScrollView else {
            return
        }
        self.contentView.frame = CGRect.init(x: 0, y: 0, width:scrollView.frame.size.width, height: T.preferredHeight)
        self.scrollView = scrollView
        scrollView.alwaysBounceVertical = true
        self.scrollViewContentSize = scrollView.contentSize
        self.registKVO()
    }
    
    private func removeKVO() {
        self.keyPathObservations = []
        self.scrollView = nil
    }
    
    private func registKVO() {
        guard let scrollView = self.scrollView else {
            return
        }
        
        var observations: [NSKeyValueObservation] = []
        observations.append(
            scrollView.observe(\.contentSize, changeHandler: { [weak self] (scrollView, change) in
                self?.scrollViewContentSize = scrollView.contentSize
            })
        )
        
        observations.append(
            scrollView.observe(\.contentOffset, changeHandler: { [weak self] (scrollView, change) in
                self?.scrollViewContentOffsetDidChange()
            })
        )
        self.keyPathObservations = observations
    }
    
    private func setup() {
        self.autoresizingMask = .flexibleWidth
        self.clipsToBounds = true
        self.addSubview(self.contentView)
        self.isHidden = true
    }
    
    private func scrollViewContentOffsetDidChange() {
        guard let scrollView = self.scrollView else {
            return
        }
        var offsetSpace = -self.preFetchedDistance
        if #available(iOS 11.0, *) {
            offsetSpace += scrollView.adjustedContentInset.bottom
        }
        
        if self.state != .pause &&
            scrollView.contentSize.height > 0 &&
            scrollView.contentSize.height >= scrollView.frame.size.height &&
            scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentSize.height > offsetSpace {
            self.state = .refreshing
            self.frame = CGRect.init(x: 0, y: scrollView.contentSize.height, width: scrollView.frame.size.width, height: self.contentView.frame.size.height)
        }
    }
    
    private func updateContentViewByStateChanged() {
        guard let scrollView = self.scrollView else {
            return
        }
        
        switch self.state {
        case .idle:
            self.isHidden = true
            self.contentView.stopLoading?()
            if scrollView.contentInset.bottom >= self.contentView.frame.size.height {
                var oldInsets = scrollView.contentInset
                oldInsets.bottom -= self.contentView.frame.size.height
                scrollView.contentInset = oldInsets
            }
        case .refreshing:
            var oldInsets = scrollView.contentInset
            oldInsets.bottom += self.contentView.frame.size.height
            scrollView.contentInset = oldInsets
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                self.refreshingBlock?(self)
            })
            self.isHidden = false
            var contentFrame = self.contentView.frame
            contentFrame.size.width = scrollView.frame.size.width
            self.contentView.frame = contentFrame
            self.contentView.startLoading?()
        default:
            break
        }
    }
    
    private weak var scrollView: UIScrollView?
    
    private var scrollViewContentSize = CGSize.zero {
        didSet {
            if scrollViewContentSize != oldValue && self.state != .refreshing {
                self.frame = CGRect.init(x: 0, y: scrollViewContentSize.height, width: self.scrollView?.frame.size.width ?? 0, height: self.contentView.frame.size.height)
            }
        }
    }
    
    private var keyPathObservations: [NSKeyValueObservation] = []
    
}
