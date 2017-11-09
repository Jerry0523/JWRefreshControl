//
// CircleLoadingView.swift
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

public enum CircleLoadingStyle {
    case `default`
    case cumulative
    case gradient
}

open class CircleLoadingView: UIView {
    open private(set) var isAnimating = false {
        didSet {
            self.isHidden = !isAnimating
        }
    }
    
    open var style = CircleLoadingStyle.default {
        didSet {
            if style != oldValue {
                self.updateLayerStyle()
            }
        }
    }
    
    open var lineWidth: CGFloat = 3.0 {
        didSet {
            if lineWidth != oldValue {
                self.circleLayer.lineWidth = lineWidth
                self.layoutLayers()
            }
        }
    }
    
    open var drawBackground = true {
        didSet {
            if drawBackground != oldValue {
               self.setNeedsDisplay()
            }
        }
    }
    
    open func startAnimating() {
        if self.isAnimating {
            return
        }
        
        self.isAnimating = true
        let duration = 1.5
        if self.style == .cumulative {
            let strokeStartAnimation = CAKeyframeAnimation.init(keyPath: "strokeStart")
            strokeStartAnimation.duration = duration
            strokeStartAnimation.values = [0, 0.2, 1.0]
            strokeStartAnimation.keyTimes = [0, 0.5, 1.0]
            let strokeEndAnimation = CAKeyframeAnimation.init(keyPath: "strokeEnd")
            strokeEndAnimation.duration = duration
            strokeEndAnimation.values = [0, 0.9, 1.0]
            strokeEndAnimation.keyTimes = [0, 0.5, 1.0]
            let groupAnimation = CAAnimationGroup.init()
            groupAnimation.animations = [strokeStartAnimation, strokeEndAnimation]
            groupAnimation.duration = duration
            groupAnimation.repeatCount = Float.infinity
            self.circleLayer.add(groupAnimation, forKey: CircleLoadingView.animationKey)
        } else if self.style == .default {
            let rotationAnimation = CABasicAnimation.init(keyPath: "transform.rotation.z")
            rotationAnimation.toValue = Float(Double.pi * 2)
            rotationAnimation.duration = duration
            rotationAnimation.isCumulative = true
            rotationAnimation.repeatCount = Float.infinity
            self.circleLayer.add(rotationAnimation, forKey: CircleLoadingView.animationKey)
        } else if self.style ==  .gradient {
            let rotationAnimation = CABasicAnimation.init(keyPath: "transform.rotation.z")
            rotationAnimation.toValue = Float(Double.pi * 2.0)
            rotationAnimation.duration = duration
            rotationAnimation.isCumulative = true
            rotationAnimation.repeatCount = Float.infinity
            self.gradientLayer?.add(rotationAnimation, forKey: CircleLoadingView.animationKey)
        }
    }
    
    open func stopAnimating() {
        self.circleLayer.removeAllAnimations()
        self.isAnimating = false
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
    
    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow != nil && self.isAnimating {
            let simpleAnimation = self.circleLayer.animation(forKey: CircleLoadingView.animationKey)
            if simpleAnimation == nil {
                self.isAnimating = false
                self.startAnimating()
            }
        }
    }
    
    open override func tintColorDidChange() {
        super.tintColorDidChange()
        self.circleLayer.strokeColor = self.tintColor.cgColor
        if self.gradientLayer != nil {
            self.updateGradientLayerColor()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutLayers()
    }
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        if self.drawBackground && self.style != .gradient {
            let context = UIGraphicsGetCurrentContext()
            context?.setLineWidth(self.lineWidth)
            context?.setStrokeColor(self.tintColor.withAlphaComponent(0.2).cgColor)
            context?.beginPath()
            if self.circleLayer.path != nil {
                context?.addPath(self.circleLayer.path!)
            }
            context?.strokePath()
        }
    }
    
    private func layoutLayers() {
        self.circleLayer.frame = self.bounds;
        
        let path = CGMutablePath()
        
        let radius = (min(self.frame.size.width, self.frame.size.height) - self.circleLayer.lineWidth) * 0.5
        path.addArc(center:CGPoint.init(x: self.frame.size.width * 0.5, y: self.frame.size.height * 0.5), radius: radius, startAngle: CGFloat(-Double.pi / 2), endAngle: CGFloat(-Double.pi / 2 + Double.pi * 2), clockwise: false)
        self.circleLayer.path = path;
        
        if let gradientLayer = self.gradientLayer {
            gradientLayer.frame = self.bounds
            let g0 = gradientLayer.sublayers?.first as? CAGradientLayer
            let g1 = gradientLayer.sublayers?.last as? CAGradientLayer
            g0?.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width * 0.5, height: self.frame.size.height)
            g1?.frame = CGRect.init(x: self.frame.size.width * 0.5, y: 0, width: self.frame.size.width * 0.5, height: self.frame.size.height)
            gradientLayer.mask = self.circleLayer
        }
    }
    
    private func updateGradientLayerColor() {
        guard let gradientLayer = self.gradientLayer else {
            return
        }
        let g0 = gradientLayer.sublayers?.first as? CAGradientLayer
        let g1 = gradientLayer.sublayers?.last as? CAGradientLayer
        
        g0?.colors = [self.tintColor.withAlphaComponent(0.5).cgColor, self.tintColor.withAlphaComponent(0.15).cgColor]
        g0?.startPoint = CGPoint.init(x: 1.0, y: 1.0)
        g0?.endPoint = CGPoint.init(x: 1.0, y: 0.0)
        
        g1?.colors = [self.tintColor.withAlphaComponent(0.5).cgColor, self.tintColor.cgColor]
        g1?.startPoint = CGPoint.init(x: 1.0, y: 1.0)
        g1?.endPoint = CGPoint.init(x: 1.0, y: 0.0)
        
    }
    
    private func updateLayerStyle() {
        switch self.style {
        case .gradient:
            if self.gradientLayer == nil {
                let gradientLayer = CALayer.init()
                gradientLayer.mask = self.circleLayer
                
                let g0 = CAGradientLayer.init()
                let g1 = CAGradientLayer.init()
                
                gradientLayer.addSublayer(g0)
                gradientLayer.addSublayer(g1)
                
                self.gradientLayer = gradientLayer
                self.updateGradientLayerColor()
            }
            self.circleLayer.removeFromSuperlayer()
            self.layer.addSublayer(self.gradientLayer!)
        default:
            if self.gradientLayer != nil {
                self.gradientLayer?.removeFromSuperlayer()
                self.gradientLayer = nil
            }
            
            if self.circleLayer.superlayer == nil {
                self.layer.addSublayer(self.circleLayer)
            }
            
            if style == .default {
                self.circleLayer.strokeEnd = 0.6
            } else if style == .cumulative {
                self.circleLayer.strokeEnd = 0
            }
        }
    }
    
    private func setup() {
        self.layer.addSublayer(self.circleLayer)
        self.circleLayer.strokeColor = self.tintColor.cgColor
        self.circleLayer.lineWidth = self.lineWidth
        self.updateLayerStyle()
    }
    
    private var circleLayer: CAShapeLayer = {
        let layer = CAShapeLayer.init()
        layer.lineCap = kCALineCapRound
        layer.strokeEnd = 0
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }()
    
    private var gradientLayer: CALayer?
    
    private static let animationKey = "simpleAnimation"
}
