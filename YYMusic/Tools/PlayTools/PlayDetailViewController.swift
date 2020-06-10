//
//  PlayDetailViewController.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/20.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit
import AVFoundation

class PlayDetailViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    var model: BDSongModel?
    @IBOutlet weak var musicSliderView: MusicSliderView!
    @IBOutlet weak var lrcLbl: LrcLabel!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var singerImageView: UIImageView!
    @IBOutlet weak var songerName: UILabel!
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var startTimeLbl: UILabel!
    @IBOutlet weak var totalTimeLbl: UILabel!
    @IBOutlet weak var playModeBtn: UIButton!
    @IBOutlet weak var previousBtn: UIButton!
    @IBOutlet weak var playAndPauseBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    fileprivate var isSlider: Bool = false
    /// 歌词的定时器
    private var lrcProgress: CADisplayLink?
    //歌曲总时间
    private var totalTime: Float64? {
        didSet {
            totalTimeLbl.text = timeIntervalToMMSSFormat(interval: totalTime!)
        }
    }
    //当前时间
    private var currentTime: Float64? {
        didSet{
            startTimeLbl.text = timeIntervalToMMSSFormat(interval: currentTime!)
            if !isSlider {
                if let tt = self.totalTime, let ct = currentTime {
                    musicSliderView.value = CGFloat(ct/tt)
                }
            }
        }
    }
    fileprivate var isFirstTapped: Bool = false
    fileprivate lazy var indicatorView: UIActivityIndicatorView = {
        let iv = UIActivityIndicatorView(style: .whiteLarge)
        iv.frame = self.playAndPauseBtn.frame
        iv.color = .white
        iv.hidesWhenStopped = true
        return iv
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        updateModel(model: model)
        //适配iPhoneX以后机型
        if screenHeight >= 812 {
            bottomConstraint.constant = 20
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.removeObserver(observer: self, name: .kMusicTimeInterval)
        NotificationCenter.removeObserver(observer: self, name: .kMusicLrcProgress)
        NotificationCenter.removeObserver(observer: self, name: .MusicBufferProgress)
        LrcAnalyzer.shared.removeLrcTimer()
    }
    
    func updateModel(model: BDSongModel?) {
        self.model = model
        if let str = model?.pic_premium, let url = URL(string: str) {
            singerImageView.kf.setImage(with: url, placeholder: UIImage(named: "music_placeholder"), options: nil, progressBlock: nil) { (result) in
            }
        }
        singerImageView.startTransitionAnimation()
        
        //歌名和歌手
        songName.text = model?.title ?? ""
        songerName.text = model?.author ?? ""
    }
    
    func setUI() {
        if PlayerManager.shared.hasBeenFavoriteMusic() {
            likeBtn.setImage(UIImage(named: "red_heart"), for: .normal)
        } else {
            likeBtn.setImage(UIImage(named: "empty_heart"), for: .normal)
        }
        //歌手头像
        singerImageView.layer.cornerRadius = 10
        singerImageView.layer.masksToBounds = true
        
        songName.textColor = .white
        songName.font = UIFont.boldSystemFont(ofSize: 17)

        songerName.textColor = .white
        songerName.font = UIFont.boldSystemFont(ofSize: 14)

        startTimeLbl.font = kFont12
        startTimeLbl.textColor = .white
        
        totalTimeLbl.font = kFont12
        totalTimeLbl.textColor = .white
        
        lrcLbl.text = ""
        lrcLbl.textColor = .white
        lrcLbl.font = kFont15
        
        //设置播放模式
        switch PlayerManager.shared.cycle {
        case .single:
            self.playModeBtn.setImage(UIImage(named: "icon_single"), for: .normal)
        case .order:
            self.playModeBtn.setImage(UIImage(named: "icon_order"), for: .normal)
        default:
            self.playModeBtn.setImage(UIImage(named: "icon_random"), for: .normal)
        }
        
        moreBtn.setImage(UIImage(named: "icon_more"), for: .normal)
        moreBtn.addTarget(self, action: #selector(moreList), for: .touchUpInside)
        
        //设置前一曲/后一曲/播放暂停
        previousBtn.setImage(UIImage(named: "prev_song"), for: .normal)
        nextBtn.setImage(UIImage(named: "next_song"), for: .normal)
        playAndPauseBtn.setImage(UIImage(named: "big_play_button"), for: .normal)
        playAndPauseBtn.setImage(UIImage(named: "big_play_button"), for: .disabled)
        playAndPauseBtn.setImage(UIImage(named: "big_pause_button"), for: .selected)
        playAndPauseBtn.isSelected = PlayerManager.shared.isPlaying
        
        playModeBtn.addTarget(self, action: #selector(singleCircle(_:)), for: .touchUpInside)
        previousBtn.addTarget(self, action: #selector(previusAction(_:)), for: .touchUpInside)
        nextBtn.addTarget(self, action: #selector(nextAction(_:)), for: .touchUpInside)
        playAndPauseBtn.addTarget(self, action: #selector(playAndPause(_:)), for: .touchUpInside)
                
        if PlayerManager.shared.isPlaying {
            let currentTime = PlayerManager.shared.getCurrentTime()
            let totalTime = PlayerManager.shared.getTotalTime()
            self.updateProgressLabelCurrentTime(currentTime: currentTime, totalTime: totalTime)
        } else {
            if let currentTime = PlayerManager.shared.getCurrentTime() {
                let totalTime = PlayerManager.shared.getTotalTime()
                self.updateProgressLabelCurrentTime(currentTime: currentTime, totalTime: totalTime)
            } else {
                if let totalTime = UserDefaultsManager.shared.userDefaultsGet(key: TOTALTIME) as? String {
                    self.updateProgressLabelCurrentTime(currentTime: "0", totalTime: totalTime)
                }
            }
        }
        
        musicSliderView.delegate = self
        
        //注册监听歌曲时间
        NotificationCenter.addObserver(observer: self, selector: #selector(musicTimeInterval(_:)), name: .kMusicTimeInterval)
        //注册监听歌词加载状态
        NotificationCenter.addObserver(observer: self, selector: #selector(musicLrcChange(_:)), name: .kLrcLoadStatus)
        //注册监听歌曲加载状态
        NotificationCenter.addObserver(observer: self, selector: #selector(musicLoadStatus(_:)), name: .kMusicLoadStatus)
        //监听歌词播放进度
        NotificationCenter.addObserver(observer: self, selector: #selector(musicLrcProgress(_:)), name: .kMusicLrcProgress)
        //监听缓冲进度
        NotificationCenter.addObserver(observer: self, selector: #selector(musicBufferProgress(_:)), name: .MusicBufferProgress)
        
        if PlayerManager.shared.isPlaying {
            LrcAnalyzer.shared.addLrcTimer()
        }
        
        //歌曲加载中状态
        if PlayerManager.shared.musicStatus == .loadding {
            self.musicSliderView.value = 0
            self.musicSliderView.bufferValue = 0
            self.startTimeLbl.text = "00:00"
            self.playAndPauseBtn.isEnabled = false
            self.playAndPauseBtn.isSelected = false
            self.playAndPauseBtn.addSubview(indicatorView)
            self.playAndPauseBtn.bringSubviewToFront(indicatorView)
            indicatorView.snp.makeConstraints({$0.center.equalTo(self.playAndPauseBtn)})
            indicatorView.startAnimating()
        }
    }

    //MARK:-监听歌曲播放状态
    @objc fileprivate func musicLoadStatus(_ sender: Notification) {
        if let status = sender.object as? MusicLoadStatus {
            switch status {
            case .loadding:
                if !isFirstTapped {
                    self.musicSliderView.value = 0
                    self.musicSliderView.bufferValue = 0
                    self.startTimeLbl.text = "00:00"
                }
                
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
                //有可能存在歌曲没播放或者没有歌曲的情况
                if isFirstTapped {
                    isFirstTapped = false
                    updateProgress()
                }
            default:
                break
            }
        }
    }
    
    //MARK:-监听歌词播放进度
    @objc fileprivate func musicBufferProgress(_ sender: Notification) {
        if let progress = sender.object as? CGFloat {
            self.musicSliderView.bufferValue = progress
        }
    }
    
    //MARK:-监听歌词播放进度
    @objc fileprivate func musicLrcProgress(_ sender: Notification) {
        if let lrc = sender.object as? (index: Int?, lrcText: String?, progress: CGFloat?) {
            self.lrcLbl.isHidden = false
            self.lrcLbl?.text = lrc.lrcText ?? ""
            self.lrcLbl?.progress = lrc.progress ?? 0
        }
    }
    
    //MARK:-监听歌词加载情况
    @objc fileprivate func musicLrcChange(_ sender: Notification) {
        if let status = sender.object as? LrcLoadStatus {
            switch status {
            case .loadding:
                self.lrcLbl.isHidden = true
                LrcAnalyzer.shared.removeLrcTimer()
            case .completed:
                LrcAnalyzer.shared.addLrcTimer()
            case .failed:
                self.lrcLbl.isHidden = true
                LrcAnalyzer.shared.removeLrcTimer()
            default:
                break
            }
        }
    }
    
    //MARK:-监听音乐时间变化
    @objc fileprivate func musicTimeInterval(_ sender: Notification) {
        let currentTime = PlayerManager.shared.getCurrentTime()
        let totalTime = PlayerManager.shared.getTotalTime()
        //滑动状态不更新
        if !isSlider {
           self.updateProgressLabelCurrentTime(currentTime: currentTime, totalTime: totalTime)
        }
    }

    //MARK:-更多列表
    @objc fileprivate func moreList() {
        let vc = MoreListViewController()
        vc.musicModel = self.model
        vc.transitioningDelegate = self
        vc.modalPresentationStyle = .custom
        self.present(vc, animated: true, completion: nil)
    }
    
    //MARK:-暂停播放
    @objc func playAndPause(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        //第一次点击底部播放按钮并且还是未在播放状态
        if PlayerManager.shared.isFristPlayerPauseBtn && !PlayerManager.shared.isPlaying {
            PlayerManager.shared.isFristPlayerPauseBtn = false
            if let model = UserDefaultsManager.shared.unarchive(key: CURRENTMUSIC) as? BDSongModel {
                PlayerManager.shared.playMusic(model: model)
            } else {
                //归档没找到默认播放第一个
                if let model = PlayerManager.shared.currentModel {
                    PlayerManager.shared.playMusic(model: model)
                }
            }
        } else {
            PlayerManager.shared.isFristPlayerPauseBtn = false
            if !sender.isSelected {
                LrcAnalyzer.shared.removeLrcTimer()
                PlayerManager.shared.playerPause()
            } else {
                LrcAnalyzer.shared.addLrcTimer()
                PlayerManager.shared.playerPlay()
            }
        }
        
    }
    
    //MARK:-更新时间和滑块
    func updateProgressLabelCurrentTime(currentTime: String?, totalTime: String?) {
        if let c = currentTime, let t = totalTime {
            let ct = CMTime(value: CMTimeValue(c)!, timescale: CMTimeScale(1.0))
            let tt = CMTime(value: CMTimeValue(t)!, timescale: CMTimeScale(1.0))
            let cs = CMTimeGetSeconds(ct)
            let ts = CMTimeGetSeconds(tt)
            if !isFirstTapped {
                self.totalTime = ts
                self.currentTime = cs
            }
        }
    }
 
    //MARK:-前一首
    @objc func previusAction(_ sender: UIButton) {
        playAndPauseBtn.isSelected = true
        PlayerManager.shared.playPrevious()
    }
    
    //MARK:下一首
    @objc func nextAction(_ sender: UIButton) {
        playAndPauseBtn.isSelected = true
        PlayerManager.shared.playNext()
    }
    
    //MARK:-顺序播放->单曲循环->随机播放->顺序播放
    @objc func singleCircle(_ sender: UIButton) {
        switch PlayerManager.shared.cycle {
        case .order:
            PlayerManager.shared.cycle = .single
            sender.setImage(UIImage(named: "icon_single"), for: .normal)
        case .single:
            PlayerManager.shared.cycle = .random
            sender.setImage(UIImage(named: "icon_random"), for: .normal)
        default:
            PlayerManager.shared.cycle = .order
            sender.setImage(UIImage(named: "icon_order"), for: .normal)
        }
    }
    
    deinit {
        NotificationCenter.removeObserver(observer: self, name: .kMusicLrcProgress)
        NotificationCenter.removeObserver(observer: self, name: .MusicBufferProgress)
        NotificationCenter.removeObserver(observer: self, name: .kMusicTimeInterval)
        NotificationCenter.removeObserver(observer: self, name: .kLrcLoadStatus)
        NotificationCenter.removeObserver(observer: self, name: .kMusicLoadStatus)
        
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        if presented is MoreListViewController {
            let vc = OverlayPresentationController(presentedViewController:presented, presenting:presenting, offset: screenHeight - 150)
            vc.isTapped = true
            return vc
        } else {
            return nil
        }
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if presented is MoreListViewController {
            let controller = OverlayAnimatedTransitioning()
            controller.isPresentation = true
            return controller
        } else {
            return nil
        }
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed is MoreListViewController {
            let controller = OverlayAnimatedTransitioning()
            controller.isPresentation = false
            return controller
        } else {
            return nil
        }
    }
}

extension PlayDetailViewController: MusicSliderViewDelegate {
    func sliderTouchBegan(value: CGFloat) {
        isSlider = true
    }
    
    func sliderTouchEnded(value: CGFloat) {
        //滑动结束更新播放进度
        updateSliderAndTap(value: value)
    }
    
    func sliderValueChanged(value: CGFloat) {
        isSlider = true
        //这里只更新开始时间
        guard let ts = self.totalTime else { return }
        let time = Float64(value*CGFloat(ts))
        self.currentTime = time
    }
    
    func sliderTapped(value: CGFloat) {
        updateSliderAndTap(value: value)
    }
    
    //MARK:-更新点击或者滑动的进度
    func updateSliderAndTap(value: CGFloat) {
        //表示歌曲不存在
        guard let ts = self.totalTime else {
            isFirstTapped = true
            self.playAndPause(self.playAndPauseBtn)
            return
        }
        
        //表示歌曲存在但是没有点击开始播放
        if PlayerManager.shared.isFristPlayerPauseBtn {
            isFirstTapped = true
            let time = Float64(value*CGFloat(ts))
            self.currentTime = time
            self.playAndPause(self.playAndPauseBtn)
            return
        }
        
        isFirstTapped = false
        //暂停情况--->滑动默认播放
        if !PlayerManager.shared.isPlaying {
            self.playAndPause(self.playAndPauseBtn)
        }
        
        let time = Float64(value*CGFloat(ts))
        self.currentTime = time
        updateProgress()
    }
    //MARK:-进度更新设置值
    func updateProgress() {
        guard let time = self.currentTime else {
            return
        }
        //滑动结束更新播放进度
        PlayerManager.shared.playerProgress(with: Double(time), completionHandler: { [weak self](value) in
            let cs = CMTimeGetSeconds(value)
            self?.musicSliderView.value = CGFloat(cs/(self?.totalTime)!)
            self?.isSlider = false
        })
    }
}
