//
// RefreshFooterControl.swift
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

open class RefreshFooterControl<T>: UIView , AnyRefreshContext, RefreshControl, UIGestureRecognizerDelegate where T: AnyRefreshContent & UIView {
    
    public var isEnabled = true {
        didSet {
            if !isEnabled {
                self.state = .idle
            }
        }
    }
    
    open var state = PullRefreshState.idle {
        didSet {
            if state != oldValue {
                updateContentViewByStateChanged()
            }
        }
    }
    
    open var refreshingBlock: ((RefreshFooterControl<T>) -> ())?
    
    open var preFetchedDistance: CGFloat = 0
    
    public let contentView = T()
    
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
        contentView.frame = CGRect(x: 0, y: 0, width:scrollView.frame.size.width, height: contentView.intrinsicContentSize.height)
        self.scrollView = scrollView
        scrollView.alwaysBounceVertical = true
        addListener()
    }
    
    private func setup() {
        autoresizingMask = .flexibleWidth
        clipsToBounds = true
        addSubview(contentView)
        isHidden = true
    }
    
    private func removeListener() {
        removeKVO()
        if let footerPanGesture = footerPanGesture {
            scrollView?.removeGestureRecognizer(footerPanGesture)
        }
    }
    
    private func addListener() {
        guard let scrollView = scrollView else {
            return
        }
        registKVO()
        if case .transfer = T.self.behaviour {
            if footerPanGesture == nil {
                footerPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleAndroidThemePanGesture(_:)))
                footerPanGesture?.delegate = self
            }
            scrollView.addGestureRecognizer(footerPanGesture!)
            scrollView.panGestureRecognizer.require(toFail: footerPanGesture!)
        }
    }
    
    @objc private func handleAndroidThemePanGesture(_ sender: UIPanGestureRecognizer) {
        guard let scrollView = scrollView, isEnabled, state == .idle else {
            return
        }
        isHidden = false
        let distance = -sender.translation(in: scrollView).y
        let contentViewHeight = contentView.intrinsicContentSize.height
        switch sender.state {
        case .changed:
            frame = CGRect(x: 0, y: scrollView.contentSize.height - distance, width: scrollView.frame.size.width, height: contentViewHeight)
            scrollView.bringSubviewToFront(self)
            if state == .idle {
                contentView.setProgress(distance / contentViewHeight)
            }
        case .ended:
            let progress = distance / contentView.intrinsicContentSize.height
            if (progress >= 1) {
                state = .refreshing
            } else {
                if state == .idle {
                    updateContentViewByStateChanged()
                } else {
                    state = .idle
                }
            }
        default: break
        }
    }
    
    // MARK: UIGestureRecognizerDelegate
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let scrollView = scrollView, isEnabled,let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else {
            return true
        }
        return scrollView.jw_draggedFooterSpace >= 0 && gestureRecognizer.velocity(in: gestureRecognizer.view).y < 0
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == footerPanGesture && otherGestureRecognizer == scrollView?.panGestureRecognizer
    }
    
    weak var scrollView: UIScrollView?
    
    var keyPathObservations: [NSKeyValueObservation] = []
    
    var footerPanGesture: UIPanGestureRecognizer?
    
}

extension RefreshFooterControl {
    
    func registKVO() {
        guard let scrollView = scrollView else {
            return
        }
        
        keyPathObservations = [
            scrollView.observe(\.contentOffset, changeHandler: { [weak self] (scrollView, change) in
                self?.scrollViewContentOffsetDidChange()
            })
        ]
    }
    
    func removeKVO() {
        scrollView = nil
        keyPathObservations = []
    }
    
    func scrollViewContentOffsetDidChange() {
        guard let scrollView = scrollView, isEnabled, T.self.behaviour != .transfer else {
            return
        }
        var offsetSpace = -preFetchedDistance
        var contentHeight = scrollView.contentSize.height
        if #available(iOS 11.0, *) {
            offsetSpace += scrollView.adjustedContentInset.bottom
            contentHeight += (scrollView.adjustedContentInset.top + scrollView.adjustedContentInset.bottom)
        }
        contentHeight += (scrollView.contentInset.top + scrollView.contentInset.bottom)
        if state == .pause && T.self.behaviour == .pinnedToEdge {
            let contentHeight = contentView.intrinsicContentSize.height
            let offsetY = scrollView.contentSize.height + max(scrollView.jw_draggedFooterSpace - contentHeight, 0)
            frame = CGRect(x: 0, y: offsetY, width: scrollView.frame.size.width, height: contentHeight)
        } else if state != .pause &&
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
        
        let isAndroidTheme = T.self.behaviour == .transfer
        
        switch state {
        case .idle:
            if isAndroidTheme {
                UIView.animate(withDuration: 0.25, animations: {
                    var frame = self.frame
                    frame.origin.y = scrollView.contentSize.height
                    self.frame = frame
                }) { _ in
                    self.contentView.stop()
                    self.isHidden = true
                }
            } else {
                isHidden = true
                contentView.stop()
                scrollView.jw_updateFooterInset(0)
            }
        case .refreshing:
            if !isAndroidTheme {
                scrollView.jw_updateFooterInset(contentView.intrinsicContentSize.height)
            } else {
                UIView.animate(withDuration: 0.25) {
                    var frame = self.frame
                    frame.origin.y = scrollView.contentSize.height - frame.size.height
                    self.frame = frame
                }
            }
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

