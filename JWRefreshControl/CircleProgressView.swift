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

open class CircleProgressView: UIView {
    
    public enum CircleProgressStyle {
        
        case `default`
        
        case pie
    }
    
    open var progress: CGFloat = 0 {
        didSet {
            if progress == oldValue {
                return
            }
            if style == .default {
                if clockWise {
                    circleLayer.strokeEnd = progress
                } else {
                    circleLayer.strokeStart = progress
                    circleLayer.strokeEnd = 1.0
                }
            } else {
                let pathAnimation = CABasicAnimation(keyPath: "path")
                pathAnimation.fromValue = circleLayer.path
                setupShape()
                pathAnimation.toValue = circleLayer.path
                circleLayer.add(pathAnimation, forKey: nil)
            }
        }
    }
    
    open var style: CircleProgressStyle = .default {
        didSet {
            if style != oldValue {
                setupLayerStyle()
                setupLayerColor()
            }
        }
    }
    
    open var lineWidth: CGFloat = 0 {
        didSet {
            if lineWidth != oldValue {
                circleLayer.lineWidth = lineWidth
                backgroundLayer.lineWidth = lineWidth
            }
        }
    }
    
    open var drawBackground = true {
        didSet {
            if drawBackground != oldValue {
                if drawBackground {
                    setupBackgroundShape()
                    layer.insertSublayer(backgroundLayer, below: circleLayer)
                } else {
                    backgroundLayer.removeFromSuperlayer()
                }
            }
        }
    }
    
    open var clockWise = true
    
    open var backgroundTintColor = UIColor(white: 23.0 / 255.0, alpha: 1.0) {
        didSet {
            if backgroundLayer != oldValue {
                backgroundLayer.strokeColor = backgroundTintColor.cgColor
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        setupShape()
        if drawBackground {
            setupBackgroundShape()
        }
    }
    
    open override func tintColorDidChange() {
        super.tintColorDidChange()
        setupLayerColor()
    }
    
    private func setup() {
        layer.addSublayer(circleLayer)
        layer.insertSublayer(backgroundLayer, below: circleLayer)
        backgroundLayer.strokeColor = backgroundTintColor.cgColor
        setupLayerStyle()
        setupLayerColor()
    }
    
    private func setupLayerColor() {
        if style == .default {
            circleLayer.fillColor = UIColor.clear.cgColor
            circleLayer.strokeColor = tintColor.cgColor
        } else if style == .pie {
            circleLayer.fillColor = tintColor.cgColor
            circleLayer.strokeColor = UIColor.clear.cgColor
        }
    }
    
    private func setupLayerStyle() {
        if style == .default {
            circleLayer.lineCap = kCALineCapRound
            circleLayer.strokeStart = 0
            if clockWise {
                circleLayer.strokeEnd = 0
            } else {
                circleLayer.strokeEnd = 1.0
            }
            lineWidth = 4.0
        } else if style == .pie {
            lineWidth = 1.0
        }
    }
    
    private func setupShape() {
        circleLayer.frame = bounds
        let path = CGMutablePath()
        if style == .pie {
            path.move(to: CGPoint(x: frame.size.width * 0.5, y: frame.size.height * 0.5))
        }
        let circleProgress = style == .pie ? progress : 1.0
        var radius = (min(frame.size.width, frame.size.height) - circleLayer.lineWidth) * 0.5
        if style == .pie {
            radius -= 2.0
        }
        path.addArc(center: CGPoint(x: frame.size.width * 0.5, y: frame.size.height * 0.5), radius: radius, startAngle: CGFloat(-Double.pi / 2), endAngle: CGFloat(-Double.pi / 2 + Double.pi * 2 * Double(circleProgress)), clockwise: false)
        circleLayer.path = path
    }
    
    private func setupBackgroundShape() {
        backgroundLayer.frame = bounds
        let path = CGMutablePath()
        if style == .pie {
            path.move(to: CGPoint(x: frame.size.width * 0.5, y: frame.size.height * 0.5))
        }
        var radius = (min(frame.size.width, frame.size.height) - circleLayer.lineWidth) * 0.5
        if style == .pie {
            radius -= 2.0
        }
        path.addArc(center: CGPoint(x: frame.size.width * 0.5, y: frame.size.height * 0.5), radius: radius, startAngle: CGFloat(-Double.pi / 2), endAngle: CGFloat(-Double.pi / 2 + Double.pi * 2), clockwise: false)
        backgroundLayer.path = path
    }
    
    private let circleLayer = CAShapeLayer()
    
    private let backgroundLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }()
}
