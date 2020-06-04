//
//  WHPlayerBottomView.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/18.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit
import Kingfisher
import MarqueeLabel

class WHPlayerBottomView: UIView {
    static let shared = WHPlayerBottomView()
    var musicModel: BDSongModel?
    /*圆环进度指示器*/
    var progress: CGFloat = 0.0 {
        didSet{
            if progress > 1 || progress < 0 { return }
            arcLayer.removeFromSuperlayer()
            drawCircle(rect: playAndPauseBtn.frame, progress: progress)
        }
    }

    /*播放暂停按钮*/
    var playAndPauseBtn: UIButton!
    /**播放的背景*/
    var contentView: UIControl!
    var currentMusicView: MusicView?
    fileprivate lazy var arcLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = kThemeColor.cgColor
        layer.lineWidth = 2.5
        layer.lineCap = CAShapeLayerLineCap(rawValue: "round")
        return layer
    }()
    fileprivate var playerBarH: CGFloat = 65.0
    //加载中转菊花
    fileprivate lazy var indicatorView: UIActivityIndicatorView = {
        let iv = UIActivityIndicatorView(style: .whiteLarge)
        iv.frame = self.playAndPauseBtn.frame
        iv.color = kThemeColor
        iv.hidesWhenStopped = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
        contentView = UIControl()
        contentView.backgroundColor = .white
        self.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.bottom.equalTo(self.snp.bottom)
            make.height.equalTo(48)
        }
        
        playAndPauseBtn = UIButton(type: .custom)
        playAndPauseBtn.setImage(UIImage(named: "icons_play_music1"), for: .normal)
        playAndPauseBtn.setImage(UIImage(named: "icons_play_music1"), for: .disabled)
        playAndPauseBtn.setImage(UIImage(named: "icons_stop_music1"), for: .selected)
        playAndPauseBtn.addTarget(self, action: #selector(playAndPause(_:)), for: .touchUpInside)
        contentView.addSubview(playAndPauseBtn)
        playAndPauseBtn.snp.makeConstraints { (make) in
            make.height.width.equalTo(35)
            make.right.equalTo(contentView.snp.right).offset(-10)
            make.centerY.equalTo(contentView.snp.centerY)
        }
        
        drawCircle(rect: playAndPauseBtn.frame, progress: 0.0)
        //注册监听音乐模型改变
        NotificationCenter.addObserver(observer: self, selector: #selector(musicChange(_:)), name: .kMusicChange)
        //注册监听歌曲时间变化
        NotificationCenter.addObserver(observer: self, selector: #selector(musicTimeInterval), name: .kMusicTimeInterval)
        //注册监听歌曲播放状态--暂停/播放
        NotificationCenter.addObserver(observer: self, selector: #selector(playStatusChange(_:)), name: .kReloadPlayStatus)
        //注册监听歌曲加载状态
        NotificationCenter.addObserver(observer: self, selector: #selector(musicLoadStatus(_:)), name: .kMusicLoadStatus)
        
        //获取上次播放存储的歌曲
        if let music = UserDefaultsManager.shared.unarchive(key: CURRENTMUSIC) as? BDSongModel {
            self.musicModel = music
        }
        self.updateMusic(model: self.musicModel)
        
        let scrollView = InfiniteCycleView()
        scrollView.delegate = self
        self.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalTo(self)
            make.right.equalTo(self.snp.right).offset(-55)
        }
    }
    
    //监听歌曲播放状态
    @objc fileprivate func musicLoadStatus(_ sender: Notification) {
        if let status = sender.object as? MusicLoadStatus {
            switch status {
            case .loadding:
                self.progress = 0
                self.playAndPauseBtn.isEnabled = false
                self.playAndPauseBtn.isSelected = false
                self.playAndPauseBtn.addSubview(indicatorView)
                self.playAndPauseBtn.bringSubviewToFront(indicatorView)
                indicatorView.snp.makeConstraints({$0.center.equalTo(self.playAndPauseBtn)})
                indicatorView.startAnimating()
            case .readyToPlay:
                self.playAndPauseBtn.isEnabled = true
                self.playAndPauseBtn.isSelected = true
                indicatorView.removeFromSuperview()
                indicatorView.stopAnimating()
            default:
                break
            }
        }
    }
    
    //MARK:-show
    func show() {
        self.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: playerBarH)
        UIView.animate(withDuration: 0.25, animations: {
            self.frame = CGRect(x: 0, y: screenHeight-49-self.playerBarH, width: screenWidth, height: self.playerBarH)
        })
        
    }
    //MARK:-hidden
    func hidden() {
        self.frame = CGRect(x: 0, y: screenHeight-49-self.playerBarH, width: screenWidth, height: playerBarH)
        UIView.animate(withDuration: 0.25, animations: {
            self.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: self.playerBarH)
        })
    }
    
    @objc fileprivate func musicTimeInterval() {
        let currentTime = PlayerManager.shared.getCurrentTime()
        let totalTime = PlayerManager.shared.getTotalTime()
        let cT = Double(currentTime ?? "0")
        let dT = Double(totalTime ?? "0")
        if let ct = cT, let dt = dT, dt > 0.0 {
            self.progress = CGFloat(ct/dt)
            if CGFloat(ct/dt) >= 1.0 {
                self.progress = 0.0
            }
        }
    }

    @objc fileprivate func musicChange(_ notification: Notification) {
        if let model = notification.object as? BDSongModel {
            self.musicModel = model
            playAndPauseBtn.isSelected = true
            self.currentMusicView?.model = model
            self.currentMusicView?.startAnimation()
        }
    }
    
    @objc fileprivate func playStatusChange(_ notification: Notification) {
        if let isPlay = notification.object as? Bool {
            playAndPauseBtn.isSelected = isPlay
            if isPlay {
                self.currentMusicView?.startAnimation()
            } else {
                self.currentMusicView?.stopAnimation()
            }
        }
    }
    
    func updateMusic(model: BDSongModel?) {
        self.musicModel = model
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //绘制进度圆环
    fileprivate func drawCircle(rect: CGRect, progress: CGFloat) {
        let xCenter = rect.size.width * 0.5
        let yCenter = rect.size.height * 0.5
        let radius = rect.size.width/2-2
        //绘制环形进度环
        // - M_PI * 0.5为改变初始位置
        let to = -CGFloat(Double.pi)*0.5 + progress * CGFloat(Double.pi)*2
        
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: xCenter, y: yCenter), radius: CGFloat(radius), startAngle: -CGFloat(Double.pi)*0.5, endAngle: to, clockwise: true)
        arcLayer.path = path.cgPath  //46,169,230
        playAndPauseBtn.layer.addSublayer(arcLayer)
    }
    
    @objc func playAndPause(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if !sender.isSelected {
            tapPlayButton(isPlay: false)
        } else {
            tapPlayButton(isPlay: true)
        }
    }
    
    //继续播放
    func playActive() {
        PlayerManager.shared.playerPlay()
    }
    
    //暂停播放
    func pauseActive() {
        PlayerManager.shared.playerPause()
    }
    
    //加载播放
    func loadMusic(model: BDSongModel) {
        //每次切换都要清空一下进度
        self.progress = 0.0
        self.musicModel = model
        PlayerManager.shared.playMusic(model: model)
    }
    
    //MARK:-播放按钮
    func tapPlayButton(isPlay: Bool) {
        self.playAndPauseBtn.isSelected = isPlay
        //第一次点击底部播放按钮并且还是未在播放状态
        if PlayerManager.shared.isFristPlayerPauseBtn && !PlayerManager.shared.isPlaying {
            PlayerManager.shared.isFristPlayerPauseBtn = false
            if let music = UserDefaultsManager.shared.unarchive(key: CURRENTMUSIC) as? BDSongModel {
                loadMusic(model: music)
            } else {
                //归档没找到默认播放第一个
                if let model = PlayerManager.shared.currentModel {
                    loadMusic(model: model)
                }
            }
        } else {
            PlayerManager.shared.isFristPlayerPauseBtn = false
            if isPlay {
                playActive()
            } else {
                pauseActive()
            }
        }
    }

    deinit {
        NotificationCenter.removeObserver(observer: self, name: .kMusicChange)
        NotificationCenter.removeObserver(observer: self, name: .kMusicTimeInterval)
        NotificationCenter.removeObserver(observer: self, name: .kReloadPlayStatus)
        NotificationCenter.removeObserver(observer: self, name: .kMusicLoadStatus)
        
    }
}

extension WHPlayerBottomView: InfiniteCycleViewDelegate {
    
    func infiniteCycleView(_ scrollView: InfiniteCycleView) -> UIView {
        return MusicView()
    }
    //更新当前视图
    func infiniteCycleView(currentView: UIView?) {
        if let mv = currentView as? MusicView {
            self.currentMusicView = mv
            mv.model = self.musicModel
        }
    }
    //更新前一个视图
    func infiniteCycleView(previousView: UIView?, isEndDragging: Bool) {
        if let mv = previousView as? MusicView {
            if !PlayerManager.shared.musicArray.isEmpty {
                let m = PlayerManager.shared.musicArray[PlayerManager.shared.previousIndex]
                mv.model = m
                if isEndDragging {
                    self.musicModel = m
                    PlayerManager.shared.playMusic(model: m)
                }
            }
        }
    }
    //更新下一个视图
    func infiniteCycleView(nextView: UIView?, isEndDragging: Bool) {
        if let mv = nextView as? MusicView {
            if !PlayerManager.shared.musicArray.isEmpty {
                let m = PlayerManager.shared.musicArray[PlayerManager.shared.nextIndex]
                mv.model = m
                if isEndDragging {
                    self.musicModel = m
                    PlayerManager.shared.playMusic(model: m)
                }
            }
        }
    }
    
    func infiniteCycleViewDidSelect(_ currentView: UIView?) {
        let vc = UIApplication.shared.keyWindow?.rootViewController
        PlayerManager.shared.presentPlayController(vc: vc, model: self.musicModel)
    }
}
