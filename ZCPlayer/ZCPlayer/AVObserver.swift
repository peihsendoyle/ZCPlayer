//
//  observer.swift
//  KPCCTestPlayer
//
//  Created by Eric Richardson on 1/25/15.
//  Copyright (c) 2015 Eric Richardson. All rights reserved.
//

import Foundation
import AVFoundation

class AVObserver: NSObject {
    typealias CallbackClosure = ( (Statuses,String?,AnyObject?) -> Void )
    typealias OnceClosure = (String?,AnyObject?) -> Void
    
    fileprivate let callback: CallbackClosure
    fileprivate let player : AVPlayer
    
    fileprivate var once = [Statuses:[OnceClosure]]()
    fileprivate var on = [Statuses:[OnceClosure]]()
    
    enum Statuses {
        case /*Player*/ playerFailed, playerReady, playing, paused, /*PlayerItem*/ itemFailed, itemReady, stalled, timeJump, accessLog, errorLog, likelyToKeepUp, unlikelyToKeepUp, loadedTimeRanges
    }
    
    let _itemNotifications = [
        NSNotification.Name.AVPlayerItemPlaybackStalled,
        NSNotification.Name.AVPlayerItemTimeJumped,
        NSNotification.Name.AVPlayerItemNewAccessLogEntry,
        NSNotification.Name.AVPlayerItemNewErrorLogEntry
    ]
    
    init(player:AVPlayer, callback:@escaping CallbackClosure) {
        self.player = player
        self.callback = callback
        
        super.init()
        
        player.addObserver(self, forKeyPath:"status", options: [], context: nil)
        player.addObserver(self, forKeyPath:"rate", options: [], context: nil)
        
        self.startListenPlayerItem()
        
        // also subscribe to notifications from currentItem
        for n in self._itemNotifications {
            NotificationCenter.default.addObserver(self, selector:#selector(AVObserver.item_notification(_:)), name: n, object: player.currentItem)
        }
    }
    
    //----------
    
    func stopListenPlayerItem() {
        
        self.player.currentItem?.removeObserver(self, forKeyPath: "status")
        self.player.currentItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        self.player.currentItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        
        NotificationCenter.default.removeObserver(self)
        
        self.once.removeAll(keepingCapacity: false)
        self.on.removeAll(keepingCapacity: false)
    }
    
    func startListenPlayerItem() {
        player.currentItem?.addObserver(self, forKeyPath:"status", options: [], context: nil)
        player.currentItem?.addObserver(self, forKeyPath:"playbackLikelyToKeepUp", options: [], context: nil)
        player.currentItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: [], context: nil)
    }
    
    func stop() {
        self.player.removeObserver(self,forKeyPath:"status")
        self.player.removeObserver(self, forKeyPath:"rate")
        
        self.stopListenPlayerItem()
        
        NotificationCenter.default.removeObserver(self)
        
        self.once.removeAll(keepingCapacity: false)
        self.on.removeAll(keepingCapacity: false)
    }
    
    //----------
    
    func once(_ status:Statuses,callback:@escaping OnceClosure) -> Void {
        if (self.once[status] == nil) {
            self.once[status] = []
        }
        
        self.once[status]?.append(callback)
    }
    
    //----------
    
    func on(_ status:Statuses,callback:@escaping OnceClosure) -> Void {
        if (self.on[status] == nil) {
            self.on[status] = []
        }
        
        self.on[status]?.append(callback)
    }
    
    //----------
    
    fileprivate func _notify(_ status:Statuses,msg:String?,obj:AnyObject? = nil) -> Void {
        // always notify our callback
        self.callback(status,msg,obj)
        
        // repeat callbacks
        if let on_callbacks = self.on[status] {
            for c in on_callbacks {
                c(msg,obj)
            }
        }
        
        // one-time callbacks
        if let callbacks = self.once[status] {
            // alert the array of callbacks
            for c in callbacks {
                c(msg,obj)
            }
            
            self.once.removeValue(forKey: status)
        }
    }
    
    //----------
    
    func item_notification(_ notification:Notification) -> Void {
        switch notification.name {
        case NSNotification.Name.AVPlayerItemPlaybackStalled:
            self._notify(Statuses.stalled,msg: "Playback Stalled")
        case NSNotification.Name.AVPlayerItemTimeJumped:
            self._notify(Statuses.timeJump,msg: "Time jumped.")
        case NSNotification.Name.AVPlayerItemNewErrorLogEntry:
            let log:AVPlayerItemErrorLogEvent? = self.player.currentItem?.errorLog()?.events.last
            self._notify(Statuses.errorLog,msg: "Error",obj: log)
        case NSNotification.Name.AVPlayerItemNewAccessLogEntry:
            let log:AVPlayerItemAccessLogEvent? = self.player.currentItem?.accessLog()?.events.last
            self._notify(Statuses.accessLog,msg: "Access Log",obj: log)
        default:
            break
        }
    }
    
    //----------
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as! NSObject == self.player {
            switch keyPath! {
            case "status":
                switch (object! as AnyObject).status as AVPlayerStatus {
                case AVPlayerStatus.readyToPlay:
                    self._notify(Statuses.playerReady, msg: "Player Ready to Play")
                case AVPlayerStatus.failed:
                    self._notify(Statuses.playerFailed,msg: self.player.error?.localizedDescription, obj:self.player.error as AnyObject)
                default:
                    break
                }
            case "rate":
                switch (object! as AnyObject).rate as Float {
                case 0.0:
                    self._notify(Statuses.paused,msg: "Paused")
                case 1.0:
                    self._notify(Statuses.playing,msg: "Playing")
                default:
                    break
                }
            default:
                break
            }
        } else if (object as! NSObject) == self.player.currentItem {
            switch keyPath! {
            case "status":
                switch (object! as AnyObject).status as AVPlayerItemStatus {
                case AVPlayerItemStatus.readyToPlay:
                    self._notify(Statuses.itemReady,msg:"Item Ready to Play")
                case AVPlayerItemStatus.failed:
                    self._notify(Statuses.itemFailed, msg: self.player.currentItem?.error?.localizedDescription, obj: self.player.currentItem?.error as AnyObject)
                default:
                    NSLog("curItem gave unhandled status")
                }
            case "playbackLikelyToKeepUp":
                if self.player.currentItem?.isPlaybackLikelyToKeepUp == true {
                    self._notify(.likelyToKeepUp, msg: "currentItem says playback is likely to keep up")
                } else {
                    self._notify(.unlikelyToKeepUp, msg: "currentItem says playback is unlikely to keep up")
                }
            case "loadedTimeRanges":
                self._notify(.loadedTimeRanges, msg: "currentItem loaded more time ranges")
            default:
                break
            }
            
        } else {
            // not sure...
        }
    }
}
