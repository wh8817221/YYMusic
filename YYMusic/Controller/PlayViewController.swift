//
//  PlayViewController.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/15.
//  Copyright © 2020 haoge. All rights reserved.
//
import UIKit

class PlayViewController: UIViewController {
    
    var model: MusicModel?
    var callback: ObjectCallback?
    
    fileprivate var playMode: PlayMode = .none
    @IBOutlet weak var closedBtn: UIButton!
    @IBOutlet weak var nexBtn: UIButton!
    @IBOutlet weak var playAndPauseBtn: UIButton!
    @IBOutlet weak var previousBtn: UIButton!
    @IBOutlet weak var recircleBtn: UIButton!
    @IBOutlet weak var totalTimeLbl: UILabel!
    @IBOutlet weak var sliderView: UISlider!
    @IBOutlet weak var currentTimeLbl: UILabel!
    @IBOutlet weak var headerImageV: UIImageView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var backgroundImageV: UIImageView!
    @IBOutlet weak var songerNameLbl: UILabel!
    @IBOutlet weak var musicNameLbl: UILabel!
    
    fileprivate var timer: Timer!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUI()
    }
    
    func setUI() {
        //获取背景图
        if let str = model?.coverLarge, let url = URL(string: str) {
           backgroundImageV.kf.setImage(with: url)
        }
        
        //关闭按钮
        closedBtn.setImage(UIImage(named: "arrow"), for: .normal)
        closedBtn.addTarget(self, action: #selector(closedAction(_:)), for: .touchUpInside)
        //歌名和歌手
        musicNameLbl.text = model?.title ?? ""
        musicNameLbl.textColor = .white
        musicNameLbl.font = UIFont.boldSystemFont(ofSize: 24)
        
        songerNameLbl.text = model?.nickname ?? ""
        songerNameLbl.textColor = .white
        songerNameLbl.font = UIFont.boldSystemFont(ofSize: 18)
        
        //歌手头像
        headerImageV.layer.cornerRadius = headerImageV.frame.height/2
        headerImageV.layer.masksToBounds = true
        if let str = model?.coverMiddle, let url = URL(string: str) {
           headerImageV.kf.setImage(with: url)
        }
        
        
        currentTimeLbl.font = kFont12
        currentTimeLbl.textColor = .white
        
        totalTimeLbl.font = kFont12
        totalTimeLbl.textColor = .white
        
        sliderView.minimumTrackTintColor = UIColor(red: 255 / 255.0, green: 209 / 255.0, blue: 2 / 255.0, alpha: 1.0)
        sliderView.setThumbImage(UIImage(named: "icon_point1"), for: .normal)
        
        //设置播放模式
        if PlayerManager.shared.isSinglecycle {
            self.recircleBtn.setImage(UIImage(named: "singlecycleSel"), for: .normal)
        } else {
            self.recircleBtn.setImage(UIImage(named: "singlecycle"), for: .normal)
        }
        //设置前一曲/后一曲/播放暂停
        previousBtn.setImage(UIImage(named: "icons_previous_music1"), for: .normal)
        nexBtn.setImage(UIImage(named: "icons_next_music1"), for: .normal)
        playAndPauseBtn.setImage(UIImage(named: "icons_play_music1"), for: .normal)
        playAndPauseBtn.setImage(UIImage(named: "icons_stop_music1"), for: .selected)
        playAndPauseBtn.isSelected = PlayerManager.shared.isPlaying
        
        recircleBtn.addTarget(self, action: #selector(singleCircle(_:)), for: .touchUpInside)
        previousBtn.addTarget(self, action: #selector(previusAction(_:)), for: .touchUpInside)
        nexBtn.addTarget(self, action: #selector(nextAction(_:)), for: .touchUpInside)
        playAndPauseBtn.addTarget(self, action: #selector(playAndPause(_:)), for: .touchUpInside)
        
        if PlayerManager.shared.isPlaying {
            startAnimation()
            startTimer()
        } else {
            sliderView.minimumValue = 0
            if let curentTime = PlayerManager.shared.getCurrentTime(), Double(curentTime)! > 0 {
                let m = String(format: "%02lld", Int(curentTime)!/60)
                let s = String(format: "%02lld", Int(curentTime)!%60)
                currentTimeLbl.text = "\(m):\(s)"
                //总时间
                let totalTime = PlayerManager.shared.getTotalTime() ?? "0"
                let tm = String(format: "%02lld", Int(totalTime)!/60)
                let ts = String(format: "%02lld", Int(totalTime)!%60)
                totalTimeLbl.text = "\(tm):\(ts)"
                if let t = Float(totalTime), t > 0 {
                    sliderView.value = (Float(curentTime) ?? 0)/t
                }
            } else {
                //总时间
                if let totalTime = UserDefaultsManager.shared.userDefaultsGet(key: TOTALTIME) as? String {
                    let tm = String(format: "%02lld", Int(totalTime)!/60)
                    let ts = String(format: "%02lld", Int(totalTime)!%60)
                    totalTimeLbl.text = "\(tm):\(ts)"
                }
                //更新播放进度
                sliderView.value = 0
            }
        }
    }
    
    func upDateUI(model: MusicModel?) {
        self.model = model
        stopTimer()
        //获取背景图
        if let str = model?.coverLarge, let url = URL(string: str) {
           backgroundImageV.kf.setImage(with: url)
        }
        //歌名和歌手
        musicNameLbl.text = model?.title ?? ""
        songerNameLbl.text = model?.nickname ?? ""
        if let str = model?.coverMiddle, let url = URL(string: str) {
           headerImageV.kf.setImage(with: url)
        }
        PlayerManager.shared.isPlaying = true
        startTimer()
    }
    
    //单曲循环/循环播放
    @objc func previusAction(_ sender: UIButton) {
        playMode = .previous
        if let c = callback {
           c(playMode)
        }
        upDateUI(model: PlayerManager.shared.currentModel)
    }
    
    //单曲循环/循环播放
    @objc func nextAction(_ sender: UIButton) {
        playMode = .next
        if let c = callback {
           c(playMode)
        }
        upDateUI(model: PlayerManager.shared.currentModel)
    }
    
    //单曲循环/循环播放
    @objc func singleCircle(_ sender: UIButton) {
        if PlayerManager.shared.isSinglecycle {
            PlayerManager.shared.isSinglecycle = false
            sender.setImage(UIImage(named: "singlecycle"), for: .normal)
        } else {
            PlayerManager.shared.isSinglecycle = true
            sender.setImage(UIImage(named: "singlecycleSel"), for: .normal)
        }
    }
    
    //MARK:-开启定时器
    func startTimer() {
        startAnimation()
        //开始定时器开始记录存储总时间
        self.timer = Timer(timeInterval: 0.1, target: self, selector: #selector(timerAct), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .common)
    }
    
    //MARK:-关闭定时器
    func stopTimer() {
        stopAnimation()
        self.timer.invalidate()
        self.timer = nil
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
        
        if let c = callback {
           c(playMode)
        }
    }
    
    @objc func timerAct() {
        //当前时间
        let curentTime = PlayerManager.shared.getCurrentTime() ?? "0"
        let m = String(format: "%02lld", Int(curentTime)!/60)
        let s = String(format: "%02lld", Int(curentTime)!%60)
        currentTimeLbl.text = "\(m):\(s)"
        //总时间
        let totalTime = PlayerManager.shared.getTotalTime() ?? "0"
        let tm = String(format: "%02lld", Int(totalTime)!/60)
        let ts = String(format: "%02lld", Int(totalTime)!%60)
        totalTimeLbl.text = "\(tm):\(ts)"
        //更新播放进度
        sliderView.minimumValue = 0
        if let t = Float(totalTime), t > 0 {
            sliderView.value = (Float(curentTime) ?? 0)/t
            if sliderView.value == 1.0 {
                print("相等了")
            }
        }
        
        if curentTime == totalTime {
            if let c = callback {
                c(PlayMode.auto)
            }
        }
    }
    
    func startAnimation() {
        if headerImageV.layer.animation(forKey: "rotationAnimationX") == nil {
            let rotationAnimationX = CABasicAnimation(keyPath: "transform.rotation.z")
            rotationAnimationX.beginTime = 0
            rotationAnimationX.toValue = 2 * CGFloat(Double.pi)
            rotationAnimationX.duration = 6
            rotationAnimationX.isRemovedOnCompletion = false
            rotationAnimationX.repeatCount = MAXFLOAT
            headerImageV.layer.add(rotationAnimationX, forKey: "rotationAnimationX")
        } else {
            let layer = headerImageV.layer
            let pausedTime = layer.timeOffset
            layer.speed = 1.0
            layer.timeOffset = 0.0
            layer.beginTime = 0
            let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
            layer.beginTime = timeSincePause
        }
    }
    
    func stopAnimation() {
        let layer = headerImageV.layer
        let pauseTime = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pauseTime
    }
    
    //关闭
    @objc fileprivate func closedAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
