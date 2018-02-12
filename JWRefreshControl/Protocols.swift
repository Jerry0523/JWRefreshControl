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

/// A type that any contentView of the refresh control (header or footer) should conform to
@objc public protocol AnyRefreshContent {
    
    ///The preferred height of the content view
    static var preferredHeight: CGFloat { get }
    
    ///Whether the content view should pin to the edge
    ///e.g. when the content view is on a refresh header, and isPinnedToEdge set to true, the content view will pin to the top of the scrollView without scrolling
    @objc optional static var isPinnedToEdge: Bool { get }
    
    ///When the refresh actions are beging triggered
    @objc optional func setProgress(progress: CGFloat)
    
    ///When the refresh control is beginning to load
    @objc optional func startLoading()
    
    ///When the refresh control is stopped
    @objc optional func stopLoading()
    
    ///When the refresh control loaded successfully
    @objc optional func loadedSuccess()
    
    ///When an error occurred
    @objc optional func loadedError(withMsg msg: String)
    
    ///When the refresh control is paused
    ///Paused means that the scrollView keeps the state of refreshing (e.g. contentInset), but with no more listening to the refresh actions
    @objc optional func loadedPause(withMsg msg: String)
    
}

public enum PullRefreshState {
    
    ///The default state, do nothing and listen to the scrollview state change
    case idle
    
    ///The refreshing state, which will change the scrollView's contentInset and call the refreshing closures
    case refreshing
    
    //The paused state, which will keeps the scrollView's refreshing state (e.g. contentInset) and stop listening to the actions
    case pause
    
}

public protocol AnyRefreshContext : class where ContentType : AnyRefreshContent {
    
    associatedtype ContentType
    
    var contentView: ContentType { get }
    
    var state: PullRefreshState { get set }
    
}

protocol AnyRefreshObserver : class {
    
    weak var scrollView: UIScrollView? { get set }
    
    var keyPathObservations: [NSKeyValueObservation] { get set }
    
    func registKVO()
    
    func removeKVO()
    
    func scrollViewContentOffsetDidChange()
    
    func updateContentViewByStateChanged()
    
}

extension RefreshControl where Self : AnyRefreshContext {
    
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

extension RefreshControl where Self : AnyRefreshObserver {
    
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
