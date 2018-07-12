//
// UIScrollView+PullRefresh.swift
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

public extension UIScrollView {
    
    ///The refresh header. Setting a nil value will remove the current refresh header.
    public var refreshHeader: RefreshControl? {
        get {
            return objc_getAssociatedObject(self, &UIScrollView.refreshHeaderKey) as? RefreshControl
        }
        
        set {
            removeRefreshHeader()
            if let refreshView = newValue as? UIView {
                insertSubview(refreshView, at: 0)
            }
            objc_setAssociatedObject(self, &UIScrollView.refreshHeaderKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    ///The refresh footer. Setting a nil value will remove the current refresh footer.
    public var refreshFooter: RefreshControl? {
        get {
            return objc_getAssociatedObject(self, &UIScrollView.refreshFooterKey) as? RefreshControl
        }
        
        set {
            removeRefreshFooter()
            if let refreshView = newValue as? UIView {
                insertSubview(refreshView, at: 0)
            }
            objc_setAssociatedObject(self, &UIScrollView.refreshFooterKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    ///Add a default refresh header.
    @discardableResult
    public func addRefreshHeader(callBack: @escaping (RefreshHeaderControl<DefaultRefreshHeaderContentView>) -> ()) -> RefreshHeaderControl<DefaultRefreshHeaderContentView> {
        return addCustomRefreshHeader(callBack: callBack)
    }
    
    ///Add a default refresh footer.
    @discardableResult
    public func addRefreshFooter(callBack: @escaping (RefreshFooterControl<DefaultRefreshFooterContentView>) -> ()) -> RefreshFooterControl<DefaultRefreshFooterContentView>{
        return addCustomRefreshFooter(callBack: callBack)
    }
   
    ///Add a custome refresh header. Custom content view should be provided.
    @discardableResult
    public func addCustomRefreshHeader<T>(callBack: @escaping (RefreshHeaderControl<T>) -> ()) -> RefreshHeaderControl<T> {
        let headerControl = RefreshHeaderControl<T>.init(frame: CGRect.init(x: 0, y: 0, width: frame.size.width, height: 0))
        headerControl.refreshingBlock = callBack
        refreshHeader = headerControl
        return headerControl
    }
    
    ///Add a custome refresh footer. Custom content view should be provided.
    @discardableResult
    public func addCustomRefreshFooter<T>(callBack: @escaping (RefreshFooterControl<T>) -> ()) -> RefreshFooterControl<T> {
        let footerControl = RefreshFooterControl<T>.init(frame: CGRect.init(x: 0, y: 0, width: frame.size.width, height: 0))
        footerControl.refreshingBlock = callBack
        refreshFooter = footerControl
        return footerControl
    }
    
    ///Remove the current refresh header.
    public func removeRefreshHeader() {
        let headerControl = refreshHeader
        headerControl?.stop()
        if let refreshView = headerControl as? UIView {
            refreshView.removeFromSuperview()
        }
        objc_setAssociatedObject(self, &UIScrollView.refreshHeaderKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    ///Remove the current refresh footer.
    public func removeRefreshFooter() {
        let footerControl = refreshFooter
        footerControl?.stop()
        if let refreshView = footerControl as? UIView {
            refreshView.removeFromSuperview()
        }
        objc_setAssociatedObject(self, &UIScrollView.refreshFooterKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private static var refreshHeaderKey: Void?
    private static var refreshFooterKey: Void?
}
