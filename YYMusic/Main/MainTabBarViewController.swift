//
//  MainTabBarViewController.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/29.
//  Copyright © 2020 haoge. All rights reserved.
//
import UIKit

class MainTabBarViewController: UITabBarController {
    var playerBottomView = WHPlayerBottomView.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        self.tabBar.backgroundColor = .white
        self.tabBar.backgroundImage = UIImage()
        
        //修改tabbar上线的颜色
        let line = UIView(frame: CGRect(x: 0, y: -0.5, width: screenWidth, height: 0.5))
        line.backgroundColor = kLineColor
        self.tabBar.insertSubview(line, at: 0)
        
        self.view.addSubview(playerBottomView)
        playerBottomView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.view)
            make.height.equalTo(65)
            make.bottom.equalTo(self.tabBar.snp.top).offset(-0.5)
        }
    }
 
    // MARK: - UIApplication
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    deinit {
        //释放播放器相关
        PlayerManager.shared.releasePlayer()
    }
}
