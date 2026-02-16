//
//  Animation.swift
//  Image Feed
//
//  Created by Дарья Савинкина on 16.02.2026.
//

import UIKit

final class SkeletonFactory {
    static func makeGradientLayer(for view: UIView) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [
            UIColor(red: 0.68, green: 0.68, blue: 0.71, alpha: 1.0).cgColor,
            UIColor(red: 0.53, green: 0.53, blue: 0.56, alpha: 1.0).cgColor,
            UIColor(red: 0.68, green: 0.68, blue: 0.71, alpha: 1.0).cgColor
        ]
        gradient.locations = [0, 0.5, 1]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = view.layer.cornerRadius
        gradient.masksToBounds = true
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        
        gradient.add(animation, forKey: "skeletonAnimation")
        
        return gradient
    }
}
