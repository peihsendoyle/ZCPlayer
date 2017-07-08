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
    
    func didTouchToggleButton(isPlay: Bool)
}

class PlayerView: UIView {
    
    weak var delegate : PlayerViewDelegate?
    
    fileprivate let indicator = UIActivityIndicatorView()
    fileprivate let containerView = UIView()
    fileprivate let currentTimeLabel = UILabel()
    fileprivate let durationTimeLabel = UILabel()
    fileprivate var gestureRecognizer : UITapGestureRecognizer!
    let slider = BufferSlider()
    fileprivate let button = UIButton()
    
    fileprivate var timer = Timer()
    
    override class var layerClass: AnyClass { return AVPlayerLayer.self }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.black
        
        (self.layer as! AVPlayerLayer).frame = self.bounds
        (self.layer as! AVPlayerLayer).videoGravity = AVLayerVideoGravityResizeAspectFill
        
        self.initComponents()
        self.initConstraints()
    }
    
    fileprivate func initComponents() {
        self.gestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.touchedPlayerView))
        self.addGestureRecognizer(self.gestureRecognizer)
        
        self.indicator.hidesWhenStopped = true
        self.indicator.activityIndicatorViewStyle = .white
        self.addSubview(self.indicator)
        
        self.containerView.backgroundColor = .clear
        self.containerView.isHidden = true
        self.addSubview(self.containerView)
        
        self.button.setImage(UIImage.init(named: "mini-play"), for: .selected)
        self.button.setImage(UIImage.init(named: "mini-pause"), for: .normal)
        self.button.isSelected = false
        self.button.tintColor = .white
        self.button.addTarget(self, action: #selector(self.touchedButton), for: .touchUpInside)
        self.containerView.addSubview(self.button)
        
        self.slider.addTarget(self, action: #selector(self.endScrubbing), for: .touchCancel)
        self.slider.addTarget(self, action: #selector(self.beginScrubbing), for: .touchDown)
        self.slider.addTarget(self, action: #selector(self.scrub), for: .touchDragInside)
        self.slider.addTarget(self, action: #selector(self.endScrubbing), for: .touchUpInside)
        self.slider.addTarget(self, action: #selector(self.endScrubbing), for: .touchUpOutside)
        self.slider.addTarget(self, action: #selector(self.scrub), for: .valueChanged)
        self.containerView.addSubview(self.slider)
        
        self.currentTimeLabel.text = "00:00"
        self.currentTimeLabel.textAlignment = .left
        self.currentTimeLabel.textColor = .white
        self.currentTimeLabel.font = UIFont.systemFont(ofSize: 12.0)
        self.containerView.addSubview(self.currentTimeLabel)
        
        self.durationTimeLabel.text = "--:--"
        self.durationTimeLabel.textAlignment = .right
        self.durationTimeLabel.textColor = .white
        self.durationTimeLabel.font = UIFont.systemFont(ofSize: 12.0)
        self.containerView.addSubview(self.durationTimeLabel)
    }
    
    fileprivate func initConstraints() {
        self.indicator.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        self.slider.translatesAutoresizingMaskIntoConstraints = false
        self.currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.durationTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.button.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["slider": self.slider, "current": self.currentTimeLabel, "duration": self.durationTimeLabel, "indicator": self.indicator, "containerView": self.containerView, "button": self.button]
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[indicator(30)]", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[indicator(30)]", options: [], metrics: nil, views: views))
        self.addConstraint(NSLayoutConstraint.init(item: self.indicator, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint.init(item: self.indicator, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[containerView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[containerView]|", options: [], metrics: nil, views: views))
        
        self.containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[slider]-20-|", options: [], metrics: nil, views: views))
        self.containerView.addConstraint(NSLayoutConstraint.init(item: self.currentTimeLabel, attribute: .centerY, relatedBy: .equal, toItem: self.slider, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        self.containerView.addConstraint(NSLayoutConstraint.init(item: self.durationTimeLabel, attribute: .centerY, relatedBy: .equal, toItem: self.slider, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        self.containerView.addConstraint(NSLayoutConstraint.init(item: self.button, attribute: .centerY, relatedBy: .equal, toItem: self.slider, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        self.containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[button(15)]", options: [], metrics: nil, views: views))
        self.containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[button(15)]-8-[current(35)]-8-[slider]-8-[duration(35)]-16-|", options: [], metrics: nil, views: views))
    }
    
    fileprivate dynamic func touchedPlayerView() {
        if self.containerView.isHidden == true {
            self.showContainerView()
        } else {
            self.hideContainerView()
        }
    }
    
    dynamic func hideContainerView() {
        guard self.containerView.isHidden == false else { return }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.containerView.alpha = 0
        }, completion: { _ in
            self.containerView.isHidden = true
        })
    }
    
    func showContainerView() {
        guard self.containerView.isHidden == true else { return }
        
        self.containerView.isHidden = false
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: { 
            self.containerView.alpha = 1
        }, completion: { _ in
            self.timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.hideContainerView), userInfo: nil, repeats: false)
        })
    }
    
    fileprivate dynamic func touchedButton() {
        self.button.isSelected = !self.button.isSelected
        self.delegate?.didTouchToggleButton(isPlay: self.button.isSelected)
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
        self.timer.invalidate()
        self.delegate?.didBeginScrubbing()
    }
    
    dynamic fileprivate func endScrubbing() {
        self.timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.hideContainerView), userInfo: nil, repeats: false)
        self.delegate?.didEndScrubbing()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
