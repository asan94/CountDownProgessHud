//
//  ViewController.swift
//  ProgressAnimation
//
//  Created by Asan Ametov on 4/22/19.
//  Copyright © 2019 Asan Ametov. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CAAnimationDelegate {
    let gradient = CAGradientLayer()
    var gradientSet = [[CGColor]]()
    var currentGradient: Int = 0
    let colorOne = UIColor.blue.cgColor
    let colorTwo = UIColor.red.cgColor
    let colorThree = UIColor.yellow.cgColor
    @IBOutlet weak var progressView: CountDownProgressBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.progressView.startCountDown(duration: 10, showPulse: true)
        self.createGradientView()
    }
    
    func createGradientView() {
        gradientSet.append([colorOne, colorTwo])
        gradientSet.append([colorTwo, colorThree])
        gradientSet.append([colorThree, colorOne])
        gradient.frame = self.view.bounds
        gradient.colors = gradientSet[currentGradient]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.drawsAsynchronously = true
        self.view.layer.insertSublayer(gradient, at: 0)
        animateGradient()
    }
    func animateGradient() {
        if currentGradient < gradientSet.count - 1 {
            currentGradient += 1
        } else {
            currentGradient = 0
        }
        
        let gradientChangeAnumation = CABasicAnimation(keyPath: "colors")
        gradientChangeAnumation.duration = 3.0
        gradientChangeAnumation.toValue = gradientSet[currentGradient]
        gradientChangeAnumation.fillMode = CAMediaTimingFillMode.forwards
        gradientChangeAnumation.isRemovedOnCompletion = false
        gradientChangeAnumation.delegate = self
        gradient.add(gradientChangeAnumation, forKey: "gradientChangeAnimation")
    }
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            gradient.colors = gradientSet[currentGradient]
            animateGradient()
        }
    }
}

