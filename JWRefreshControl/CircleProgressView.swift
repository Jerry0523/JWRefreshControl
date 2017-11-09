//
// CircleProgressView.swift
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

public enum CircleProgressStyle {
    case `default`
    case pie
}

open class CircleProgressView: UIView {
    
    open var progress: CGFloat = 0 {
        didSet {
            if progress == oldValue {
                return
            }
            if self.style == .default {
                if self.clockWise {
                    self.circleLayer.strokeEnd = progress
                } else {
                    self.circleLayer.strokeStart = progress
                    self.circleLayer.strokeEnd = 1.0
                }
            } else {
                let pathAnimation = CABasicAnimation.init(keyPath: "path")
                pathAnimation.fromValue = self.circleLayer.path
                self.setupShape()
                pathAnimation.toValue = self.circleLayer.path
                self.circleLayer.add(pathAnimation, forKey: nil)
            }
        }
    }
    
    open var style: CircleProgressStyle = .default {
        didSet {
            if style != oldValue {
                self.setupLayerStyle()
                self.setupLayerColor()
            }
        }
    }
    
    open var lineWidth: CGFloat = 0 {
        didSet {
            if lineWidth != oldValue {
                self.circleLayer.lineWidth = lineWidth
                self.backgroundLayer.lineWidth = lineWidth
            }
        }
    }
    
    open var drawBackground = true {
        didSet {
            if drawBackground != oldValue {
                if drawBackground {
                    self.setupBackgroundShape()
                    self.layer.insertSublayer(self.backgroundLayer, below: self.circleLayer)
                } else {
                    self.backgroundLayer.removeFromSuperlayer()
                }
            }
        }
    }
    
    open var clockWise = true
    
    open var backgroundTintColor = UIColor.init(white: 23.0 / 255.0, alpha: 1.0) {
        didSet {
            if backgroundLayer != oldValue {
                self.backgroundLayer.strokeColor = backgroundTintColor.cgColor
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.setupShape()
        if self.drawBackground {
            self.setupBackgroundShape()
        }
    }
    
    open override func tintColorDidChange() {
        super.tintColorDidChange()
        self.setupLayerColor()
    }
    
    private func setup() {
        self.layer.addSublayer(self.circleLayer)
        self.layer.insertSublayer(self.backgroundLayer, below: self.circleLayer)
        self.backgroundLayer.strokeColor = self.backgroundTintColor.cgColor
        self.setupLayerStyle()
        self.setupLayerColor()
    }
    
    private func setupLayerColor() {
        if self.style == .default {
            self.circleLayer.fillColor = UIColor.clear.cgColor
            self.circleLayer.strokeColor = self.tintColor.cgColor
        } else if self.style == .pie {
            self.circleLayer.fillColor = self.tintColor.cgColor
            self.circleLayer.strokeColor = UIColor.clear.cgColor
        }
    }
    
    private func setupLayerStyle() {
        if self.style == .default {
            self.circleLayer.lineCap = kCALineCapRound
            self.circleLayer.strokeStart = 0
            if self.clockWise {
                self.circleLayer.strokeEnd = 0
            } else {
                self.circleLayer.strokeEnd = 1.0
            }
            self.lineWidth = 4.0
        } else if self.style == .pie {
            self.lineWidth = 1.0
        }
    }
    
    private func setupShape() {
        self.circleLayer.frame = self.bounds
        let path = CGMutablePath.init()
        if self.style == .pie {
            path.move(to: CGPoint.init(x: self.frame.size.width * 0.5, y: self.frame.size.height * 0.5))
        }
        let circleProgress = self.style == .pie ? self.progress : 1.0
        var radius = (min(self.frame.size.width, self.frame.size.height) - self.circleLayer.lineWidth) * 0.5
        if self.style == .pie {
            radius -= 2.0
        }
        path.addArc(center: CGPoint.init(x: self.frame.size.width * 0.5, y: self.frame.size.height * 0.5), radius: radius, startAngle: CGFloat(-Double.pi / 2), endAngle: CGFloat(-Double.pi / 2 + Double.pi * 2 * Double(circleProgress)), clockwise: false)
        self.circleLayer.path = path
    }
    
    private func setupBackgroundShape() {
        self.backgroundLayer.frame = self.bounds
        let path = CGMutablePath.init()
        if self.style == .pie {
            path.move(to: CGPoint.init(x: self.frame.size.width * 0.5, y: self.frame.size.height * 0.5))
        }
        var radius = (min(self.frame.size.width, self.frame.size.height) - self.circleLayer.lineWidth) * 0.5
        if self.style == .pie {
            radius -= 2.0
        }
        path.addArc(center: CGPoint.init(x: self.frame.size.width * 0.5, y: self.frame.size.height * 0.5), radius: radius, startAngle: CGFloat(-Double.pi / 2), endAngle: CGFloat(-Double.pi / 2 + Double.pi * 2), clockwise: false)
        self.backgroundLayer.path = path
    }
    
    private let circleLayer = CAShapeLayer()
    
    private let backgroundLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }()
}
