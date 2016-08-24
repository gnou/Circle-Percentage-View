//
//  CirclePercentageView.swift
//  CircelProgress
//
//  Created by CuiMingyu on 8/23/16.
//  Copyright © 2016 CuiMingyu. All rights reserved.
//

import Foundation
import UIKit

class CirclePercentageView: UIView {
    
    // MARK: - Single Progress Mode
    
    /// Percentage value
    var percentage: CGFloat? {
        didSet {
            if let percentage = percentage {
                self.percentages = [percentage]
            } else {
                self.percentages = []
            }
        }
    }
    
    var progressBarColor: UIColor? {
        didSet {
            if let progressBarColor = progressBarColor {
                self.progressBarColors = [progressBarColor]
            } else {
                self.progressBarColors = []
            }
        }
    }
    
    // MARK: - Multiple Progresses Mode
    
    /// Multiple percentage values
    var percentages = [CGFloat]() {
        didSet {
            // Not allow more than 10 percentage numbers
            assert(percentages.count < 10, "Too many percentage numbers")
            
            // Negative percentage number is not allowed
            for p in percentages {
                assert(p >= 0, "Input number must be equal to or greater than 0")
            }
            
            // Summary should less than 1.0
            let summary = percentages.reduce(0.0) { $0 + $1 }
            assert(summary <= 1.0, "Total value of input should always less than 100%")
            
            setupProgressLayers()
        }
    }
    
    /// Colors for all the progress numbers
    var progressBarColors = [UIColor]()
    
    // MARK: - Background Circle
    
    /// Start angle for the background circle,
    /// default value is the left most dot of a circle, which is π
    var backgroundCircleStartAngle: CGFloat = CGFloat(M_PI)
    
    /// End angle for the background circle
    /// default value is the default value start angle plus a whole circle, which is π + 2π, which is 3π
    var backgroundCircleEndAngle: CGFloat = CGFloat(3 * M_PI)
    
    /// Color for the background circle
    var backgroundCircleColor: UIColor = UIColor(white: 0.9, alpha: 1.0)
    
    /// The direction in which to draw the arcs.
    var clockwise: Bool = true
    
    var widthOfProgressLine: CGFloat = 12.0
    
    var animated: Bool = false
    
    /// How long does the animation take
    var animationDuration: Double = 0.5
    
    private var backgroundCircleLayer: CAShapeLayer?
    private var progressLayers = [CAShapeLayer]()
    
    private func randomColor() -> UIColor {
        return UIColor(red: CGFloat(arc4random_uniform(255))/255.0, green: CGFloat(arc4random_uniform(255))/255.0, blue: CGFloat(arc4random_uniform(255))/255.0, alpha: 1.0)
    }
    
    private func pathAnimation(fromValue fromValue: CGFloat, toValue: CGFloat) -> CABasicAnimation {
        let pAnimation = CABasicAnimation()
        pAnimation.duration = CFTimeInterval(animationDuration)
        pAnimation.fromValue = fromValue
        pAnimation.toValue = toValue
        pAnimation.removedOnCompletion = true
        pAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        return pAnimation
    }
    
    // MARK: - Initizlization methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private var arcPath: CGPath {
        let radius = min(bounds.width, bounds.height)/2 - widthOfProgressLine/2
        let pathCenter = CGPoint(x: bounds.origin.x + bounds.width/2, y: bounds.origin.y + bounds.height/2)
        let path = UIBezierPath(arcCenter: pathCenter, radius: radius, startAngle: backgroundCircleStartAngle, endAngle: backgroundCircleEndAngle, clockwise: clockwise)
        return path.CGPath
    }
    
    private func arcLayer() -> CAShapeLayer {
        let pLayer = CAShapeLayer()
        pLayer.path = arcPath
        pLayer.fillColor = UIColor.clearColor().CGColor
        pLayer.lineWidth = widthOfProgressLine
        pLayer.lineCap = kCALineCapRound
        return pLayer
    }
    
    func setupBackgroundLayer() {
        backgroundCircleLayer = arcLayer()
        backgroundCircleLayer?.strokeColor = backgroundCircleColor.CGColor
        layer.addSublayer(backgroundCircleLayer!)
    }
    
    func setupProgressLayers() {
        for pLayer in progressLayers {
            pLayer.removeFromSuperlayer()
        }
        
        var summary: CGFloat = 0.0
        for (index, p) in percentages.enumerate() {
            let pLayer = arcLayer()
            
            let startValue = summary
            summary += p
            let endValue = summary
            
            pLayer.strokeStart = startValue
            pLayer.strokeEnd = endValue
            
            if index < progressBarColors.count {
                pLayer.strokeColor = progressBarColors[index].CGColor
            } else {
                pLayer.strokeColor = randomColor().CGColor
            }
            
            if animated {
                pLayer.addAnimation(pathAnimation(fromValue: 0.0, toValue: startValue), forKey: "strokeStart")
                pLayer.addAnimation(pathAnimation(fromValue: 0.0, toValue: endValue), forKey: "strokeEnd")
            }
            
            if let backgroundCircleLayer = backgroundCircleLayer {
                layer.insertSublayer(pLayer, above: backgroundCircleLayer)
            } else {
                layer.insertSublayer(pLayer, atIndex: 0)
            }
            progressLayers.append(pLayer)
        }
    }
    
    override func layoutSubviews() {
        backgroundCircleLayer?.path = arcPath
        
        for pLayer in progressLayers {
            pLayer.path = arcPath
        }
    }
}