//
//  MainPlayViewController.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/20.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit
import HWPanModal

class MainPlayViewController: BaseViewController, PageScrollViewDelegate {
    var model: BDSongModel?
    @IBOutlet weak var backgroudView: UIView!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var closedBtn: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    fileprivate var visualEffectView: UIVisualEffectView!
    fileprivate var pageScrollView: PageScrollView!
    //默认选中的位置
    fileprivate var selectIndex: Int = 0
    //播放页面
    fileprivate var playVC: PlayDetailViewController!
    //歌词页面
    fileprivate var lyricVC: LyricViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //适配iPhoneX以后机型
        if screenHeight >= 812 {
            topConstraint.constant = 20+24
        }
        //更新状态栏
        self.statusBarStyle = .lightContent
        self.addPanRecognizer()
        self.setUI()

        //音乐控制器
        playVC = PlayDetailViewController(nibName: "PlayDetailViewController", bundle: nil)
        playVC.model = model

        //歌词控制器
        lyricVC = LyricViewController(nibName: "LyricViewController", bundle: nil)
        
        pageScrollView = PageScrollView(frame: CGRect.zero, viewControllers: [playVC, lyricVC], parentVc: self)
        pageScrollView.delegate = self
        contentView.addSubview(pageScrollView)
        pageScrollView.snp.makeConstraints { (make) in
            make.right.top.left.bottom.equalTo(contentView)
        }
        //初始化选中的位置
        pageScrollView.selectIndex(index: selectIndex)
        
        NotificationCenter.addObserver(observer: self, selector: #selector(musicChange(_:)), name: .kMusicChange)
    }

    @objc fileprivate func musicChange(_ notification: Notification) {
        if let model = notification.object as? BDSongModel {
            self.model = model
            self.updateBackgroudImage()
            self.playVC.updateModel(model: model)
        }
    }
    
    func updateBackgroudImage() {
        //获取背景图
        if let str = model?.pic_big, let url = URL(string: str) {
            backgroundImageView.kf.setImage(with: url, placeholder: UIImage(named: "music_placeholder"), options: nil, progressBlock: nil) { (result) in
            }
        }
    }
    
    func addPanRecognizer() {
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(closePlay))
        swipeRecognizer.direction = .down
        self.view.addGestureRecognizer(swipeRecognizer)
    }
    
    @objc func closePlay() {
        self.dismiss(animated: true, completion: nil)
    }

    func setUI() {
        self.setupBackgroudImage()
        //关闭按钮
        closedBtn.setImage(UIImage(named: "arrow"), for: .normal)
        closedBtn.addTarget(self, action: #selector(closedAction(_:)), for: .touchUpInside)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], for: .normal)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], for: .selected)
        segmentedControl.addTarget(self, action: #selector(segmentClick(_:)), for: .valueChanged)
    }

    @objc fileprivate func segmentClick(_ sender: UISegmentedControl) {
        pageScrollView.selectIndex(index: sender.selectedSegmentIndex)
    }
    
    func setupBackgroudImage() {
        backgroundImageView.contentMode = .scaleAspectFill

        self.updateBackgroudImage()
        
        let effect = UIBlurEffect(style: .light)
        visualEffectView = UIVisualEffectView(effect: effect)
        visualEffectView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        if !visualEffectView.isDescendant(of: backgroundImageView) {
            backgroudView.addSubview(visualEffectView)
        }
        backgroundImageView.startTransitionAnimation()
    }
    
    //关闭
    @objc fileprivate func closedAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    deinit {
        print("\(self)释放了")
        NotificationCenter.removeObserver(observer: self, name: .kMusicChange)
    }
    
    //MARK:- HWPanModalPresentable
    override func topOffset() -> CGFloat {
        return 0
    }
    
    override func transitionDuration() -> TimeInterval {
        return 0.5
    }
    
    override func shouldRoundTopCorners() -> Bool {
        return false
    }
    
    override func showDragIndicator() -> Bool {
        return false
    }
    
    override func allowScreenEdgeInteractive() -> Bool {
        return false
    }
    //MARK:-PageScrollViewDelegate
    func pageDidScroll(to index: Int) {
        self.segmentedControl.selectedSegmentIndex = index
    }
}
