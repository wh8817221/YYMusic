//
//  PlayerManager.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/14.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import HWPanModal

//歌曲播放模式
enum PlayerCycle: Int {
    /**单曲循环*/
    case single = 0
    /**顺序播放*/
    case order = 1
    /**随机播放*/
    case random = 2
}

//歌词加载状态
enum LrcLoadStatus {
    case none      //默认
    case loadding  //加载中
    case completed   //完成
    case failed    //失败
}

//歌曲加载状态
enum MusicLoadStatus {
    case none      //默认
    case loadding  //加载中
    case readyToPlay //准备播放
    case completed   //播放完成
    case failed    //播放失败
}

class PlayerManager: NSObject {
    static let shared = PlayerManager()
    /*存放歌曲数组*/
    var musicArray: [BDSongModel] = []
    /*前一首下标*/
    var previousIndex: Int! {
        get {
            if self.index == 0 {
                return self.musicArray.count - 1
            } else {
                return self.index - 1
            }
        }
    }
    /*下一首下标*/
    var nextIndex: Int! {
        get {
            if self.index == self.musicArray.count - 1 {
                return 0
            } else {
                return self.index + 1
            }
        }
    }
    /*播放下标, 默认从第一首开始*/
    var index: Int = 0
    /*标记是不是没点列表直接点了播放按钮如果是就默认播放按钮*/
    var isFristPlayerPauseBtn: Bool = true
    /*是不是正在播放*/
    var isPlaying: Bool = false
    /**是否锁屏*/
    var isLockedScreen: Bool = false
    /*播放器*/
    var player: AVPlayer!
    var currentPlayerItem: AVPlayerItem! {
        didSet{
            if currentPlayerItem != nil {
                //播放状态
                currentPlayerItem.addObserver(self, forKeyPath: "status", options: .new, context: nil)
                //播放进度
                currentPlayerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
                //监听播放器在缓冲数据的状态 playbackBufferEmpty
                currentPlayerItem.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
                //缓冲达到可播放程度了 playbackLikelyToKeepUp
                currentPlayerItem.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
            }
        }
    }
    /**缓存*/
    var resourceLoader: ResourceLoader?
    /*播放模式*/
    var cycle: PlayerCycle = .order {
        didSet{
            UserDefaultsManager.shared.userDefaultsSet(object: cycle.rawValue, key: CYCLE)
        }
    }
    
    /*歌曲加载状态*/
    var musicStatus: MusicLoadStatus = .none {
        didSet{
            NotificationCenter.post(name: .kMusicLoadStatus, object: musicStatus)
        }
    }
    
    /*歌词加载状态*/
    var lrcStatus: LrcLoadStatus = .none {
        didSet{
            NotificationCenter.post(name: .kLrcLoadStatus, object: lrcStatus)
        }
    }
    
    /**获取当前播放的歌曲*/
    var currentModel: BDSongModel?{
        get {
            if musicArray.count > 0 {
                if self.cycle == .random {
                    let random = Int(arc4random())%musicArray.count
                    return musicArray[random]
                } else {
                    return musicArray[index]
                }
            }
            return nil
        }
    }
    /**缓存进度*/
    var bufferProgress: CGFloat? {
        didSet {
            if !bufferProgress!.isNaN {
               NotificationCenter.post(name: .MusicBufferProgress, object: bufferProgress)
            }
        }
    }
    
    var session = AVAudioSession.sharedInstance()
    /**播放时间监听*/
    fileprivate var timeObserve: Any?
    fileprivate var isFirstTime: Bool = true
    fileprivate var playModel: BDSongModel?
    
    override init() {
        super.init()
        
        //获取播放模式
        if let c = UserDefaultsManager.shared.userDefaultsGet(key: CYCLE) as? Int {
            self.cycle = PlayerCycle(rawValue: c) ?? .order
        }
        
        if player == nil {
            player = AVPlayer()
            try? session.setCategory(.playback)
            try? session.setActive(true, options: [])
        }
        
        //播放完毕的通知
        NotificationCenter.addObserver(observer: self, selector: #selector(playerItemDidPlayToEndTime(_:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        //耳机插入和拔掉通知
        NotificationCenter.addObserver(observer: self, selector: #selector(audioRouteChangeListener(_:)), name: AVAudioSession.routeChangeNotification, object: nil)
        
    }

    //MARK:-播放完毕通知
    @objc fileprivate func playerItemDidPlayToEndTime(_ notification: Notification) {
        musicStatus = .completed
        print("播放完毕========>\(currentModel?.title ?? "")歌曲")
        autoPlay()
    }
    
    //MARK:-耳机操作通知
    @objc fileprivate func audioRouteChangeListener(_ notification: Notification) {
        let info = notification.userInfo
        if let routeChangeReason = info?[AVAudioSessionRouteChangeReasonKey] as? AVAudioSession.RouteChangeReason {
            switch routeChangeReason {
            case .newDeviceAvailable:
                print("插入耳机========>\(currentModel?.title ?? "")歌曲")
                self.playerPlay()
            case .oldDeviceUnavailable:
                print("拔掉耳机========>\(currentModel?.title ?? "")歌曲")
                self.playerPause()
            default:
                break
            }
        }
    }
    
    //MARK:- 存储歌曲时缺少Index,重新设置index
    func resetIndex(model: BDSongModel?) {
        for (index,m) in self.musicArray.enumerated() {
            if m.song_id == model?.song_id {
                PlayerManager.shared.index = index
            }
        }
    }
    
    /// 返回当前时长
    var currentTime: Float64 {
        get{
            return CMTimeGetSeconds(self.player.currentTime())
        }
    }
    
    /// 总时长
    var duration: Float64? {
        get{
            if let d = self.player.currentItem?.duration {
                return CMTimeGetSeconds(d)
            }
            return nil
            
        }
    }
    
    //MARK:- 当前时间
    func getCurrentTime() -> String? {
        //获取当前时间
        let value = self.player.currentTime().value
        let timescale = self.player.currentTime().timescale
        if self.player.currentTime().timescale > 0  {
            let currentTime = value/Int64(timescale)
            return "\(currentTime)"
        }
        return nil
    }
    
    //MARK:- 总时长
    func getTotalTime() -> String? {
        //获取音乐总时长
        let d = self.player.currentItem?.duration.value
        let t = self.player.currentItem?.duration.timescale
        if self.player.currentItem?.duration.timescale != 0 {
            let totalTime = d!/Int64(t!)
            return "\(totalTime)"
        }
        return nil
    }
    
    //MARK:- 播放状态
    func playerStatus() -> Int {
        if currentPlayerItem.status == .readyToPlay {
            return 1
        } else {
            return 0
        }
    }

    //MARK:- 播放
    func playerPlay() {
        player.play()
        isPlaying = true
        NotificationCenter.post(name: .kReloadPlayStatus, object: isPlaying)
    }
    
    //MARK:- 暂停
    func playerPause() {
        player.pause()
        isPlaying = false
        NotificationCenter.post(name: .kReloadPlayStatus, object: isPlaying)
    }
    
    //MARK:- 播放歌曲
    func playMusic(model: BDSongModel?) {
        //当前播放的歌曲
        if model?.song_id == currentModel?.song_id && isPlaying {
            return
        }
        self.playReplaceItem(with: model)
    }
    
    //MARK:- 自动下一首/循环/随机
    func autoPlay() {
        if PlayerManager.shared.cycle == .single {
            //单曲循环播放
            self.playReplaceItem(with: PlayerManager.shared.currentModel)
        } else {
            //下一首
            self.playNext()
        }
    }

    //MARK:- 前一首
    func playPrevious() {
        if self.index == 0 {
            self.index = self.musicArray.count - 1
        } else {
            self.index -= 1
        }
        self.playReplaceItem(with: self.currentModel)
    }
    
    //MARK:- 下一首
    func playNext() {
        if self.index == self.musicArray.count - 1 {
            self.index = 0
        } else {
            self.index += 1
        }
        self.playReplaceItem(with: self.currentModel)
    }
  
    //MARK:-喜欢
    func hasBeenFavoriteMusic() -> Bool {
        return true
    }
    
    //MARK:-音量控制
    func playerVolume(with volumeFloat: CGFloat) {
        self.player.volume = Float(volumeFloat)
    }

    //MARK:- 播放进度
    func playerProgress(with progress: Double, completionHandler: ((CMTime) -> Void)? = nil) {
        self.resourceLoader?.seekRquired = true
        var progress = progress
        if self.isPlaying {
            // 将进度转换成播放时间（不能直接将进度条快进到播放结束）
            if (progress == CMTimeGetSeconds(self.player.currentItem!.duration)) {
                progress -= 0.5
            }
        }
        let time = CMTimeMakeWithSeconds(progress, preferredTimescale: Int32(NSEC_PER_SEC))
        self.player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero) { (finished) in
            if finished {
                completionHandler?(time)
            }
        }
    }
    
    func getSongPlay(model: BDSongModel?) {
        //每次播放重置index
        resetIndex(model: model)
        //播放的url,有可能取不到
        guard let url = URL(string: model?.file_link ?? "") else {
            self.autoPlay()
            return
        }
//        //有缓存播放缓存
//        let cacheFilePath = CacheFileHandle.cacheFileExists(with: url)
//        if cacheFilePath != nil {
//            let url = URL(fileURLWithPath: cacheFilePath!)
//            currentPlayerItem = AVPlayerItem(url: url)
//            print("有缓存，播放缓存文件")
//        } else {
//            //没有缓存播放网络文件
//            if self.resourceLoader == nil {
//               self.resourceLoader = ResourceLoader()
//            }
//            self.resourceLoader?.delegate = self
//            let asset = AVURLAsset(url: url.customSchemeURL()!, options: nil)
//            asset.resourceLoader.setDelegate(self.resourceLoader!, queue: DispatchQueue.main)
//            currentPlayerItem = AVPlayerItem(asset: asset)
//            print("无缓存，播放网络文件")
//        }

        currentPlayerItem = AVPlayerItem(url: url)
        self.player.replaceCurrentItem(with: currentPlayerItem)
        //调用播放
        self.playerPlay()

        //监听音乐的时间变化
        addMusicTimeMake()
        
        //通知页面模型改变
        NotificationCenter.post(name: .kMusicChange, object: model)
        
        //存储当前播放的歌曲
        UserDefaultsManager.shared.archiver(object: (model)!, key: CURRENTMUSIC)
    }
    
    //MARK:- 自动/切换播放
    fileprivate func playReplaceItem(with model: BDSongModel?) {
        self.playModel = model
        //记录歌曲和歌词状态
        self.lrcStatus = .loadding
        self.musicStatus = .loadding
        self.isFristPlayerPauseBtn = false
        var param = [String: Any]()
        param["method"] = "baidu.ting.song.play"
        param["songid"] = model?.song_id
        let d = RequestHelper.getCommonList(param).generate()
        NetWorkingTool.shared.requestDataBD(generate: d, isShowHUD: false, method: .get, successCallback: { [weak self](data: SongInfo?) in
            if let s = data {
                s.songinfo?.file_link = s.bitrate?.file_link
                self?.loadLrclink(lrclink: s.songinfo?.lrclink)
                self?.getSongPlay(model: s.songinfo)
            }
        })
    }
    
    //MARK:-获取歌词
    func loadLrclink(lrclink: String?) {
        if let lrclink = lrclink, !lrclink.isEmpty {
            NetWorkingTool.shared.downloadFile(fileURL: URL(string: lrclink)!, successCallback: { (fileUrl) in
                if let lrcs = LrcAnalyzer.shared.analyzerLrc(by: fileUrl!), !lrcs.isEmpty {
                    self.lrcStatus = .completed
                } else {
                    self.lrcStatus = .failed
                }
            })
        } else {
            self.lrcStatus = .failed
        }
    }
    
    //MARK:- 展示音乐播放界面
    func presentPlayController(vc: UIViewController?, model: BDSongModel?) {
        let playVC = MainPlayViewController(nibName: "MainPlayViewController", bundle: nil)
        playVC.model = model
//        vc?.presentPanModal(playVC)
        playVC.modalPresentationStyle = .fullScreen
        vc?.present(playVC, animated: true, completion: nil)
    }

    //MARK:- 监听音乐时间变化
    func addMusicTimeMake() {
        var tempTime: Float64?
        let cmt = CMTime(value: CMTimeValue(1.0), timescale: CMTimeScale(1.0))
        timeObserve = player.addPeriodicTimeObserver(forInterval: cmt, queue: DispatchQueue.main) { [weak self](time) in
            //过滤重复的时间
            let ct = CMTimeGetSeconds(time)
            if ct == tempTime {
                return
            }
            tempTime = ct
            if let duration = self?.player.currentItem?.duration {
                let tt = CMTimeGetSeconds(duration)
                NotificationCenter.post(name: .kMusicTimeInterval, object: [ct,tt])
            }
        }
    }

    //MARK:- 清空播放器监听属性
    func releasePlayer() {
        self.removeObserver(self, forKeyPath: "loadedTimeRanges")
        self.removeObserver(self, forKeyPath: "status")
        self.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        self.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        NotificationCenter.default.removeObserver(self)
        self.currentPlayerItem = nil
        self.player = nil
    }
    //MARK:- KVO监听播放状态
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let item = object as? AVPlayerItem {
            switch keyPath! {
            case "status":
                switch item.status {
                case .readyToPlay:
                    //存储歌曲总时间
                    if let t = self.getTotalTime(), (Int(t) ?? 0) > 0{
                        UserDefaultsManager.shared.userDefaultsSet(object: "\(t)", key: TOTALTIME)
                    }
                    //歌曲切换更新锁屏歌曲
                    if isLockedScreen {
                        self.updateLockedScreenMusic()
                    }
                case .failed:
                    self.musicStatus = .failed
                default:
                    break
                }
            case "loadedTimeRanges":
                //监听播放器的缓冲进度
                let loadedTimeRanges = item.loadedTimeRanges
                // 获取缓冲区域
                if let timeRange = loadedTimeRanges.first?.timeRangeValue {
                    let startSeconds = CMTimeGetSeconds(timeRange.start)
                    let durationSeconds = CMTimeGetSeconds(timeRange.duration)
                    // 计算缓冲总进度
                    let timeInterval = startSeconds + durationSeconds
                    let duration = item.duration
                    let totalDuration = CMTimeGetSeconds(duration)
                    self.bufferProgress = CGFloat(timeInterval/totalDuration)
                }
            case "playbackBufferEmpty":
                //监听播放器在缓冲数据的状态
                self.musicStatus = .loadding
            case "playbackLikelyToKeepUp":
                //由于 AVPlayer 缓存不足就会自动暂停，所以缓存充足了需要手动播放，才能继续播放
                if self.musicStatus != .readyToPlay {
                    self.musicStatus = .readyToPlay
                }
            default:
                break
            }
        }
    }
    
    //MARK:-锁屏时候的设置，效果需要在真机上才可以看到
    func updateLockedScreenMusic() {
        guard let model = self.playModel else {
            return
        }
        let tt = self.getTotalTime()
        let ct = self.getCurrentTime()
        var info = [String: Any]()
        // 设置持续时间（歌曲的总时间）
        info[MPMediaItemPropertyPlaybackDuration] = tt
        // 设置当前播放进度
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = ct
        //设置歌曲名
        info[MPMediaItemPropertyTitle] = model.title ?? ""
        //设置演唱者
        info[MPMediaItemPropertyArtist] = model.author ?? ""
        
        //歌手头像
        if let url = (model.pic_big ?? "").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            if let data = try? Data(contentsOf: URL(string: url)!) {
                let artwork = MPMediaItemArtwork.init(boundsSize: CGSize(width: 400, height: 400)) { (size) -> UIImage in
                    return UIImage(data: data)!
                }
                info[MPMediaItemPropertyArtwork] = artwork
            }
        }
        info[MPNowPlayingInfoPropertyPlaybackProgress] = Int(ct!)!/Int(tt!)!
        //进度光标的速度（这个随 自己的播放速率调整，我默认是原速播放）
        info[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
}

//extension PlayerManager: ResourceLoaderDelegate {
//    
//    func loader(_ loader: ResourceLoader, cache progress: CGFloat) {
//        print(progress)
//        self.bufferProgress = progress
//    }
//    
//    func loader(_ loader: ResourceLoader, failLoading error: Error) {
//        print("failLoading")
//    }
//}
