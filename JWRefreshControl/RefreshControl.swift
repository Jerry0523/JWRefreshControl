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

open class RefreshHeaderControl<T>: UIView, AnyRefreshContext, RefreshControl, UIGestureRecognizerDelegate where T: AnyRefreshContent & UIView {
    
    public var state = PullRefreshState.idle {
        didSet {
            if state != oldValue {
                updateContentViewByStateChanged()
            }
        }
    }
    
    open var refreshingBlock: ((RefreshHeaderControl<T>) -> ())?
    
    ///called when the pan gesture ended
    open var handleStateByProgressChange: ((RefreshHeaderControl<T>, CGFloat) -> ())?
    
    open let contentView = T(frame: CGRect.zero)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview == nil {
            self.state = .idle
        }
        removeListener()
        guard let scrollView = newSuperview as? UIScrollView else {
            return
        }
        self.scrollView = scrollView
        scrollView.alwaysBounceVertical = true
        addListener()
    }
    
    private func setup() {
        autoresizingMask = .flexibleWidth
        clipsToBounds = true
        layout(contentView: contentView)
        addSubview(contentView)
    }
    
    private func layout(contentView: T) {
        let viewHeight = contentView.intrinsicContentSize.height
        switch T.self.behaviour {
        case .pinnedToEdge:
            contentView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: viewHeight)
            contentView.autoresizingMask = .flexibleWidth
        case .default, .android:
            contentView.frame = CGRect(x: 0, y: frame.size.height - viewHeight, width: self.frame.size.width, height: viewHeight)
            contentView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        }
    }
    
    private func removeListener() {
        removeKVO()
        if let headerPanGesture = headerPanGesture {
            scrollView?.removeGestureRecognizer(headerPanGesture)
        }
    }
    
    private func addListener() {
        registKVO()
        switch T.self.behaviour {
        case .android:
            if headerPanGesture == nil {
                headerPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
                headerPanGesture?.delegate = self
            }
            scrollView?.addGestureRecognizer(headerPanGesture!)
        default:
            guard let panGestureRecognizer = scrollView?.panGestureRecognizer else {
                return
            }
            keyPathObservations.append(
                panGestureRecognizer.observe(\.state, changeHandler: { [weak self] (scrollView, change) in
                    self?.handlePanGestureStateChange()
                })
            )
        }
    }
    
    @objc private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        guard let scrollView = scrollView else {
            return
        }
        let distance = sender.translation(in: scrollView).y
        
        switch sender.state {
        case .changed:
            frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: distance)
            scrollView.bringSubview(toFront: self)
            if state == .idle {
                contentView.setProgress(distance / contentView.intrinsicContentSize.height)
            }
        case .ended:
            handleProgress(distance / contentView.intrinsicContentSize.height)
        default: break
        }
        
    }
    
    private func handlePanGestureStateChange() {
        guard let scrollView = scrollView else {
            return
        }
        
        if scrollView.panGestureRecognizer.state == .ended {
            if state != .idle {
                return
            }
            
            let offsetY = scrollView.jw_draggedHeaderOffsetY
            let progress = offsetY / contentView.intrinsicContentSize.height
            
            handleProgress(progress)
        }
    }
    
    private func handleProgress(_ progress: CGFloat) {
        if let handleStateByProgressChange = handleStateByProgressChange {
            handleStateByProgressChange(self, progress)
        } else {
            if (progress >= 1) {
                state = .refreshing
            } else {
                state = .idle
            }
        }
    }
    
    // MARK: UIGestureRecognizerDelegate
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let scrollView = scrollView, gestureRecognizer == headerPanGesture else {
            return true
        }
        return scrollView.jw_draggedHeaderOffsetY >= 0 && headerPanGesture!.velocity(in: gestureRecognizer.view).y > 0
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == headerPanGesture && otherGestureRecognizer == scrollView?.panGestureRecognizer
    }
    
    // MARK: Private vars
    weak var scrollView: UIScrollView?
    
    var keyPathObservations: [NSKeyValueObservation] = []
    
    var headerPanGesture: UIPanGestureRecognizer?
    
}

open class RefreshFooterControl<T>: UIView , AnyRefreshContext, RefreshControl where T: AnyRefreshContent & UIView {
    
    open var state = PullRefreshState.idle {
        didSet {
            if state != oldValue {
                updateContentViewByStateChanged()
            }
        }
    }
    
    open var refreshingBlock: ((RefreshFooterControl<T>) -> ())?
    
    open var preFetchedDistance: CGFloat = 0
    
    open let contentView = T()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        if newSuperview == nil {
            self.state = .idle
        }
        
        removeKVO()
        
        guard let scrollView = newSuperview as? UIScrollView else {
            return
        }
        contentView.frame = CGRect(x: 0, y: 0, width:scrollView.frame.size.width, height: contentView.intrinsicContentSize.height)
        self.scrollView = scrollView
        scrollView.alwaysBounceVertical = true
        registKVO()
    }
    
    private func setup() {
        autoresizingMask = .flexibleWidth
        clipsToBounds = true
        addSubview(contentView)
        isHidden = true
    }
    
    weak var scrollView: UIScrollView?
    
    var keyPathObservations: [NSKeyValueObservation] = []
    
}

extension RefreshHeaderControl : AnyRefreshObserver {
    
    func scrollViewContentOffsetDidChange() {
        guard let scrollView = scrollView else {
            return
        }
        
        var offsetY = -scrollView.contentOffset.y
        if #available(iOS 11.0, *) {
            offsetY -= (scrollView.adjustedContentInset.top - scrollView.jw_adjustedContentInset.top)
        } else {
            offsetY -= (scrollView.contentInset.top - scrollView.jw_adjustedContentInset.top)
        }
        
        if offsetY >= 0 {
            frame = CGRect(x: 0, y: -offsetY, width: scrollView.frame.size.width, height: offsetY)
            
            if state == .idle {
                contentView.setProgress(frame.size.height / contentView.intrinsicContentSize.height)
            }
        }
        
        if state != .idle {
            var insetsTop = offsetY
            
            if scrollView.isTracking && insetsTop != contentView.intrinsicContentSize.height {
                insetsTop = 0
            }
            
            insetsTop = min(contentView.intrinsicContentSize.height, insetsTop)
            insetsTop = max(0, insetsTop)
            
            if scrollView.jw_adjustedContentInset.top != insetsTop {
                scrollView.layer.removeAllAnimations()
                UIView.animate(withDuration: 0.25, animations: {
                    scrollView.jw_updateHeaderInset(insetsTop)
                })
            }
        }
        
    }
    
    func updateContentViewByStateChanged() {
        guard let scrollView = scrollView else {
            return
        }
        
        let isAndroidTheme = T.self.behaviour == .android
        
        switch state {
        case .idle:
            contentView.stop()
            UIView.animate(withDuration: 0.25, animations: {
                if isAndroidTheme {
                    var frame = self.frame
                    frame.size.height = 0
                    self.frame = frame
                } else {
                    scrollView.jw_updateHeaderInset(0)
                }
            })
        case .refreshing:
            contentView.start()
            UIView.animate(withDuration: 0.25, animations: {
                if isAndroidTheme {
                    var frame = self.frame
                    frame.size.height = self.contentView.intrinsicContentSize.height
                    self.frame = frame
                } else {
                    scrollView.jw_updateHeaderInset(self.contentView.intrinsicContentSize.height)
                }
            }, completion: { (finished) in
                self.refreshingBlock?(self)
                self.scrollView?.refreshFooter?.stop()
            })
        default:
            break
        }
    }
}

extension RefreshFooterControl : AnyRefreshObserver {
    
    func scrollViewContentOffsetDidChange() {
        guard let scrollView = scrollView else {
            return
        }
        var offsetSpace = -preFetchedDistance
        var contentHeight = scrollView.contentSize.height
        if #available(iOS 11.0, *) {
            offsetSpace += scrollView.adjustedContentInset.bottom
            contentHeight += (scrollView.adjustedContentInset.top + scrollView.adjustedContentInset.bottom)
        }
        contentHeight += (scrollView.contentInset.top + scrollView.contentInset.bottom)
        if state != .pause &&
            scrollView.contentSize.height > 0 &&
            contentHeight >= scrollView.frame.size.height &&
            scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentSize.height > offsetSpace {
            state = .refreshing
            if T.self.behaviour == .pinnedToEdge {
                let offsetY = scrollView.contentOffset.y + scrollView.frame.size.height - contentView.intrinsicContentSize.height
                frame = CGRect(x: 0, y: offsetY, width: scrollView.frame.size.width, height: contentView.intrinsicContentSize.height)
            } else {
                frame = CGRect(x: 0, y: scrollView.contentSize.height, width: scrollView.frame.size.width, height: contentView.intrinsicContentSize.height)
            }
        }
    }
    
    public func updateContentViewByStateChanged() {
        guard let scrollView = scrollView else {
            return
        }
        
        switch state {
        case .idle:
            isHidden = true
            contentView.stop()
            scrollView.jw_updateFooterInset(0)
        case .refreshing:
            scrollView.jw_updateFooterInset(contentView.intrinsicContentSize.height)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                self.refreshingBlock?(self)
            })
            isHidden = false
            var contentFrame = contentView.frame
            contentFrame.size.width = scrollView.frame.size.width
            contentView.frame = contentFrame
            contentView.start()
        default:
            break
        }
    }
}
