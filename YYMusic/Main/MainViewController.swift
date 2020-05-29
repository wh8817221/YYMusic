//
//  MainViewController.swift
//  chapiaotong
//
//  Created by 王浩 on 2018/5/22.
//  Copyright © 2018年 王浩. All rights reserved.

import UIKit

class MainViewController: UITabBarController {
    
    var model: MusicModel? {
        didSet {
           playButton.model = model
        }
    }
    // 圆半径
    fileprivate var radius:CGFloat = 60/2
    // standOutHeight 突出高度 16
    let standOutHeight: CGFloat = 16
    var playButton: PlayButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        self.tabBar.backgroundImage = UIImage()
        self.tabBar.shadowImage = UIImage()
        self.tabBar.insertSubview(self.drawTabbarBgImageView(), at: 0)
        self.tabBar.isOpaque = true
        setupTabBar(image: "big_play_button")
        
        if let music = UserDefaultsManager.shared.unarchive(key: CURRENTMUSIC) as? MusicModel {
            self.model = music
        }
        
        NotificationCenter.addObserver(observer: self, selector: #selector(musicChange(_:)), name: .kMusicChange)
        NotificationCenter.addObserver(observer: self, selector: #selector(musicTimeInterval), name: .kMusicTimeInterval)
    }
    
    @objc fileprivate func musicChange(_ notification: Notification) {
        if let model = notification.object as? MusicModel {
            self.model = model
        }
    }
    
    @objc fileprivate func musicTimeInterval() {
        let currentTime = PlayerManager.shared.getCurrentTime()
        let totalTime = PlayerManager.shared.getTotalTime()
        //更新进度圆环 如果当前时间=总时长 就直接下一首(或者单曲循环)
        let cT = Double(currentTime ?? "0")
        let dT = Double(totalTime ?? "0")
        if let ct = cT, let dt = dT, dt > 0.0 {
            playButton.progress = CGFloat(ct/dt)
            if CGFloat(ct/dt) >= 1.0 {
                playButton.progress = 0.0
            }
        }

    }
    
    @objc fileprivate func playAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        playButton.startAnimation()
        if let model = self.model {
            let nav = self.viewControllers?[self.selectedIndex] as? BaseNavigationViewController
            let vc = nav?.visibleViewController
            PlayerManager.shared.presentPlayController(vc: vc, model: model)
        } else {
            CustomHUD.showHideTextHUD("您暂未选择播放的歌曲")
        }
    }
    
    fileprivate func setupTabBar(image: String) {
        
        guard let vcs = self.viewControllers else {
            return
        }
      
        for (idx,vc) in vcs.enumerated() {
            if idx == 1 {
                vc.tabBarItem.isEnabled = false
                vc.tabBarItem.title = ""
                vc.tabBarItem.image = nil
            }
        }

        let width: CGFloat = 50
        let height: CGFloat = 50
    
        playButton = PlayButton()
        playButton.frame = CGRect(x: (screenWidth-width)/2, y: radius - (self.tabBar.frame.height/2) - standOutHeight, width: width, height: height)
        playButton.layer.cornerRadius = 25
        playButton.layer.masksToBounds = true
        
        self.tabBar.addSubview(playButton)
        self.tabBar.bringSubviewToFront(playButton)
        playButton.addTarget(self, action: #selector(playAction(_ :)), for: .touchUpInside)
    }
    
    
    
    // 画背景的方法，返回 Tabbar的背景
    fileprivate func drawTabbarBgImageView() -> UIImageView {
        let allFloat = (pow(radius, 2)-pow((radius-standOutHeight), 2))
        let ww = sqrt(allFloat)
        let imageView = UIImageView(frame: CGRect(x: 0, y: -standOutHeight, width: screenWidth, height: self.tabBar.frame.height+tabHeight+standOutHeight))
        
        let size = imageView.frame.size
        let layer = CAShapeLayer()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: size.width/2 - ww, y: standOutHeight))
        let angleH = 0.5*((radius-standOutHeight)/radius)
        let startAngle = (1+angleH)*(CGFloat(Double.pi))
        let endAngle = (2-angleH)*(CGFloat(Double.pi))
        //画弧
        path.addArc(withCenter: CGPoint(x: (size.width)/2, y: radius), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        // 开始画弧以外的部分
        path.addLine(to: CGPoint(x: size.width/2+ww, y: standOutHeight))
        path.addLine(to: CGPoint(x: size.width, y: standOutHeight))
        path.addLine(to: CGPoint(x: size.width, y: size.height))
        path.addLine(to: CGPoint(x: 0, y: size.height))
        path.addLine(to: CGPoint(x: 0, y: standOutHeight))

        path.addLine(to: CGPoint(x: size.width/2-ww, y: standOutHeight))
        layer.path = path.cgPath
        layer.fillColor = UIColor.white.cgColor
        //边框线条的颜色
        layer.strokeColor = UIColor(white: 0.765, alpha: 1.0).cgColor
        //边框线条的宽
        layer.lineWidth = 0.5
        // 在要画背景的view上 addSublayer:
        imageView.layer.addSublayer(layer)
        
        return imageView
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
