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
    
    var isEnabled: Bool { get set }
    
    ///Notify the refresh control to start
    func start()
    
    ///Notify the refresh control to stop
    func stop()
    
    ///Notify the refresh control to succeed
    func success(withDelay: TimeInterval?)
    
    ///Notify the refresh control to pause
    ///which means that the scrollView keeps the state of refreshing (e.g. contentInset), but with no more listening to refresh actions
    func pause(_ msg: String)
    
    ///Notify the refresh control to fail
    func error(_ msg: String)
    
}

///A type that indicates the contentView's behaviour.
public enum RefreshContentBehaviour {
    
    ///Scroll along with the scrollView
    case scroll
    
    ///A vaule indicates whether the content view should be pined to the edge
    ///e.g. when the content view is on a refresh header, and isPinnedToEdge set to true, the content view will be pined to the top of the scrollView without scrolling
    case pinnedToEdge
    
    ///Keep the scrollView still and move the content view. Like in android.
    case transfer
    
}

/// A type that any contentView of the refresh control (header or footer) should conform to
public protocol AnyRefreshContent {
    
    static var behaviour: RefreshContentBehaviour { get }
    
    ///Called when the refresh actions are beging triggered
    func setProgress(_ progress: CGFloat)
    
    ///Called when the refresh control is beginning to load
    func start()
    
    ///Called when the refresh control is stopped
    func stop()
    
    ///Called when the refresh control loaded successfully
    func success()
    
    ///Called when an error occurred
    func error(_ msg: String)
    
    ///Called when the refresh control is paused
    ///which means that the scrollView keeps the state of refreshing (e.g. contentInset), but with no more listening to the refresh actions
    func pause(_ msg: String)
    
}

public enum PullRefreshState {
    
    ///The default state, do nothing and listen to the scrollview state change
    case idle
    
    ///The refreshing state, which will change the scrollView's contentInset and call the refreshing closures
    case refreshing
    
    //The paused state, which will keeps the scrollView's refreshing state (e.g. contentInset) with no listening to actions
    case pause
    
}

public protocol AnyRefreshContext : AnyObject where ContentType : AnyRefreshContent {
    
    associatedtype ContentType
    
    var contentView: ContentType { get }
    
    var state: PullRefreshState { get set }
    
}

protocol AnyRefreshObserver : AnyObject {
    
    var scrollView: UIScrollView? { get set }
    
    var keyPathObservations: [NSKeyValueObservation] { get set }
    
    func registKVO()
    
    func removeKVO()
    
    func scrollViewContentOffsetDidChange()
    
    func updateContentViewByStateChanged()
    
}

///default imp for AnyRefreshContent provided
extension AnyRefreshContent {
    
    public static var behaviour: RefreshContentBehaviour {
        return RefreshContentBehaviour.scroll
    }
    
    public func success() {}
    
    public func error(_ msg: String) {}
    
    public func pause(_ msg: String) {}
    
    public func setProgress(_ progress: CGFloat) {}
}

public extension RefreshControl where Self : AnyRefreshContext {
    
    func pause(_ msg: String) {
        contentView.pause(_: msg)
        state = .pause
    }
    
    func error(_ msg: String) {
        contentView.error(_: msg)
        state = .pause
    }
    
    func start() {
        state = .refreshing
    }
    
    func stop() {
        state = .idle
    }
    
    func success(withDelay: TimeInterval? = 0.6) {
        contentView.success()
        DispatchQueue.main.asyncAfter(deadline: .now() + (withDelay ?? 0.6)) {[weak self] in
            self?.state = .idle
        }
    }
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
