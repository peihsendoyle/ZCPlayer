//
//  BufferSlider.swift
//  ZCPlayer
//
//  Created by Doyle Illusion on 7/7/17.
//  Copyright © 2017 Zyncas Technologies. All rights reserved.
//

import Foundation
import UIKit

class BufferSlider: UISlider {
    
    fileprivate let progressView = UIProgressView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.minimumValue = 0
        self.maximumValue = 1
        self.value = 0
        self.minimumTrackTintColor = UIColor.color(0xFFFFFF, alpha: 1.0)
        self.maximumTrackTintColor = .clear
        
        self.addComponents()
        self.addConstraints()
    }
    
    fileprivate func addComponents() {
        self.progressView.layer.cornerRadius = 1.0
        self.progressView.layer.masksToBounds = true
        self.progressView.progress = 0
        self.progressView.progressViewStyle = .default
        self.progressView.progressTintColor = UIColor.color(0xFFFFFF, alpha: 0.5)
        self.progressView.trackTintColor = .clear
        self.insertSubview(self.progressView, at: 0)
    }
    
    fileprivate func addConstraints() {
        self.progressView.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["progressView": self.progressView]
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[progressView]|", options: [], metrics: nil, views: views))
        self.addConstraint(NSLayoutConstraint.init(item: self.progressView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 1.0))
    }
    
    func setProgress(progress: Float, animated: Bool) {
        self.progressView.setProgress(progress, animated: animated)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
