//
// Protocols.swift
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

public protocol RefreshControl {
    
    func startLoading()
    
    func stopLoading()
    
    func loadedSuccess(withDelay: TimeInterval?)
    
    func loadedPause(withMsg msg: String)
    
    func loadedError(withMsg msg: String)
    
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

public enum PullRefreshState {
    
    case idle
    
    case refreshing
    
    case pause
    
}

public protocol AnyRefreshContext : class where ContentType : AnyRefreshContent {
    
    associatedtype ContentType
    
    var contentView: ContentType { get }
    
    var state: PullRefreshState { get set }
    
}

public extension RefreshControl where Self : AnyRefreshContext {
    
    public func loadedPause(withMsg msg: String) {
        contentView.loadedPause?(withMsg: msg)
        state = .pause
    }
    
    public func loadedError(withMsg msg: String) {
        contentView.loadedError?(withMsg: msg)
        state = .pause
    }
    
    public func startLoading() {
        state = .refreshing
    }
    
    public func stopLoading() {
        state = .idle
    }
    
    public func loadedSuccess(withDelay: TimeInterval? = 0.6) {
        contentView.loadedSuccess?()
        DispatchQueue.main.asyncAfter(deadline: .now() + (withDelay ?? 0.6)) {[weak self] in
            self?.state = .idle
        }
    }
}

protocol AnyRefreshObserver : class {
    
    weak var scrollView: UIScrollView? { get set }
    
    var keyPathObservations: [NSKeyValueObservation] { get set }
    
    func registKVO()
    
    func removeKVO()
    
    func scrollViewContentOffsetDidChange()
    
    func updateContentViewByStateChanged()
    
}

extension AnyRefreshObserver {
    
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
}
