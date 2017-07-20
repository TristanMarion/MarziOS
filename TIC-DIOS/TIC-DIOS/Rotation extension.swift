//
//  Rotation extension.swift
//  TIC-DIOS
//
//  Created by etna on 19/07/2017.
//  Copyright © 2017 etna. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    //Start Rotating view
    func startRotating(duration: Double = 1) {
        let kAnimationKey = "rotation"
        
        if self.layer.animation(forKey: kAnimationKey) == nil {
            let animate = CABasicAnimation(keyPath: "transform.rotation")
            animate.duration = duration
            animate.repeatCount = Float.infinity
            
            animate.fromValue = 0.0
            animate.toValue = Float(Double.pi * 5.0)
            self.layer.add(animate, forKey: kAnimationKey)
        }
    }
    
    //Stop rotating view
    func stopRotating() {
        let kAnimationKey = "rotation"
        
        if self.layer.animation(forKey: kAnimationKey) != nil {
            self.layer.removeAnimation(forKey: kAnimationKey)
        }
    }
    
}
