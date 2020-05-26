//
//  MVPlayViewController.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/26.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit
import ZFPlayer
let kVideoCover = "https://upload-images.jianshu.io/upload_images/635942-14593722fe3f0695.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240"
class MVPlayViewController: UIViewController {

    var cover: String?
    var fileTitle: String?
    var mvFileBase: MVFilesBase?
    
    fileprivate var zfPlayer: ZFPlayerController!
    fileprivate lazy var controlView: ZFPlayerControlView = {
        let cv = ZFPlayerControlView()
        cv.fastViewAnimated = true
        cv.autoHiddenTimeInterval = 5
        cv.autoFadeTimeInterval = 0.5
        cv.prepareShowLoading = true
        cv.prepareShowControlView = true
        return cv
    }()
    fileprivate lazy var containerView: UIImageView = {
        let iv = UIImageView()
        let image = ZFUtilities.image(with: UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1), size: CGSize(width: 1, height: 1))
        iv.setImageWithURLString(kVideoCover, placeholder: image)
        return iv
    }()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        self.loadZFPlayer()
        
    }

    func loadZFPlayer() {
        self.view.addSubview(containerView)
        let playerManager = ZFAVPlayerManager()
        zfPlayer = ZFPlayerController(playerManager: playerManager, containerView: containerView)
        zfPlayer.controlView = controlView
        //设置退到后台继续播放
        zfPlayer.pauseWhenAppResignActive = false
        zfPlayer.orientationWillChange = { (player, isFullScreen) in
        }
        //播放完成
        zfPlayer.playerDidToEnd = { (asset) in
            
        }
        if let file = self.mvFileBase {
           zfPlayer.assetURL = URL(string: (file.chaoqing?.file_link)!)!
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        zfPlayer.isViewControllerDisappear = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        zfPlayer.isViewControllerDisappear = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let x: CGFloat = 0
        let y: CGFloat = self.navigationController?.navigationBar.frame.maxY ?? 0
        let w: CGFloat = self.view.frame.width
        let h: CGFloat = w*9/16
        containerView.frame = CGRect(x: x, y: y, width: w, height: h)
    }
}
