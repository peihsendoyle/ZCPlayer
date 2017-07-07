//
//  PlayerControllerManager.swift
//  ZCPlayer
//
//  Created by Doyle Illusion on 7/5/17.
//  Copyright © 2017 Zyncas Technologies. All rights reserved.
//

import Foundation

class PlayerControllerManager {
    static let shared = PlayerControllerManager()
    
    var dict : [String : PlayerController] = [:]
}
