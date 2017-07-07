//
//  PlayerView.swift
//  ZCPlayer
//
//  Created by Doyle Illusion on 7/5/17.
//  Copyright © 2017 Zyncas Technologies. All rights reserved.
//

import UIKit
import AVFoundation

protocol PlayerViewDelegate : class {
    func didScrubbing()
    func didBeginScrubbing()
    func didEndScrubbing()
}

class PlayerView: UIView {
    
    weak var delegate : PlayerViewDelegate?
    
    fileprivate let currentTimeLabel = UILabel()
    fileprivate let durationTimeLabel = UILabel()
    let slider = BufferSlider()
    fileprivate let indicator = UIActivityIndicatorView()
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.black
        
        (self.layer as! AVPlayerLayer).frame = self.bounds
        (self.layer as! AVPlayerLayer).videoGravity = AVLayerVideoGravityResizeAspectFill
        
        self.initComponents()
        self.initConstraints()
    }
    
    fileprivate func initComponents() {
        self.slider.addTarget(self, action: #selector(self.endScrubbing), for: .touchCancel)
        self.slider.addTarget(self, action: #selector(self.beginScrubbing), for: .touchDown)
        self.slider.addTarget(self, action: #selector(self.scrub), for: .touchDragInside)
        self.slider.addTarget(self, action: #selector(self.endScrubbing), for: .touchUpInside)
        self.slider.addTarget(self, action: #selector(self.endScrubbing), for: .touchUpOutside)
        self.slider.addTarget(self, action: #selector(self.scrub), for: .valueChanged)
        self.addSubview(self.slider)
        
        self.currentTimeLabel.text = "00:00"
        self.currentTimeLabel.textAlignment = .left
        self.currentTimeLabel.textColor = .white
        self.currentTimeLabel.font = UIFont.systemFont(ofSize: 12.0)
        self.addSubview(self.currentTimeLabel)
        
        self.durationTimeLabel.text = "--:--"
        self.durationTimeLabel.textAlignment = .right
        self.durationTimeLabel.textColor = .white
        self.durationTimeLabel.font = UIFont.systemFont(ofSize: 12.0)
        self.addSubview(self.durationTimeLabel)
        
        self.indicator.hidesWhenStopped = true
        self.indicator.activityIndicatorViewStyle = .white
        self.addSubview(self.indicator)
    }
    
    fileprivate func initConstraints() {
        self.slider.translatesAutoresizingMaskIntoConstraints = false
        self.currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.durationTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.indicator.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["slider": self.slider, "current": self.currentTimeLabel, "duration": self.durationTimeLabel, "indicator": self.indicator]
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[slider]-20-|", options: [], metrics: nil, views: views))
        self.addConstraint(NSLayoutConstraint.init(item: self.currentTimeLabel, attribute: .centerY, relatedBy: .equal, toItem: self.slider, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint.init(item: self.durationTimeLabel, attribute: .centerY, relatedBy: .equal, toItem: self.slider, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[current(35)]-8-[slider]-8-[duration(35)]-16-|", options: [], metrics: nil, views: views))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[indicator(30)]", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[indicator(30)]", options: [], metrics: nil, views: views))
        self.addConstraint(NSLayoutConstraint.init(item: self.indicator, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint.init(item: self.indicator, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
    }
    
    func showLoading() {
        self.indicator.startAnimating()
    }
    
    func hideLoading() {
        self.indicator.stopAnimating()
    }
    
    func enableSlider() {
        self.slider.isEnabled = true
    }
    
    func disableSlider() {
        self.slider.isEnabled = false
    }
    
    func syncSlider(value: Double) {
        self.slider.value = Float(value)
    }
    
    func syncTime(value: Double) {
        self.currentTimeLabel.text = String(value).timeIntervalToMMSSFormat(value)
    }
    
    func syncDuration(value: Double) {
        self.durationTimeLabel.text = String(value).timeIntervalToMMSSFormat(value)
    }
    
    dynamic fileprivate func scrub() {
        self.delegate?.didScrubbing()
    }
    
    dynamic fileprivate func beginScrubbing() {
        self.delegate?.didBeginScrubbing()
    }
    
    dynamic fileprivate func endScrubbing() {
        self.delegate?.didEndScrubbing()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
