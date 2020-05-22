//
//  MainPlayViewController.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/20.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit
import HWPanModal

class MainPlayViewController: BaseViewController {
    var model: MusicModel?
    @IBOutlet weak var backgroudView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var closedBtn: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    fileprivate var visualEffectView: UIVisualEffectView!
    
    fileprivate var selectView: SelectScrollview!
    //默认选中的位置
    fileprivate var selectIndex: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        //更新状态栏
        self.statusBarStyle = .lightContent
        self.addPanRecognizer()
        self.setUI()

        //音乐控制器
        let playVC = PlayDetailViewController(nibName: "PlayDetailViewController", bundle: nil)
        playVC.model = model
        playVC.callback = { [weak self](value) in
            if let m = value as? MusicModel {
                self?.model = m
                self?.updateBackgroudImage()
            }
        }

        //歌词控制器
        let lyricVC = LyricViewController(nibName: "LyricViewController", bundle: nil)
        lyricVC.model = model

        selectView = SelectScrollview(frame: CGRect.zero, viewControllers: [playVC, lyricVC], parentVc: self)
        selectView.callback = { [weak self] (value) in
            if let index = value as? Int {
                self?.segmentedControl.selectedSegmentIndex = index
            }
        }
        contentView.addSubview(selectView)
        selectView.snp.makeConstraints { (make) in
            make.right.top.left.bottom.equalTo(contentView)
        }
        //初始化选中的位置
        selectView.selectIndex(index: selectIndex)
    }

    func updateBackgroudImage() {
        //获取背景图
        if let str = model?.coverLarge, let url = URL(string: str) {
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
        selectView.selectIndex(index: sender.selectedSegmentIndex)
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
        print("我被杀死了")
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
}

