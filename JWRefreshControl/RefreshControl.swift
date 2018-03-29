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

open class RefreshHeaderControl<T>: UIView, AnyRefreshContext, RefreshControl where T: AnyRefreshContent & UIView {
    
    public var state = PullRefreshState.idle {
        didSet {
            if state != oldValue {
                updateContentViewByStateChanged()
            }
        }
    }
    
    open var refreshingBlock: ((RefreshHeaderControl<T>) -> ())?
    
    open let contentView = T() //(frame: CGRect.zero)
    
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
        
        self.scrollView = scrollView
        scrollView.alwaysBounceVertical = true
        registKVO()
        let panGestureRecognizer = scrollView.panGestureRecognizer
        keyPathObservations.append(
            panGestureRecognizer.observe(\.state, changeHandler: { [weak self] (scrollView, change) in
                self?.scrollViewPanGestureStateDidChange()
            })
        )
    }
    
    private func setup() {
        autoresizingMask = .flexibleWidth
        clipsToBounds = true
        layout(contentView: contentView)
        addSubview(contentView)
    }
    
    private func layout(contentView: T) {
        let viewHeight = T.preferredHeight
        if T.self.isPinnedToEdge ?? false {
            contentView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: viewHeight)
            contentView.autoresizingMask = .flexibleWidth
        } else {
            contentView.frame = CGRect(x: 0, y: self.frame.size.height - viewHeight, width: self.frame.size.width, height: viewHeight)
            contentView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        }
    }
    
    private func scrollViewPanGestureStateDidChange() {
        guard let scrollView = scrollView else {
            return
        }
        if scrollView.panGestureRecognizer.state == .ended {
            if state != .idle {
                return
            }
            var offsetY = -(scrollView.contentInset.top + scrollView.contentOffset.y)
            if #available(iOS 11.0, *) {
                offsetY -= (scrollView.adjustedContentInset.top - scrollView.contentInset.top)
            }
            if (offsetY >= T.preferredHeight) {
                state = .refreshing
            } else {
                state = .idle
            }
        }
    }
    
    weak var scrollView: UIScrollView?
    
    var keyPathObservations: [NSKeyValueObservation] = []
    
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
        contentView.frame = CGRect(x: 0, y: 0, width:scrollView.frame.size.width, height: T.preferredHeight)
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
                contentView.setProgress?(frame.size.height / T.preferredHeight)
            }
        }
        
        if state != .idle {
            var insetsTop = offsetY
            
            if scrollView.isTracking && insetsTop != T.preferredHeight {
                insetsTop = 0
            }
            
            insetsTop = min(T.preferredHeight, insetsTop)
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
        
        switch state {
        case .idle:
            contentView.stop?()
            UIView.animate(withDuration: 0.25, animations: {
                scrollView.jw_updateHeaderInset(0)
            })
            
        case .refreshing:
            contentView.start?()
            UIView.animate(withDuration: 0.25, animations: {
                scrollView.jw_updateHeaderInset(T.preferredHeight)
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
            if T.self.isPinnedToEdge ?? false {
                let offsetY = scrollView.contentOffset.y + scrollView.frame.size.height - T.preferredHeight
                frame = CGRect(x: 0, y: offsetY, width: scrollView.frame.size.width, height: T.preferredHeight)
            } else {
                frame = CGRect(x: 0, y: scrollView.contentSize.height, width: scrollView.frame.size.width, height: T.preferredHeight)
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
            contentView.stop?()
            scrollView.jw_updateFooterInset(0)
        case .refreshing:
            scrollView.jw_updateFooterInset(T.preferredHeight)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                self.refreshingBlock?(self)
            })
            isHidden = false
            var contentFrame = contentView.frame
            contentFrame.size.width = scrollView.frame.size.width
            contentView.frame = contentFrame
            contentView.start?()
        default:
            break
        }
    }
}
