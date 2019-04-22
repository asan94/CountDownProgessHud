//
//  CountDownProgressBar.swift
//  ProgressAnimation
//
//  Created by Asan Ametov on 4/22/19.
//  Copyright © 2019 Asan Ametov. All rights reserved.
//

import UIKit

class CountDownProgressBar: UIView {
    private var timer = Timer()
    
    private var duration = 5.0
    private var remainingTime = 0.0
    private var showPulse = false

    /// label that will show the remaining time
    private lazy var remainingTimeLabel: UILabel = {
        let remainingTimeLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: bounds.width, height: bounds.height)))
        remainingTimeLabel.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        remainingTimeLabel.textAlignment = NSTextAlignment.center
        return remainingTimeLabel
    }()
    
    /// foreground layer that will be animated
    private lazy var foregroundLayer: CAShapeLayer = {
        let foregroundLayer = CAShapeLayer()
        foregroundLayer.lineWidth = 10
        foregroundLayer.strokeColor = UIColor.black.cgColor
        foregroundLayer.lineCap = .round
        foregroundLayer.fillColor = UIColor.clear.cgColor
        foregroundLayer.strokeEnd = 0
        foregroundLayer.frame = bounds
        return foregroundLayer
    }()
    /// backgroud layer that will be animated
    private lazy var backgroundLayer: CAShapeLayer = {
        let backgroundLayer = CAShapeLayer()
        backgroundLayer.lineWidth = 10
        backgroundLayer.strokeColor = UIColor.black.cgColor
        backgroundLayer.lineCap = .round
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.frame = bounds
        return backgroundLayer
    }()
    private lazy var pulseLayer: CAShapeLayer = {
        let pulseLayer = CAShapeLayer()
        pulseLayer.lineWidth = 10
        pulseLayer.strokeColor = UIColor.lightGray.cgColor
        pulseLayer.lineCap = .round
        pulseLayer.fillColor = UIColor.clear.cgColor
        pulseLayer.frame = bounds
        return pulseLayer
    }()
    
    
    private lazy var foregroundGradientLayer: CAGradientLayer = {
       let foregroundGradientLayer = CAGradientLayer()
        foregroundGradientLayer.frame = bounds
        let startColor = UIColor.red.cgColor
        let secondColor = UIColor.yellow.cgColor
        foregroundGradientLayer.colors = [startColor, secondColor]
        foregroundGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        foregroundGradientLayer.endPoint = CGPoint(x: 1, y: 1)
        return foregroundGradientLayer
    }()
    
    private lazy var pulseGradientLayer: CAGradientLayer = {
        let pulseGradientLayer = CAGradientLayer()
        pulseGradientLayer.frame = bounds
        let startColor = UIColor.red.cgColor.copy(alpha: 0.5)
        let secondColor = UIColor.yellow.cgColor.copy(alpha: 0.5)
        pulseGradientLayer.colors = [startColor!, secondColor!]
        pulseGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        pulseGradientLayer.endPoint = CGPoint(x: 1, y: 1)
        return pulseGradientLayer
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadLayers()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadLayers()
    }
    deinit {
        timer.invalidate()
    }
    private func loadLayers() {
        
        /// get the centre point of the view
        let centrePoint = CGPoint(x: frame.width/2, y: frame.height/2)
        
        /// create a circular path that is just slighly smaller than the view
        /// set the start angle to be 12 o'clock and angle, to be 360 degrees clockwise
        let circularPath = UIBezierPath(arcCenter: centrePoint, radius: bounds.width / 2 - 20, startAngle: -CGFloat.pi/2, endAngle: 2 * CGFloat.pi - CGFloat.pi/2, clockwise:  true)
        //give the CAShapeLayers the circular path to follow
        //pulse and foreground layers will be the masks over the gradient layers
        //add the background CAShapeLayer and the 2 CAGradientLayer as a sublayer
        pulseLayer.path = circularPath.cgPath
        
        pulseGradientLayer.mask = pulseLayer
        
        layer.addSublayer(pulseGradientLayer)
        
        backgroundLayer.path = circularPath.cgPath
        layer.addSublayer(backgroundLayer)
        
        foregroundLayer.path = circularPath.cgPath
        foregroundGradientLayer.mask = foregroundLayer
        layer.addSublayer(foregroundGradientLayer)
        addSubview(remainingTimeLabel)
        print(remainingTimeLabel.frame)
    }
    private func beginAnimation() {
        
        animateForegroundLayer()
        
        // only show the pulse if required
        if showPulse {
            animatePulseLayer()
        }
        
    }
    private func animateForegroundLayer() {
        let foregroundAnimation = CABasicAnimation(keyPath: "strokeEnd")
        foregroundAnimation.fromValue = 0
        foregroundAnimation.toValue = 1
        foregroundAnimation.duration = CFTimeInterval(duration)
        foregroundAnimation.fillMode = CAMediaTimingFillMode.forwards
        foregroundAnimation.isRemovedOnCompletion = false
        foregroundAnimation.delegate = self
        
        foregroundLayer.add(foregroundAnimation, forKey: "foregroundAnimation")
    }
    
    private func animatePulseLayer() {
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.2
        
        let pulseOpacityAnimation = CABasicAnimation(keyPath: "opacity")
        pulseOpacityAnimation.fromValue = 0.7
        pulseOpacityAnimation.toValue = 0.0
        
        let groupedAnimation = CAAnimationGroup()
        groupedAnimation.animations = [pulseAnimation, pulseOpacityAnimation]
        groupedAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        groupedAnimation.duration = 1.0
        groupedAnimation.repeatCount = Float.infinity
        
        pulseLayer.add(groupedAnimation, forKey: "pulseAnimation")
    }
    
    @objc private func handleTimerTick() {
        remainingTime -= 0.1
        if remainingTime > 0 {
            
        } else {
            remainingTime = 0
            timer.invalidate()
        }
        DispatchQueue.main.async {
            self.remainingTimeLabel.text = "\(String(format: "%.1f", self.remainingTime))"
        }
    }
    
    //MARK: - Public functions
    
    /// Starts countDown with defined duration.
    ///
    /// - Parameters:
    ///   - duration: Countdown time duration
    ///   - showPulse: showPulse By default false, set to true to show pulse around the countDown progressbar.
    func startCountDown(duration: Double, showPulse: Bool = false) {
        self.duration = duration
        self.showPulse = showPulse
        remainingTime = duration
        remainingTimeLabel.text = "\(remainingTime)"
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleTimerTick), userInfo: nil,repeats: true)
        beginAnimation()
    }
}
extension CountDownProgressBar: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        pulseLayer.removeAllAnimations()
        timer.invalidate()
    }
}
