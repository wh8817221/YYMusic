//
//  MainViewController.swift
//  chapiaotong
//
//  Created by 王浩 on 2018/5/22.
//  Copyright © 2018年 王浩. All rights reserved.

import UIKit

enum BadgeStyle {
    case dot
    case number
}

class MainViewController: UITabBarController {
    
    fileprivate var badges = [Int: UILabel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.barTintColor = .white
        self.tabBar.backgroundColor = .white
        
        //修改tabbar上线的颜色
//        let line = UIView(frame: CGRect(x: 0, y: -0.5, width: screenWidth, height: 0.5))
//        line.backgroundColor = .gray
//        self.tabBar.insertSubview(line, at: 0)
        
    }
    
    // MARK: - UIApplication
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    deinit {
        PlayerManager.shared.releasePlayer()
    }
}
