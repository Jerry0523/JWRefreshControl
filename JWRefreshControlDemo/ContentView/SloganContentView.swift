//
//  SloganContentView.swift
//  JWRefreshControlDemo
//
//  Created by Jerry on 2017/11/9.
//  Copyright © 2017年 Jerry. All rights reserved.
//

import UIKit
import JWRefreshControl

let themeColor = UIColor.init(red: 246.0 / 255.0, green: 72 / 255.0, blue: 69 / 255.0, alpha: 1.0)

class SloganContentView: UIView {
    
    override init(frame: CGRect) {
        
        sloganLayer = SloganLayer.init()
        
        super.init(frame: frame)
        layer.addSublayer(sloganLayer)
        sloganLayer.strokeColor = themeColor.cgColor
        sloganLayer.fillColor = UIColor.clear.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sloganLayer.frame = CGRect.init(x: (frame.size.width - 170) * 0.5, y: frame.size.height - 69, width: 170, height: 56)
    }
    
    private let sloganLayer: SloganLayer!
}

extension SloganContentView : AnyRefreshContent {
    
    static var preferredHeight: CGFloat {
        return 120
    }
    
    func setProgress(progress: CGFloat) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        sloganLayer.strokeEnd = progress
        sloganLayer.fillColor = themeColor.withAlphaComponent(progress).cgColor
        CATransaction.commit()
    }
    
    func startLoading() {
        sloganLayer.startAnimation()
    }
    
    func stopLoading() {
        sloganLayer.removeAllAnimations()
    }
}

class SloganLayer: CAShapeLayer {
    
    func convertToPoint(pointString: String) -> CGPoint {
        let pointsArray = pointString.components(separatedBy: ",")
        if pointsArray.count == 2 {
            return CGPoint.init(x: CGFloat(Float(pointsArray[0])!) , y: CGFloat(Float(pointsArray[1])!))
        } else {
            return CGPoint.zero
        }
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        setup()
    }
    
    override init() {
        super.init()
        setup()
    }
    
    private func setup() {
        var final: UIBezierPath? = nil
        if let pointsArray = NSArray(contentsOfFile: Bundle.main.path(forResource: "SloganPoints", ofType: "plist")!) {
            if pointsArray.count > 0 {
                final = try? UIBezierPath.init(dataArray: pointsArray as! [String], defaultMethod: .curve)
            }
        }
        
        if final != nil {
            final?.miterLimit = 4
            final?.close()
            path = final!.cgPath
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAnimation(){
        let colorAnimation = CABasicAnimation(keyPath: "fillColor")
        colorAnimation.duration = 6.0;
        colorAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.2, 0.5, 0.5, 0.7)
        colorAnimation.fromValue = UIColor.clear.cgColor
        colorAnimation.toValue = themeColor.cgColor
        
        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = 3.0
        pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pathAnimation.fromValue = 0.0
        pathAnimation.toValue = 1.0
        
        let animGroup = CAAnimationGroup()
        animGroup.animations = [colorAnimation, pathAnimation]
        animGroup.duration = 6.0
        animGroup.repeatCount = Float(LONG_MAX)
        animGroup.isRemovedOnCompletion = false
        animGroup.fillMode = kCAFillModeForwards
        
        add(animGroup, forKey: "sloganAnimation")
    }
    
    func pauseAnimation(){
        if speed > 0 {
            let pauseTime = convertTime(CACurrentMediaTime(), from: nil)
            speed = 0
            timeOffset = pauseTime
        }
    }
    
    func resumeAnimation(){
        if speed == 0 {
            let pausedTime = timeOffset
            speed = 1.0
            timeOffset = 0.0
            beginTime = 0.0
            let timeSincePause = convertTime(CACurrentMediaTime(), from: nil) - pausedTime
            beginTime = timeSincePause
        }
    }
    
}
