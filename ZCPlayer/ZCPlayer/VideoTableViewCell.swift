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
    
    fileprivate let coverMask = UIView()
    fileprivate let coverView = UIImageView()
    fileprivate let button = UIImageView()
    fileprivate let circleView = UIView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .black
        
        self.addComponents()
        self.addConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    fileprivate func addComponents() {
        self.coverView.backgroundColor = .clear
        self.coverView.contentMode = .scaleAspectFit
        self.contentView.addSubview(self.coverView)
        
        self.coverMask.backgroundColor = UIColor.color(0x000000, alpha: 0.3)
        self.coverView.addSubview(self.coverMask)
        
        self.circleView.layer.cornerRadius = 30.0
        self.circleView.layer.masksToBounds = true
        self.circleView.backgroundColor = UIColor.color(0xFFFFFF, alpha: 0.4)
        self.coverView.addSubview(self.circleView)
        
        self.button.image = UIImage.init(named: "mini-play")
        self.button.tintColor = .white
        self.button.contentMode = .scaleAspectFit
        self.coverView.addSubview(self.button)
    }
    
    fileprivate func addConstraints() {
        self.coverView.translatesAutoresizingMaskIntoConstraints = false
        self.button.translatesAutoresizingMaskIntoConstraints = false
        self.circleView.translatesAutoresizingMaskIntoConstraints = false
        self.coverMask.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["cover": self.coverView, "button": self.button, "circle": self.circleView, "mask": self.coverMask]
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[cover]|", options: [], metrics: nil, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[cover]|", options: [], metrics: nil, views: views))
        
        self.coverView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[mask]|", options: [], metrics: nil, views: views))
        self.coverView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[mask]|", options: [], metrics: nil, views: views))
        
        self.coverView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[circle(60)]", options: [], metrics: nil, views: views))
        self.coverView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[circle(60)]", options: [], metrics: nil, views: views))
        self.coverView.addConstraint(NSLayoutConstraint.init(item: self.circleView, attribute: .centerX, relatedBy: .equal, toItem: self.coverView, attribute: .centerX, multiplier: 1.0, constant: -5.0))
        self.coverView.addConstraint(NSLayoutConstraint.init(item: self.circleView, attribute: .centerY, relatedBy: .equal, toItem: self.coverView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
        self.coverView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[button(30)]", options: [], metrics: nil, views: views))
        self.coverView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[button(30)]", options: [], metrics: nil, views: views))
        self.coverView.addConstraint(NSLayoutConstraint.init(item: self.button, attribute: .centerX, relatedBy: .equal, toItem: self.coverView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        self.coverView.addConstraint(NSLayoutConstraint.init(item: self.button, attribute: .centerY, relatedBy: .equal, toItem: self.coverView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
    }
    
    class func getCellSize() -> CGFloat {
        return UIScreen.main.bounds.size.height
    }
}

