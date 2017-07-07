//
//  VideoTableViewCell.swift
//  ZCPlayer
//
//  Created by Doyle Illusion on 7/5/17.
//  Copyright © 2017 Zyncas Technologies. All rights reserved.
//

import UIKit
import AVFoundation

class VideoTableViewCell : UITableViewCell {
    
    var coverImage : UIImage! {
        didSet {
            self.coverView.image = self.coverImage
        }
    }
    
    fileprivate let coverView = UIImageView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .black
        
        self.addComponents()
        self.addConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    fileprivate func addComponents() {
        self.coverView.contentMode = .scaleAspectFit
        self.contentView.addSubview(self.coverView)
    }
    
    fileprivate func addConstraints() {
        self.coverView.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["cover": self.coverView]
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[cover]|", options: [], metrics: nil, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[cover]|", options: [], metrics: nil, views: views))
    }
    
    class func getCellSize() -> CGFloat {
        return UIScreen.main.bounds.size.height
    }
}

