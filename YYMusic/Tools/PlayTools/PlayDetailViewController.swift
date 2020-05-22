//
//  PlayDetailViewController.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/20.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit
import AVFoundation

class PlayDetailViewController: UIViewController {
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    var model: MusicModel?
    var callback: ObjectCallback?
    fileprivate var playMode: PlayMode = .none
    @IBOutlet weak var singerImageView: UIImageView!
    @IBOutlet weak var songerName: UILabel!
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var startTimeLbl: UILabel!
    @IBOutlet weak var totalTimeLbl: UILabel!
    @IBOutlet weak var sliderView: MusicSlider!
    @IBOutlet weak var playModeBtn: UIButton!
    @IBOutlet weak var previousBtn: UIButton!
    @IBOutlet weak var playAndPauseBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    fileprivate var timer: Timer!
    fileprivate var isSlider: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        updateModel()
        //适配iPhoneX以后机型
        if screenHeight >= 812 {
            bottomConstraint.constant = 20
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.removeObserver(observer: self, name: .kMusicTimeInterval)
    }
    
    func updateModel() {
        if let str = model?.coverMiddle, let url = URL(string: str) {
            singerImageView.kf.setImage(with: url, placeholder: UIImage(named: "music_placeholder"), options: nil, progressBlock: nil) { (result) in
            }
        }
        singerImageView.startTransitionAnimation()
        
        //歌名和歌手
        songName.text = model?.title ?? ""
        songerName.text = model?.nickname ?? ""
        
        if let callback = callback {
            callback(model!)
        }
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
        
        //设置前一曲/后一曲/播放暂停
        previousBtn.setImage(UIImage(named: "prev_song"), for: .normal)
        nextBtn.setImage(UIImage(named: "next_song"), for: .normal)
        playAndPauseBtn.setImage(UIImage(named: "big_play_button"), for: .normal)
        playAndPauseBtn.setImage(UIImage(named: "big_pause_button"), for: .selected)
        playAndPauseBtn.isSelected = PlayerManager.shared.isPlaying
        
        playModeBtn.addTarget(self, action: #selector(singleCircle(_:)), for: .touchUpInside)
        previousBtn.addTarget(self, action: #selector(previusAction(_:)), for: .touchUpInside)
        nextBtn.addTarget(self, action: #selector(nextAction(_:)), for: .touchUpInside)
        playAndPauseBtn.addTarget(self, action: #selector(playAndPause(_:)), for: .touchUpInside)
        
        sliderView.isContinuous = true
        
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
        //开始事件
        sliderView.addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        //结束事件
        sliderView.addTarget(self, action: #selector(touchUpInside(_:)), for: .touchUpInside)
        //值改变事件
        sliderView.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
        self.addObserverToPlayer()
    }
    
    func addObserverToPlayer() {
        NotificationCenter.addObserver(observer: self, selector: #selector(musicTimeInterval), name: .kMusicTimeInterval)
    }
    
    @objc fileprivate func musicTimeInterval() {
        let currentTime = PlayerManager.shared.getCurrentTime()
        let totalTime = PlayerManager.shared.getTotalTime()
        //滑动状态不更新
        if !isSlider {
           self.updateProgressLabelCurrentTime(currentTime: currentTime, totalTime: totalTime)
        }
    }
    
    //暂停播放
    @objc func playAndPause(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if !sender.isSelected {
            playMode = .pause
        } else {
            playMode = .play
        }
        NotificationCenter.post(name: .kReloadPlayStatus, object: playMode)
    }
    
    /** 设置时间数据 */
    func updateProgressLabelCurrentTime(currentTime: String?, totalTime: String?) {
        if let c = currentTime, let t = totalTime {
            let ct = CMTime(value: CMTimeValue(c)!, timescale: CMTimeScale(1.0))
            let tt = CMTime(value: CMTimeValue(t)!, timescale: CMTimeScale(1.0))
            
            let cs = CMTimeGetSeconds(ct)
            let ts = CMTimeGetSeconds(tt)
            startTimeLbl.text = timeIntervalToMMSSFormat(interval: cs)
            totalTimeLbl.text = timeIntervalToMMSSFormat(interval: ts)
            
            //当前播放进度
            sliderView.minimumValue = 0.0
            sliderView.maximumValue = Float(ts)
            if !isSlider {
               sliderView.value = Float(cs)
            }

            if cs == ts {
                self.playMode = .auto
                NotificationCenter.post(name: .kReloadPlayStatus, object: playMode)
                delay(0.2, closure: { [weak self] in
                    self?.upDateUI()
                })
            }
        }
    }
    
    @objc fileprivate func touchDown(_ slider: UISlider) {
        isSlider = true
    }
    
    @objc fileprivate func touchUpInside(_ slider: UISlider) {
        
        //暂停情况--->滑动默认播放
        if !self.playAndPauseBtn.isSelected {
            self.playAndPause(self.playAndPauseBtn)
        }
        //滑动结束更新播放进度
        PlayerManager.shared.playerProgress(with: Double(slider.value), completionHandler: { [weak self](value) in
            let cs = CMTimeGetSeconds(value)
            self?.sliderView.value = Float(cs)
            self?.isSlider = false
        })
    }
    
    @objc fileprivate func valueChanged(_ slider: UISlider) {
        isSlider = true
        //这里只更新开始时间
        let ct = CMTime(value: CMTimeValue(slider.value), timescale: CMTimeScale(1.0))
        let cs = CMTimeGetSeconds(ct)
        startTimeLbl.text = timeIntervalToMMSSFormat(interval: cs)
    }
    
    func upDateUI() {
        if let m = PlayerManager.shared.currentModel {
            self.model = m
            self.updateModel()
            PlayerManager.shared.isPlaying = true
        }
    }
    
    //MARK:-前一首
    @objc func previusAction(_ sender: UIButton) {
        playMode = .previous
        //切换歌曲, 默认自动播放
        playAndPauseBtn.isSelected = true
        NotificationCenter.post(name: .kReloadPlayStatus, object: playMode)
        
        delay(0.25, closure: { [weak self] in
            self?.upDateUI()
        })

    }
    
    //MARK:下一首
    @objc func nextAction(_ sender: UIButton) {
        playMode = .next
        //切换歌曲, 默认自动播放
        playAndPauseBtn.isSelected = true
        NotificationCenter.post(name: .kReloadPlayStatus, object: playMode)
        delay(0.25, closure: { [weak self] in
            self?.upDateUI()
        })
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
}
