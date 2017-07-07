//
//  Extension.swift
//  ZCPlayer
//
//  Created by Doyle Illusion on 7/5/17.
//  Copyright © 2017 Zyncas Technologies. All rights reserved.
//

import UIKit

extension UIColor {
    
    /** Get color with hex */
    static func color(_ hex: Int, alpha: CGFloat = 1.0) -> UIColor {
        let red     = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green   = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue    = CGFloat((hex & 0xFF)) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
extension String {
    func timeIntervalToMMSSFormat(_ interval: TimeInterval) -> String {
        let ti = Int(interval)
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        return String(format: "%02ld:%02ld", Int(minutes), Int(seconds))
    }
}
