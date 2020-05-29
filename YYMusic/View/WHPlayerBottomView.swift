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
    var musicModel: MusicModel? {
        didSet {
            if let m = musicModel {
                let url = URL(string: m.coverSmall!)
                headerImageView.kf.setImage(with: url, placeholder: UIImage(named: "musicicon"), options: nil, progressBlock: nil, completionHandler: {(result) in
                })
                songNameLbl.text = "\(m.title ?? "") - \(m.nickname ?? "")"
            }
        }
    }
    
    /*圆环进度指示器*/
    var progress: CGFloat = 0.0 {
        didSet{
            if progress > 1 || progress < 0 { return }
            arcLayer.removeFromSuperlayer()
            drawCircle(rect: playAndPauseBtn.frame, progress: progress)
        }
    }
    
    /*歌手头像*/
    var headerImageView: UIImageView!
    /*歌名-歌手名*/
    var songNameLbl: MarqueeLabel = {
        let lbl = MarqueeLabel()
        lbl.text = "歌曲-歌手"
        lbl.textColor = .black
        lbl.font = kFont15
        lbl.textAlignment = .left
        lbl.speed = .duration(10)
        lbl.trailingBuffer = 30
        lbl.fadeLength = 10
        lbl.animationCurve = .easeInOut
        return lbl
    }()
    
    /*播放暂停按钮*/
    var playAndPauseBtn: UIButton!
    /**播放的背景*/
    var contentView: UIControl!
    fileprivate lazy var arcLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = kThemeColor.cgColor
        layer.lineWidth = 2.5
        layer.lineCap = CAShapeLayerLineCap(rawValue: "round")
        return layer
    }()
    
    fileprivate var playerBarH: CGFloat = 65.0
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
        contentView = UIControl()
        contentView.backgroundColor = .white
        self.addSubview(contentView)
        contentView.addTarget(self, action: #selector(tapBottomView(_:)), for: .touchUpInside)
        contentView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.bottom.equalTo(self.snp.bottom)
            make.height.equalTo(48)
        }
        
        
        headerImageView = UIImageView()
        headerImageView.image = UIImage(named: "musicicon")
        headerImageView.layer.cornerRadius = 25
        headerImageView.layer.masksToBounds = true
        contentView.addSubview(headerImageView)
        headerImageView.snp.makeConstraints { (make) in
            make.height.width.equalTo(50)
            make.left.equalTo(contentView.snp.left).offset(10)
            make.bottom.equalTo(contentView.snp.bottom).offset(-6)
        }
        
        playAndPauseBtn = UIButton(type: .custom)
        playAndPauseBtn.setImage(UIImage(named: "icons_play_music1"), for: .normal)
        playAndPauseBtn.setImage(UIImage(named: "icons_stop_music1"), for: .selected)
        playAndPauseBtn.addTarget(self, action: #selector(playAndPause(_:)), for: .touchUpInside)
        contentView.addSubview(playAndPauseBtn)
        playAndPauseBtn.snp.makeConstraints { (make) in
            make.height.width.equalTo(35)
            make.right.equalTo(contentView.snp.right).offset(-10)
            make.centerY.equalTo(contentView.snp.centerY)
        }

        contentView.addSubview(songNameLbl)
        songNameLbl.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView.snp.centerY)
            make.left.equalTo(headerImageView.snp.right).offset(10)
            make.right.equalTo(playAndPauseBtn.snp.left).offset(-10)
        }
        
        drawCircle(rect: playAndPauseBtn.frame, progress: 0.0)
        //注册监听
        NotificationCenter.addObserver(observer: self, selector: #selector(musicChange(_:)), name: .kMusicChange)
        NotificationCenter.addObserver(observer: self, selector: #selector(musicTimeInterval), name: .kMusicTimeInterval)
        NotificationCenter.addObserver(observer: self, selector: #selector(playStatusChange(_:)), name: .kReloadPlayStatus)
        
        //获取上次播放存储的歌曲
        if let music = UserDefaultsManager.shared.unarchive(key: CURRENTMUSIC) as? MusicModel {
            self.musicModel = music
        }
        self.updateMusic(model: self.musicModel)
    }
    
    @objc fileprivate func musicTimeInterval() {
        let currentTime = PlayerManager.shared.getCurrentTime()
        let totalTime = PlayerManager.shared.getTotalTime()
        //更新进度圆环 如果当前时间=总时长 就直接下一首(或者单曲循环)
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
        if let model = notification.object as? MusicModel {
            self.musicModel = model
            playAndPauseBtn.isSelected = true
            startAnimation()
        }
    }
    
    @objc fileprivate func playStatusChange(_ notification: Notification) {
        if let isPlay = notification.object as? Bool {
            playAndPauseBtn.isSelected = isPlay
            if isPlay {
                startAnimation()
            } else {
                stopAnimation()
            }
        }
    }
    
    func updateMusic(model: MusicModel?) {
        self.musicModel = model
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc fileprivate func tapBottomView(_ sender: UIButton) {
        let vc = UIApplication.shared.keyWindow?.rootViewController
        PlayerManager.shared.presentPlayController(vc: vc, model: self.musicModel)
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
    func loadMusic(model: MusicModel) {
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
            if let music = UserDefaultsManager.shared.unarchive(key: CURRENTMUSIC) as? MusicModel {
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
    
    func startAnimation() {
        if headerImageView.layer.animation(forKey: "rotationAnimationZ") == nil {
            let rotationAnimationZ = CABasicAnimation(keyPath: "transform.rotation.z")
            rotationAnimationZ.timingFunction = CAMediaTimingFunction(name: .linear)
            rotationAnimationZ.fromValue = 0 // 开始角度
            rotationAnimationZ.toValue = 2*CGFloat(Double.pi)
            rotationAnimationZ.duration = 10
            rotationAnimationZ.autoreverses = false
            rotationAnimationZ.isRemovedOnCompletion = false
            rotationAnimationZ.repeatCount = MAXFLOAT
            rotationAnimationZ.fillMode = .forwards
            headerImageView.layer.add(rotationAnimationZ, forKey: "rotationAnimationZ")
        } else {
            let layer = headerImageView.layer
            let pausedTime = layer.timeOffset
            layer.speed = 1.0
            layer.timeOffset = 0.0
            layer.beginTime = 0
            let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
            layer.beginTime = timeSincePause
        }
    }
    
    func stopAnimation() {
        let layer = headerImageView.layer
        let pauseTime = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pauseTime
    }

    deinit {
        NotificationCenter.removeObserver(observer: self, name: .kMusicChange)
        NotificationCenter.removeObserver(observer: self, name: .kMusicTimeInterval)
        NotificationCenter.removeObserver(observer: self, name: .kReloadPlayStatus)
        
    }
}
