//
//  MainPlayViewController.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/20.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit

class MainPlayViewController: UIViewController {
    var model: MusicModel?
    
    @IBOutlet weak var backgroudView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var closedBtn: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    fileprivate var visualEffectView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addPanRecognizer()
        self.setUI()
                
        let pageVC = PlayDetailViewController(nibName: "PlayDetailViewController", bundle: nil)
        pageVC.view.frame = contentView.bounds
        pageVC.model = model
        self.addChild(pageVC)
        contentView.addSubview(pageVC.view)
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
    }

    func setupBackgroudImage() {
        backgroundImageView.contentMode = .scaleAspectFill
        //获取背景图
        if let str = model?.coverLarge, let url = URL(string: str) {
            backgroundImageView.kf.setImage(with: url, placeholder: UIImage(named: "music_placeholder"), options: nil, progressBlock: nil) { (result) in
            }
        }
        
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
}
