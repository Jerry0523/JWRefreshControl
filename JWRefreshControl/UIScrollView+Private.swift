//
// UIScrollView+Private.swift
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

extension UIScrollView {
    
    var jw_draggedHeaderSpace: CGFloat {
        get {
            var offsetY = -(contentInset.top + contentOffset.y)
            if #available(iOS 11.0, *) {
                offsetY -= (adjustedContentInset.top - contentInset.top)
            }
            return offsetY
        }
    }
    
    var jw_draggedFooterSpace: CGFloat {
        get {
            return bounds.height - (contentSize.height - contentOffset.y)
        }
    }
    
    var jw_adjustedContentInset: UIEdgeInsets {
        
        get {
            return (objc_getAssociatedObject(self, &UIScrollView.adjustedContentInsetKey) as? UIEdgeInsets) ?? .zero
        }
        
        set {
            let old = jw_adjustedContentInset
            objc_setAssociatedObject(self, &UIScrollView.adjustedContentInsetKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if old.top != newValue.top {
                jw_fixContentInsetsTop(newValue.top - old.top)
            }
            if old.bottom != newValue.bottom {
                jw_fixContentInsetsBottom(newValue.bottom - old.bottom)
            }
        }
    }
    
    func jw_updateHeaderInset(_ val: CGFloat) {
        var jwAdjustedContentInset = self.jw_adjustedContentInset
        jwAdjustedContentInset.top = val
        self.jw_adjustedContentInset = jwAdjustedContentInset
    }
    
    func jw_updateFooterInset(_ val: CGFloat) {
        var jwAdjustedContentInset = self.jw_adjustedContentInset
        jwAdjustedContentInset.bottom = val
        self.jw_adjustedContentInset = jwAdjustedContentInset
    }
    
    private func jw_fixContentInsetsTop(_ offset: CGFloat) {
        var oldInsets = self.contentInset
        oldInsets.top += offset
        self.contentInset = oldInsets
    }
    
    private func jw_fixContentInsetsBottom(_ offset: CGFloat) {
        var oldInsets = self.contentInset
        oldInsets.bottom += offset
        self.contentInset = oldInsets
    }
    
    private static var adjustedContentInsetKey: Void?
}
