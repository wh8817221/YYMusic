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
    
    var model: MusicModel? {
        didSet{
            if let str = model?.coverMiddle, let url = URL(string: str) {
                SingerImageView.kf.setImage(with: url, placeholder: UIImage(named: "music_placeholder"), options: nil, progressBlock: nil) { (result) in
                }
            }
            SingerImageView.startTransitionAnimation()
            
            //歌名和歌手
            songName.text = model?.title ?? ""
            songerName.text = model?.nickname ?? ""
        }
    }
    
    fileprivate var playMode: PlayMode = .none
    @IBOutlet weak var SingerImageView: UIImageView!
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
    fileprivate var newItem: Bool?
    
    fileprivate var musicIsPlaying: Bool?
    fileprivate var musicIsChange: Bool?
    fileprivate var musicIsCan: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    func setUI() {
        if PlayerManager.shared.hasBeenFavoriteMusic() {
            likeBtn.setImage(UIImage(named: "red_heart"), for: .normal)
        } else {
            likeBtn.setImage(UIImage(named: "empty_heart"), for: .normal)
        }
        //歌手头像
        SingerImageView.layer.cornerRadius = 7
        SingerImageView.layer.masksToBounds = true
        
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
        
//        self.updateProgressLabelCurrentTime(currentTime: <#TimeInterval#>, duration: <#TimeInterval#>)
        
        if PlayerManager.shared.isPlaying {
            startTimer()
        } else {
            sliderView.minimumValue = 0
            if let curentTime = PlayerManager.shared.getCurrentTime(), Double(curentTime)! > 0 {
                let m = String(format: "%02lld", Int(curentTime)!/60)
                let s = String(format: "%02lld", Int(curentTime)!%60)
                startTimeLbl.text = "\(m):\(s)"
                //总时间
                let totalTime = PlayerManager.shared.getTotalTime() ?? "0"
                let tm = String(format: "%02lld", Int(totalTime)!/60)
                let ts = String(format: "%02lld", Int(totalTime)!%60)
                totalTimeLbl.text = "\(tm):\(ts)"
                if let t = Float(totalTime), t > 0 {
                    sliderView.value = (Float(curentTime) ?? 0)
                    sliderView.maximumValue = Float(t)
                }
            } else {
                //总时间
                if let totalTime = UserDefaultsManager.shared.userDefaultsGet(key: TOTALTIME) as? String {
                    let tm = String(format: "%02lld", Int(totalTime)!/60)
                    let ts = String(format: "%02lld", Int(totalTime)!%60)
                    totalTimeLbl.text = "\(tm):\(ts)"
                    sliderView.maximumValue = Float(totalTime)!
                }
                //更新播放进度
                sliderView.value = 0
            }
        }
        
        sliderView.addTarget(self, action: #selector(sliderProgress(_:)), for: .valueChanged)
//        self.addObserver(to: PlayerManager.shared.player)
        
    }

    //暂停播放
    @objc func playAndPause(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if !sender.isSelected {
            playMode = .pause
            stopTimer()
        } else {
            playMode = .play
            startTimer()
        }
        NotificationCenter.post(name: .kReloadPlayStatus, object: playMode)
    }
    
    /** 设置时间数据 */
    func updateProgressLabelCurrentTime(currentTime: TimeInterval, duration: TimeInterval) {
        startTimeLbl.text = timeIntervalToMMSSFormat(interval: currentTime)
        totalTimeLbl.text = timeIntervalToMMSSFormat(interval: duration)
//        if musicIsCan == true {
//            var currentTimef = CGFloat(currentTime)
//            var currentTimei = Int(currentTime)
//            if currentTimef == currentTimei {
//                musicIsCan = false
//            }
//        }
//        if musicIsChange == false && musicIsCan == false {
//            sliderView.setValue(Float(currentTime/duration), animated: true)
//        }
        sliderView.setValue(Float(currentTime/duration), animated: true)
    }
    
    @objc fileprivate func sliderProgress(_ sender: UISlider) {
        PlayerManager.shared.playerProgress(with: Double(sender.value))
    }
    
    func upDateUI() {
        if let m = PlayerManager.shared.currentModel {
            self.model = m
            PlayerManager.shared.isPlaying = true
            startTimer()
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
    
    //MARK:-上一首
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
    
    //MARK:-开启定时器
    func startTimer() {
        //开始定时器开始记录存储总时间
        self.timer = Timer(timeInterval: 0.1, target: self, selector: #selector(timerAct), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .common)
    }
    
    //MARK:-关闭定时器
    func stopTimer() {
        self.timer.invalidate()
        self.timer = nil
    }
    
    @objc func timerAct() {
        //当前时间
        let curentTime = PlayerManager.shared.getCurrentTime() ?? "0"
        let m = String(format: "%02lld", Int(curentTime)!/60)
        let s = String(format: "%02lld", Int(curentTime)!%60)
        startTimeLbl.text = "\(m):\(s)"

        let totalTime = PlayerManager.shared.getTotalTime() ?? "0"
        let tm = String(format: "%02lld", Int(totalTime)!/60)
        let ts = String(format: "%02lld", Int(totalTime)!%60)
        totalTimeLbl.text = "\(tm):\(ts)"
        //更新播放进度
        if let t = Float(totalTime), t > 0 {
            sliderView.minimumValue = 0
            //当前播放进度
            sliderView.value = (Float(curentTime) ?? 0)
            sliderView.maximumValue = Float(t)
        }
        
        if curentTime == totalTime && totalTime != "0" {
            self.playMode = .auto
            NotificationCenter.post(name: .kReloadPlayStatus, object: playMode)
            delay(0.2, closure: { [weak self] in
                self?.upDateUI()
            })
        }
    }
    
    //MARK:-kvo
    /** 给AVPlayer添加监控 */
    func addObserver(to player: AVPlayer) {
        NotificationCenter.addObserver(observer: self, selector: #selector(musicTimeInterval), name: .kMusicTimeChange)
    }
    /** 通知 监听时间变化，设置时间 */
    @objc func musicTimeInterval() {
        if let c = PlayerManager.shared.player.currentItem?.currentTime() {
            let current = CMTimeGetSeconds(c)
            if let t = PlayerManager.shared.player.currentItem?.duration {
                let total = CMTimeGetSeconds(t)
                self.updateProgressLabelCurrentTime(currentTime: current, duration: total)
            }
        }
    }
}
