//
//  SloganHeaderContentView.swift
//  JWRefreshControlDemo
//
//  Created by Jerry on 2017/11/9.
//  Copyright © 2017年 Jerry. All rights reserved.
//

import UIKit

let themeColor = UIColor.init(red: 246.0 / 255.0, green: 72 / 255.0, blue: 69 / 255.0, alpha: 1.0)

class SloganHeaderContentView: UIView {
    
    override init(frame: CGRect) {
        
        self.sloganLayer = SloganLayer.init()
        
        super.init(frame: frame)
        self.layer.addSublayer(sloganLayer)
        sloganLayer.strokeColor = themeColor.cgColor
        sloganLayer.fillColor = UIColor.clear.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sloganLayer.frame = CGRect.init(x: (self.frame.size.width - 170) * 0.5, y: self.frame.size.height - 69, width: 170, height: 56)
    }
    
    private let sloganLayer: SloganLayer!
}

extension SloganHeaderContentView : AnyRefreshContent {
    
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
        self.setup()
    }
    
    override init() {
        super.init()
        self.setup()
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
            self.path = final!.cgPath
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
        
        self.add(animGroup, forKey: "sloganAnimation")
    }
    
    func pauseAnimation(){
        if self.speed > 0 {
            let pauseTime = self.convertTime(CACurrentMediaTime(), from: nil)
            self.speed = 0
            self.timeOffset = pauseTime
        }
    }
    
    func resumeAnimation(){
        if self.speed == 0 {
            let pausedTime = self.timeOffset
            self.speed = 1.0
            self.timeOffset = 0.0
            self.beginTime = 0.0
            let timeSincePause = self.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
            self.beginTime = timeSincePause
        }
    }
    
}
