//
// SimpleShapeView.swift
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

public enum SimpleShapeType : String {
    case custom = "custom"
    case yes = "yes"
    case arrow = "arrow"
    case heart = "heart"
    case pentastar = "pentastar"
    case add = "add"
    case close = "close"
    
    public var shapeData: [String]? {
        switch self {
        case .yes:
            return ["0.04,0.53|1", "0.4,0.9", "0.96,0.1"]
        case .arrow:
            return ["0.5,0.98|1", "0.5,0.02", "0.2,0.36", "0.5,0.02|1", "0.8,0.36"]
        case .heart:
            return ["0.5,0.3|1", "0.08,0.26,0.28,0.03,0.1,0.18|2", "0.11,0.51,0.05,0.36,0.06,0.45|2", "0.5,0.9,0.2,0.65|3", "0.89,0.51,0.8,0.65|3","0.92,0.26,0.94,0.45,0.95,0.36|2", "0.5,0.3,0.9,0.18,0.72,0.03|2"]
        case .pentastar:
            return ["0.5,0.05|1", "0.6,0.39", "0.95,0.39", "0.67,0.6", "0.77,0.93", "0.5,0.73", "0.23,0.93", "0.33,0.6", "0.05,0.39", "0.4,0.39", "0.5,0.05"]
        case .add:
            return ["0.04,0.5|1", "0.96,0.5", "0.5,0.04|1", "0.5,0.96"]
        case .close:
            return ["0.16,0.16|1", "0.82,0.82", "0.84,0.16|1", "0.18,0.82"]
        default:
            return nil
        }
    }
}

public enum SimpleShapeSubType : String {
    case arrowTop = "top"
    case arrowBottom = "bottom"
    case arrowLeft = "left"
    case arrowRight = "right"
    case pentastarHalf = "half"
}

@IBDesignable
open class SimpleShapeView: UIView {
    
    @IBInspectable open var lineWidth: CGFloat = 2.0 {
        didSet {
            if lineWidth != oldValue {
                shapeLayer.lineWidth = lineWidth
            }
        }
    }
    
    @IBInspectable open var filled = false {
        didSet {
            if filled != oldValue {
                updateLayerColor()
            }
        }
    }
    
    open var type: SimpleShapeType = .custom {
        didSet {
            if type != oldValue {
                maskLayer = nil
                shapeLayer.mask = nil
                setNeedsLayout()
            }
        }
    }
    
    open var subType: SimpleShapeSubType? {
        didSet {
            if subType == oldValue {
                return
            }
            if type == .arrow {
                var angle: Double = 0
                if subType == .arrowLeft {
                    angle = -Double.pi / 2
                } else if subType == .arrowBottom {
                    angle = -Double.pi
                } else if subType == .arrowRight {
                    angle = Double.pi / 2
                }
                UIView.animate(withDuration: 0.25, animations: {
                    self.shapeLayer.transform = CATransform3DMakeRotation(CGFloat(angle), 0, 0, 1.0)
                })
            } else if type == .pentastar {
                if subType == .pentastarHalf {
                    maskLayer = CAShapeLayer.init()
                    shapeLayer.mask = maskLayer
                    setupMaskLayer()
                } else {
                    maskLayer = nil
                    shapeLayer.mask = nil
                }
            }
        }
    }
    
    @IBInspectable open var typeString: String? {
        set {
            guard let typeString = typeString else {
                return
            }
            let newType = SimpleShapeType.init(rawValue: typeString)
            if newType != nil {
                type = newType!
            }
        }
        
        get {
            return type.rawValue
        }
    }
    
    @IBInspectable open var subTypeString: String? {
        set {
            guard let subTypeString = subTypeString else {
                return
            }
            let newType = SimpleShapeSubType.init(rawValue: subTypeString)
            if newType != nil {
                subType = newType!
            }
        }
        
        get {
            return subType?.rawValue
        }
    }
    
    open var shapeData: [String]? {
        get {
            return type.shapeData
        }
    }
    
    open func beginSimpleAnimation() {
        if type == .yes {
            shapeLayer.removeAllAnimations()
            let animation = CABasicAnimation.init(keyPath: "strokeEnd")
            animation.fromValue = 0
            animation.toValue = 1.0
            animation.duration = 0.25
            shapeLayer.add(animation, forKey: nil)
        }
    }
    
    open override class var layerClass: Swift.AnyClass {
        get {
            return CAShapeLayer.self
        }
    }
    
    open override var intrinsicContentSize: CGSize {
        get {
            return CGSize.init(width: 35, height: 35)
        }
    }
    
    private var shapeLayer: CAShapeLayer {
        get {
            return layer as! CAShapeLayer
        }
    }
    
    private var maskLayer: CAShapeLayer?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    open override func tintColorDidChange() {
        super.tintColorDidChange()
        updateLayerColor()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let layerSize = min(frame.size.width, frame.size.height)
        let bezierPath = try? UIBezierPath.init(dataArray: shapeData ?? [], destSize: layerSize)
        shapeLayer.path = bezierPath?.cgPath
        setupMaskLayer()
    }
    
    private func setup() {
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.lineJoin = kCALineJoinRound
        updateLayerColor()
    }
    
    private func updateLayerColor() {
        shapeLayer.strokeColor = tintColor.cgColor
        var filledColor = UIColor.clear
        if filled && (type == .heart || type == .pentastar) {
            filledColor = tintColor
        }
        shapeLayer.fillColor = filledColor.cgColor
    }
    
    private func setupMaskLayer() {
        if subType == .pentastarHalf {
            maskLayer?.path = UIBezierPath.init(rect: CGRect.init(x: 0, y: 0, width: frame.size.width * 0.5, height: frame.size.height)).cgPath
        }
    }
}

extension UIBezierPath {
    
    public enum PathMethod: Int {
        case line = 0
        case move = 1
        case curve = 2
        case quadCurve = 3
        case arc = 4
        case close = 5
        case clip = 6
        
        func draw(numValueArray: [CGFloat], path: UIBezierPath, destSize: CGFloat) {
            switch self {
            case .move:
                if numValueArray.count == 2 {
                    path.move(to: CGPoint(x: destSize * numValueArray[0], y: destSize * numValueArray[1]))
                }
                break
            case .line:
                if numValueArray.count == 2 {
                    path.addLine(to: CGPoint(x: destSize * numValueArray[0], y: destSize * numValueArray[1]))
                }
                break
            case .curve:
                if numValueArray.count == 6 {
                    path.addCurve(to: CGPoint(x: destSize * numValueArray[0], y: destSize * numValueArray[1]), controlPoint1: CGPoint(x: destSize * numValueArray[2], y: destSize * numValueArray[3]), controlPoint2: CGPoint(x: destSize * numValueArray[4], y: destSize * numValueArray[5]))
                }
                break
            case .quadCurve:
                if numValueArray.count == 4 {
                    path.addQuadCurve(to: CGPoint(x: destSize * numValueArray[0], y: destSize * numValueArray[1]), controlPoint: CGPoint(x: destSize * numValueArray[2], y: destSize * numValueArray[3]))
                }
                break
            case .arc:
                if numValueArray.count == 6 {
                    path.addArc(withCenter: CGPoint(x: destSize * numValueArray[0], y: destSize * numValueArray[1]), radius: destSize * numValueArray[2], startAngle: numValueArray[3], endAngle: numValueArray[4], clockwise: numValueArray[5] < 1)
                }
                break
            case .close:
                path.close()
                break
            case .clip:
                path.addClip()
                break
            }
        }
    }
    
    public convenience init(dataArray: [String], destSize: CGFloat = 1.0, defaultMethod: PathMethod? = .line) throws {
        self.init()
        for line in dataArray {
            let lineGroup = line.components(separatedBy: "|")
            var method: PathMethod = defaultMethod ?? .line
            if lineGroup.count == 2 {
                guard let aMethod = PathMethod.init(rawValue: Int(lineGroup[1])!) else {
                    throw NSError.init(domain: "com.jerry", code: 0, userInfo: [NSLocalizedDescriptionKey: "unknown path method!"])
                }
                method = aMethod
            }
            
            let valueArray = lineGroup.first?.components(separatedBy: ",")
            var numValueArray: [CGFloat] = []
            if valueArray != nil {
                for value in valueArray! {
                    let numValue = Float(value.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
                    if numValue != nil {
                        numValueArray.append(numValue == nil ? 0 : CGFloat(numValue!))
                    }
                }
            }
            method.draw(numValueArray: numValueArray, path: self, destSize: destSize)
        }
    }
}
