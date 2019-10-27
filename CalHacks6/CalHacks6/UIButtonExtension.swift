//
//  UIButtonExtension.swift
//  CalHacks6
//
//  Created by Arman Vaziri on 10/26/19.
//  Copyright © 2019 ArmanVaziri. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
    func pulse() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.5
        pulse.fromValue = 0.9
        pulse.toValue = 1.0
        pulse.autoreverses = false
        pulse.repeatCount = 1
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        layer.add(pulse, forKey: nil)
        
    }
     
}

extension UILabel {
    
    func pulseLabel() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 5.0
        pulse.fromValue = 0.9
        pulse.toValue = 1.0
        pulse.autoreverses = false
        pulse.repeatCount = 1
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        layer.add(pulse, forKey: nil)
        
    }
     
}
