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

open class CircleLoadingView: UIView {
    
    public enum CircleLoadingStyle {
        
        case `default`
        
        case cumulative
        
        case gradient
        
    }
    
    open private(set) var isAnimating = false {
        didSet {
            isHidden = !isAnimating
        }
    }
    
    open var style = CircleLoadingStyle.default {
        didSet {
            if style != oldValue {
                updateLayerStyle()
            }
        }
    }
    
    open var lineWidth: CGFloat = 3.0 {
        didSet {
            if lineWidth != oldValue {
                circleLayer.lineWidth = lineWidth
                layoutLayers()
            }
        }
    }
    
    open var drawBackground = true {
        didSet {
            if drawBackground != oldValue {
               setNeedsDisplay()
            }
        }
    }
    
    open func startAnimating() {
        if isAnimating {
            return
        }
        
        isAnimating = true
        let duration = 1.5
        if style == .cumulative {
            let strokeStartAnimation = CAKeyframeAnimation(keyPath: "strokeStart")
            strokeStartAnimation.duration = duration
            strokeStartAnimation.values = [0, 0.2, 1.0]
            strokeStartAnimation.keyTimes = [0, 0.5, 1.0]
            let strokeEndAnimation = CAKeyframeAnimation(keyPath: "strokeEnd")
            strokeEndAnimation.duration = duration
            strokeEndAnimation.values = [0, 0.9, 1.0]
            strokeEndAnimation.keyTimes = [0, 0.5, 1.0]
            let groupAnimation = CAAnimationGroup()
            groupAnimation.animations = [strokeStartAnimation, strokeEndAnimation]
            groupAnimation.duration = duration
            groupAnimation.repeatCount = Float.infinity
            circleLayer.add(groupAnimation, forKey: CircleLoadingView.animationKey)
        } else if style == .default {
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotationAnimation.toValue = Float(Double.pi * 2)
            rotationAnimation.duration = duration
            rotationAnimation.isCumulative = true
            rotationAnimation.repeatCount = Float.infinity
            circleLayer.add(rotationAnimation, forKey: CircleLoadingView.animationKey)
        } else if style ==  .gradient {
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotationAnimation.toValue = Float(Double.pi * 2.0)
            rotationAnimation.duration = duration
            rotationAnimation.isCumulative = true
            rotationAnimation.repeatCount = Float.infinity
            gradientLayer?.add(rotationAnimation, forKey: CircleLoadingView.animationKey)
        }
    }
    
    open func stopAnimating() {
        circleLayer.removeAllAnimations()
        isAnimating = false
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
    
    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow != nil && isAnimating {
            let simpleAnimation = circleLayer.animation(forKey: CircleLoadingView.animationKey)
            if simpleAnimation == nil {
                isAnimating = false
                startAnimating()
            }
        }
    }
    
    open override func tintColorDidChange() {
        super.tintColorDidChange()
        circleLayer.strokeColor = tintColor.cgColor
        if gradientLayer != nil {
            updateGradientLayerColor()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        layoutLayers()
    }
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        if drawBackground && style != .gradient {
            let context = UIGraphicsGetCurrentContext()
            context?.setLineWidth(lineWidth)
            context?.setStrokeColor(tintColor.withAlphaComponent(0.2).cgColor)
            context?.beginPath()
            if circleLayer.path != nil {
                context?.addPath(circleLayer.path!)
            }
            context?.strokePath()
        }
    }
    
    private func layoutLayers() {
        circleLayer.frame = bounds;
        
        let path = CGMutablePath()
        
        let radius = (min(frame.size.width, frame.size.height) - circleLayer.lineWidth) * 0.5
        path.addArc(center:CGPoint(x: frame.size.width * 0.5, y: frame.size.height * 0.5), radius: radius, startAngle: CGFloat(-Double.pi / 2), endAngle: CGFloat(-Double.pi / 2 + Double.pi * 2), clockwise: false)
        circleLayer.path = path;
        
        if let gradientLayer = gradientLayer {
            gradientLayer.frame = bounds
            let g0 = gradientLayer.sublayers?.first as? CAGradientLayer
            let g1 = gradientLayer.sublayers?.last as? CAGradientLayer
            g0?.frame = CGRect(x: 0, y: 0, width: frame.size.width * 0.5, height: frame.size.height)
            g1?.frame = CGRect(x: frame.size.width * 0.5, y: 0, width: frame.size.width * 0.5, height: frame.size.height)
            gradientLayer.mask = circleLayer
        }
    }
    
    private func updateGradientLayerColor() {
        guard let gradientLayer = gradientLayer else {
            return
        }
        let g0 = gradientLayer.sublayers?.first as? CAGradientLayer
        let g1 = gradientLayer.sublayers?.last as? CAGradientLayer
        
        g0?.colors = [tintColor.withAlphaComponent(0.5).cgColor, tintColor.withAlphaComponent(0.15).cgColor]
        g0?.startPoint = CGPoint(x: 1.0, y: 1.0)
        g0?.endPoint = CGPoint(x: 1.0, y: 0.0)
        
        g1?.colors = [tintColor.withAlphaComponent(0.5).cgColor, tintColor.cgColor]
        g1?.startPoint = CGPoint(x: 1.0, y: 1.0)
        g1?.endPoint = CGPoint(x: 1.0, y: 0.0)
        
    }
    
    private func updateLayerStyle() {
        switch style {
        case .gradient:
            if gradientLayer == nil {
                let gradientLayer = CALayer()
                gradientLayer.mask = circleLayer
                
                let g0 = CAGradientLayer()
                let g1 = CAGradientLayer()
                
                gradientLayer.addSublayer(g0)
                gradientLayer.addSublayer(g1)
                
                self.gradientLayer = gradientLayer
                updateGradientLayerColor()
            }
            circleLayer.removeFromSuperlayer()
            layer.addSublayer(gradientLayer!)
        default:
            if gradientLayer != nil {
                gradientLayer?.removeFromSuperlayer()
                gradientLayer = nil
            }
            
            if circleLayer.superlayer == nil {
                layer.addSublayer(circleLayer)
            }
            
            if style == .default {
                circleLayer.strokeEnd = 0.6
            } else if style == .cumulative {
                circleLayer.strokeEnd = 0
            }
        }
    }
    
    private func setup() {
        layer.addSublayer(circleLayer)
        circleLayer.strokeColor = tintColor.cgColor
        circleLayer.lineWidth = lineWidth
        updateLayerStyle()
    }
    
    private var circleLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineCap = kCALineCapRound
        layer.strokeEnd = 0
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }()
    
    private var gradientLayer: CALayer?
    
    private static let animationKey = "simpleAnimation"
}
