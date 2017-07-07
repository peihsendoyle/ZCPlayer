//
//  PlayerController.swift
//  ZCPlayer
//
//  Created by Doyle Illusion on 7/4/17.
//  Copyright © 2017 Zyncas Technologies. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class PlayerController : NSObject {
    
    fileprivate var mRestoreAfterScrubbingRate: Float = 0.0
    
    fileprivate var player : AVPlayer!
    fileprivate var playerItem : AVPlayerItem!
    fileprivate var observer : AVObserver?
    
    lazy var playerView : PlayerView = {
        let view = PlayerView()
        view.delegate = self
        (view.layer as! AVPlayerLayer).videoGravity = AVLayerVideoGravityResizeAspect
        return view
    }()
    
    fileprivate var currentTime : Double = 0.0
    fileprivate var durationTime : Double = 0.0
    fileprivate var timeObserver : Any?
    fileprivate var isSeeking = false {
        didSet {
            self.playerView.isSeeking = self.isSeeking
        }
    }
    
    required init(url: URL) {
        super.init()
        
        self.playerItem = AVPlayerItem(url: url)
        self.player = AVPlayer(playerItem: self.playerItem)
        
        self.addLifeObservers()
        
        (self.playerView.layer as! AVPlayerLayer).player = self.player
        
        PlayerControllerManager.shared.dict[url.absoluteString] = self
    }
    
    func addLifeObservers() {
        self.observer = AVObserver(player: self.player) { (status, message, object) in
            switch status {
            case .playerFailed:
                self.syncScrubber()
                self.disableScrubber()
                self.removePlayerViewFromSuperview()
                print("Player failed. We don't have logic to recover from this.")
            case .itemFailed:
                self.removePlayerTimeObserver()
                self.syncScrubber()
                self.disableScrubber()
                self.removePlayerViewFromSuperview()
                print("Item failed. We don't have logic to recover from this.")
            case .stalled:
                print("Playback stalled at \(self.player.currentItem!.currentDate() ?? Date())")
            case .itemReady:
                self.initScrubberTimer()
                self.enableScrubber()
            case .accessLog:
                print("New Access log")
            case .errorLog:
                print("New Error log")
            case .playing:
                print("Status: Playing")
            case .paused:
                print("Status: Paused")
            case .likelyToKeepUp:
                self.playerView.hideLoading()
                self.playerView.hideContainerView()
            case .unlikelyToKeepUp:
                self.playerView.showLoading()
                self.playerView.showContainerView()
            case .timeJump:
                print("Player reports that time jumped.")
            case .loadedTimeRanges:
                self.playerView.slider.setProgress(progress: self.getAvailableTime(), animated: true)
            default:
                break
            }
        }
    }
    
    func addPlayerViewToSuperview(view: UIView) {
        if self.player.currentItem == nil {
            self.player.replaceCurrentItem(with: self.playerItem)
        }
        
        guard let player = self.player else { return }
        //player.seek(to: CMTimeMakeWithSeconds(0.35, 1000), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        player.play()
        
        if view.subviews.contains(self.playerView) { return }
        
        self.playerView.frame = view.bounds
        view.addSubview(self.playerView)
    }
    
    func removePlayerViewFromSuperview() {
        self.playerView.removeFromSuperview()
        
        guard let player = self.player else { return }
        player.pause()
        self.playerView.hideContainerView()
        
        self.player.replaceCurrentItem(with: nil)
    }
    
    func initScrubberTimer() {
        guard let playerDuration = self.getItemDuration() else { return }
        self.durationTime = CMTimeGetSeconds(playerDuration)
        self.playerView.syncDuration(value: self.durationTime)
        
        var interval: Double = 0.1
        if self.durationTime.isFinite { interval = 0.5 * self.durationTime / Double(self.playerView.slider.bounds.width) }
        self.timeObserver = self.player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(interval, Int32(NSEC_PER_SEC)), queue: nil, using: { [weak self] (time: CMTime) -> Void in
            guard let `self` = self else { return }
            self.syncScrubber()
        })
    }
    
    func syncScrubber() {
        if self.durationTime.isFinite {
            let minValue = self.playerView.slider.minimumValue
            let maxValue = self.playerView.slider.maximumValue
            let time = CMTimeGetSeconds(self.player.currentTime())
            guard time.isFinite else { return }
            self.playerView.syncTime(value: time)
            self.playerView.syncSlider(value: Double((maxValue - minValue) * Float(time) / Float(self.durationTime) + minValue))
        }
    }
    
    func beginScrubbing() {
        mRestoreAfterScrubbingRate = self.player.rate
        self.player.rate = 0.0
        
        self.removePlayerTimeObserver()
    }
    
    func scrub(_ sender: AnyObject) {
        if (sender is UISlider) && !self.isSeeking {
            self.isSeeking = true
            let slider = sender

            if self.durationTime.isFinite {
                let minValue: Float = slider.minimumValue
                let maxValue: Float = slider.maximumValue
                let value: Float = slider.value
                let time = (self.durationTime * Double((value - minValue) / (maxValue - minValue)))
                self.playerView.syncTime(value: time)
                self.player.seek(to: CMTimeMakeWithSeconds(time, Int32(NSEC_PER_SEC)), completionHandler: {(finished: Bool) -> Void in
                    DispatchQueue.main.async(execute: { [weak self] () -> Void in
                        self?.isSeeking = false
                    })
                })
            }
        }
    }
    
    func endScrubbing() {
        guard timeObserver == nil else { return }
        
        if mRestoreAfterScrubbingRate != 0.0 {
            self.player.rate = mRestoreAfterScrubbingRate
            mRestoreAfterScrubbingRate = 0.0
            //self.isPlay = true
        }
        
        if self.durationTime.isFinite {
            let width: CGFloat = self.playerView.slider.bounds.width
            let tolerance: Double = 0.5 * self.durationTime / Double(width)
            self.timeObserver = self.player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(tolerance, Int32(NSEC_PER_SEC)), queue: nil, using: { [weak self] (time: CMTime) -> Void in
                guard let `self` = self else { return }
                self.syncScrubber()
            })
        }
    }
    
    func isScrubbing() -> Bool {
        return mRestoreAfterScrubbingRate != 0.0
    }
    
    func enableScrubber() {
        self.playerView.enableSlider()
    }
    
    func disableScrubber() {
        self.playerView.disableSlider()
    }
    
    func toggle(isPlay: Bool) {
        isPlay ? self.player.pause() : self.player.play()
    }
    
    func getAvailableTime() -> Float {
        let timeRange = self.playerItem.loadedTimeRanges[0].timeRangeValue
        let startSeconds = CMTimeGetSeconds(timeRange.start)
        let durationSeconds = CMTimeGetSeconds(timeRange.duration)
        let result = startSeconds + durationSeconds
        return Float(result)
    }
    
    fileprivate func getItemDuration() -> CMTime? {
        guard let playerItem = self.playerItem else { return nil }
        return playerItem.duration
    }
    
    func removePlayerTimeObserver() {
        guard timeObserver != nil else { return }
        
        self.player.removeTimeObserver(timeObserver!)
        self.timeObserver = nil
    }
    
    func removeLifeObserver() {
        self.observer?.stop()
        self.observer = nil
    }
}

extension PlayerController : PlayerViewDelegate {
    func didTouchToggleButton(isPlay: Bool) {
        self.toggle(isPlay: isPlay)
    }
    
    func didScrubbing() {
        self.scrub(self.playerView.slider)
    }
    
    func didBeginScrubbing() {
        self.beginScrubbing()
    }
    
    func didEndScrubbing() {
        self.endScrubbing()
    }
}
