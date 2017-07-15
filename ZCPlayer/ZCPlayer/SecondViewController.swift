//
//  SecondViewController.swift
//  ZCPlayer
//
//  Created by Doyle Illusion on 7/8/17.
//  Copyright © 2017 Zyncas Technologies. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    var isInTransition = false
    
    let urls = ["https://yosing.vn/master/files/records/records/record_record_59522512a7acd.mp4"]
    
    let image = UIImage.init(named: "cover.jpg")
    
    let tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height), style: .plain)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = .white
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
        self.tableView.allowsSelection = false
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(VideoTableViewCell.self, forCellReuseIdentifier: "videoCell")
        
        self.view.addSubview(self.tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.isInTransition = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.isInTransition = false
        
        let cells = self.tableView.visibleCells
        
        for cell in cells {
            guard let videoCell = cell as? VideoTableViewCell else { continue }
            guard let indexPath = self.tableView.indexPath(for: videoCell) else { continue }
            if self.isFullyVisible(cell: videoCell, scrollView: self.tableView) {
                let url = self.urls[indexPath.row]
                if let controller = PlayerControllerManager.shared.dict[url] {
                    controller.addPlayerViewToSuperview(view: videoCell.contentView)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.isInTransition = true
        
        let cells = self.tableView.visibleCells
        
        for cell in cells {
            guard let videoCell = cell as? VideoTableViewCell else { continue }
            guard let indexPath = self.tableView.indexPath(for: videoCell) else { continue }
            
            let url = self.urls[indexPath.row]
            if let controller = PlayerControllerManager.shared.dict[url] {
                controller.removePlayerViewFromSuperview()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.isInTransition = false
    }
}

extension SecondViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "videoCell", for: indexPath) as! VideoTableViewCell
        cell.coverImage = self.image
        let url = self.urls[indexPath.row]
        
        if let controller = PlayerControllerManager.shared.dict[url] {
            controller.addPlayerViewToSuperview(view: cell.contentView)
        } else {
            let controller = PlayerController.init(url: URL.init(string: url)!)
            controller.addPlayerViewToSuperview(view: cell.contentView)
        }
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard self.isInTransition == false else { return }
        
        let cells = self.tableView.visibleCells
        
        for cell in cells {
            guard let videoCell = cell as? VideoTableViewCell else { continue }
            guard let indexPath = self.tableView.indexPath(for: videoCell) else { continue }
            
            if self.isFullyVisible(cell: videoCell, scrollView: scrollView) {
                let url = self.urls[indexPath.row]
                if let controller = PlayerControllerManager.shared.dict[url] {
                    controller.addPlayerViewToSuperview(view: cell.contentView)
                }
            } else {
                let url = self.urls[indexPath.row]
                if let controller = PlayerControllerManager.shared.dict[url] {
                    controller.removePlayerViewFromSuperview()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    fileprivate func isFullyVisible(cell: VideoTableViewCell, scrollView: UIScrollView) -> Bool {
        let relativeToScrollViewRect = cell.convert(cell.bounds, to: scrollView)
        let visibleScrollViewRect = CGRect(x: CGFloat(scrollView.contentOffset.x), y: CGFloat(scrollView.contentOffset.y), width: CGFloat(scrollView.bounds.size.width), height: CGFloat(scrollView.bounds.size.height))
        
        return visibleScrollViewRect.contains(CGPoint.init(x: relativeToScrollViewRect.midX, y: relativeToScrollViewRect.midY))
    }
}

extension SecondViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200.0
    }
}
