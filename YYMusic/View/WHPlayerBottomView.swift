//
//  WHPlayerBottomView.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/18.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit
import Kingfisher

class WHPlayerBottomView: UIControl {
    static let shared = WHPlayerBottomView()
  
    var musicModel: MusicModel? {
        didSet {
            if let m = musicModel {
                let url = URL(string: m.coverSmall!)
                headerImageView.kf.setImage(with: url, placeholder: UIImage(named: "musicicon"), options: nil, progressBlock: nil, completionHandler: {(result) in
                })
                songNameLbl.text = m.title ?? ""
                songerLbl.text = m.nickname ?? ""
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
    /*歌名*/
    var songNameLbl: UILabel!
    /*歌手名*/
    var songerLbl: UILabel!
    /*播放暂停按钮*/
    var playAndPauseBtn: UIButton!
    fileprivate var isFirstTime: Bool = true
    fileprivate lazy var arcLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        
        layer.strokeColor = kThemeColor.cgColor
        layer.lineWidth = 2.5
        layer.lineCap = CAShapeLayerLineCap(rawValue: "round")
        return layer
    }()
    
    fileprivate var playerBarH: CGFloat = 65.0
    fileprivate var parentVC: UIViewController?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 57/255, green: 57/255, blue: 58/255, alpha: 1.0)
        
        headerImageView = UIImageView()
        headerImageView.image = UIImage(named: "musicicon")
        headerImageView.layer.cornerRadius = 25
        headerImageView.layer.masksToBounds = true
        self.addSubview(headerImageView)
        headerImageView.snp.makeConstraints { (make) in
            make.height.width.equalTo(50)
            make.left.equalTo(self.snp.left).offset(10)
            make.centerY.equalTo(self.snp.centerY)
        }
        
        playAndPauseBtn = UIButton(type: .custom)
        playAndPauseBtn.setImage(UIImage(named: "icons_play_music1"), for: .normal)
        playAndPauseBtn.setImage(UIImage(named: "icons_stop_music1"), for: .selected)
        playAndPauseBtn.addTarget(self, action: #selector(playAndPause(_:)), for: .touchUpInside)
        self.addSubview(playAndPauseBtn)
        playAndPauseBtn.snp.makeConstraints { (make) in
            make.height.width.equalTo(35)
            make.right.equalTo(self.snp.right).offset(-10)
            make.centerY.equalTo(self.snp.centerY)
        }
        
        songNameLbl = UILabel()
        songNameLbl.textColor = kThemeColor
        songNameLbl.font = kFont17
        songNameLbl.text = "歌曲名"
        self.addSubview(songNameLbl)
        songNameLbl.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.top).offset(15)
            make.left.equalTo(headerImageView.snp.right).offset(10)
            make.right.equalTo(playAndPauseBtn.snp.left).offset(-10)
        }
        
        songerLbl = UILabel()
        songerLbl.textColor = .white
        songerLbl.font = kFont12
        songerLbl.text = "歌手"
        self.addSubview(songerLbl)
        songerLbl.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.songNameLbl)
            make.top.equalTo(self.songNameLbl.snp.bottom).offset(8)
            make.bottom.equalTo(self.snp.bottom).offset(-15)
        }
        
        drawCircle(rect: playAndPauseBtn.frame, progress: 0.0)
        NotificationCenter.addObserver(observer: self, selector: #selector(reloadPlay(_ :)), name: .kReloadPlayStatus)
        //设置代理
        PlayerManager.shared.delegate = self
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
                self.autoNext()
                self.progress = 0.0
            }
        }
        //存储歌曲总时间, 第一次进入才存
        if let t = totalTime, (Int(t) ?? 0) > 0{
            //只记录一次总时间,防止不停的调用存储
            if isFirstTime {
                isFirstTime = false
                UserDefaultsManager.shared.userDefaultsSet(object: "\(t)", key: TOTALTIME)
            }
        }
    }
    
    //MARK:-刷新播放状态
    @objc fileprivate func reloadPlay(_ sender: Notification) {
        if let mode = sender.object as? PlayMode {
            switch mode {
            case .play, .pause:
                self.tapPlayButton(isPlay: mode == .play)
            case .next:
                self.nextMusic()
                self.playAndPauseBtn.isSelected = true
            case .previous:
                self.previousMusic()
                self.playAndPauseBtn.isSelected = true
            default:
                self.autoNext()
                self.playAndPauseBtn.isSelected = true
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(tableView: UITableView, superVc: UIViewController) {
        self.parentVC = superVc
        // tableview  给底部留距离
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: playerBarH))
        superVc.view.addSubview(self)
        self.snp.makeConstraints { (make) in
            make.left.right.equalTo(superVc.view)
            make.bottom.equalTo(superVc.view.snp.bottom)
            make.height.equalTo(playerBarH)
        }
        self.addTarget(self, action: #selector(tapBottomView(_:)), for: .touchUpInside)
    }
    
    @objc fileprivate func tapBottomView(_ sender: UIButton) {
        PlayerManager.shared.presentPlayController(vc: self.parentVC, model: self.musicModel)
    }
    
    //刷新界面
    func reloadUI(music: MusicModel) {
        self.musicModel = music
    }
    
    func reloadData(with index: Int, model: MusicModel) {
        //记录播放状态和播放歌曲角标
        PlayerManager.shared.isPlaying = true
        PlayerManager.shared.index = index
        loadMusic(model: model)
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
        startAnimation()
    }
    
    //暂停播放
    func pauseActive() {
        PlayerManager.shared.playerPause()
        stopAnimation()
    }
    
    //加载播放
    func loadMusic(model: MusicModel) {
        self.musicModel = model
        self.playAndPauseBtn.isSelected = true
        PlayerManager.shared.playReplaceItem(with: model, callback: {[weak self] (value) in
            self?.startAnimation()
        })
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
    
    //前一首
    func previousMusic() {
        stopAnimation()
        PlayerManager.shared.playPrevious(callback: {[weak self] (value) in
             if let m = value as? MusicModel {
                self?.musicModel = m
                self?.startAnimation()
             }
        })
    }
    
    //下一首
    func nextMusic() {
        stopAnimation()
        PlayerManager.shared.playNext(callback: {[weak self] (value) in
             if let m = value as? MusicModel {
                self?.musicModel = m
                self?.startAnimation()
             }
        })
    }
    
    //MARK:-自动下一首或者是单曲循环
    func autoNext() {
        if PlayerManager.shared.cycle == .single {
            //单曲循环播放
            if let model = self.musicModel {
                loadMusic(model: model)
            }
        } else {
            //下一首
            nextMusic()
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
        NotificationCenter.removeObserver(observer: self, name: .kReloadPlayStatus)
    }
}

extension WHPlayerBottomView: PlayMusicDelegate {
    func playMusicChange(_ mode: Int, object: Any?) {
        
    }
    
    func playMusicTimeChange(_ currentTime: Float64, totalTime: Float64) {
        self.progress = CGFloat(currentTime/totalTime)
        if CGFloat(currentTime/totalTime) >= 1.0 {
            self.autoNext()
            self.progress = 0.0
        }
        //存储歌曲总时间, 第一次进入才存,防止不停的调用存储
        if isFirstTime {
            isFirstTime = false
            UserDefaultsManager.shared.userDefaultsSet(object: "\(totalTime)", key: TOTALTIME)
        }
    }
}
