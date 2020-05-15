//
//  PlayerBottomView.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/14.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit
import MediaPlayer

class PlayerFlowLayout: UICollectionViewFlowLayout {

    override func prepare() {
        self.scrollDirection = .horizontal
        self.sectionInset = UIEdgeInsets(top: self.insetY, left: self.insetX, bottom: self.insetY, right: self.insetX)
        self.itemSize = CGSize(width: self.itemWidth, height: self.itemHeight)
        self.minimumLineSpacing = 0
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let originalAttributesArr = super.layoutAttributesForElements(in: rect)
        //复制布局,以下操作，在复制布局中处理
        var attributesArr: Array<UICollectionViewLayoutAttributes> = Array()
        for attr in originalAttributesArr! {
            attributesArr.append(attr.copy() as! UICollectionViewLayoutAttributes)
        }
        return attributesArr
    }
    
    //MARK 配置方法
    var itemWidth: CGFloat {
        return (self.collectionView?.bounds.size.width)!
    }
    
    var itemHeight: CGFloat {
        return (self.collectionView?.bounds.size.height)!
    }

    //设置左右缩进
    var insetX: CGFloat {
        return ((self.collectionView?.bounds.size.width)!-self.itemWidth)/2
    }
    
    //上下缩进
    var insetY: CGFloat {
        return ((self.collectionView?.bounds.size.height)!-self.itemHeight)/2
    }
    
    //是否实时刷新布局
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

class PlayerBottomView: UIView {
    static let shared = PlayerBottomView()
    var reloadCallback: ObjectCallback?
    var selectedIndex: Int = 0
    
    fileprivate var playerBarH: CGFloat = 65.0
    fileprivate var collectionView: UICollectionView!
    fileprivate var dragStartX: CGFloat = 0
    fileprivate var dragEndX: CGFloat = 0
    fileprivate var dragAtIndex: Int = 0
    fileprivate var musicModel: MusicModel?
    //标记是否在单曲循环 (如果是yes是当前这首播放完时自动还从新开始播放)当前播放的
    fileprivate var isSinglecycle: Bool = false
    fileprivate var timer: Timer!
    fileprivate var isFirstTime: Bool = true
    override init(frame: CGRect) {
        super.init(frame: frame)
        let layout = PlayerFlowLayout()
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.left.right.bottom.top.equalTo(self)
        }
   
        collectionView.register(UINib(nibName: "PlayerBottomCell", bundle: nil), forCellWithReuseIdentifier: PlayerBottomCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(tableView: UITableView, superView: UIView) {
        // tableview  给底部留距离
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: playerBarH+tabHeight))
        superView.addSubview(self)
        self.snp.makeConstraints { (make) in
            make.left.right.equalTo(superView)
            make.bottom.equalTo(superView.snp.bottom).offset(-tabHeight)
            make.height.equalTo(playerBarH)
        }
    }
    
    //刷新界面
    func reloadUI(music: MusicModel) {
        self.musicModel = music
        self.collectionView.reloadData()
    }
    
    func reloadData(with index: Int) {
        //记录播放状态和播放歌曲角标
        PlayerManager.shared.isPlaying = true
        PlayerManager.shared.index = index
        //获取播放歌曲模型
        let model = PlayerManager.shared.musicArray[index]
        self.musicModel = model
        //存储当前播放的歌曲
        UserDefaultsManager.shared.archiver(object: model, key: CURRENTMUSIC)
        //回调刷新列表
        if let callback = self.reloadCallback {
            callback(self.musicModel!)
        }
        //播放音乐
        PlayerManager.shared.replaceItem(with: model.playUrl32 ?? "")
        self.collectionView.reloadData()
        //开始计时
        startTimer()
        //获取总时间
        if let time = UserDefaultsManager.shared.userDefaultsGet(key: TOTALTIME) as? String {
            lockScreeen(totalTime: time)
        }
    }
    
    //MARK:-开启定时器
    func startTimer() {
        //开始定时器开始记录存储总时间
        isFirstTime = true
        self.timer = Timer(timeInterval: 0.1, target: self, selector: #selector(timerAct), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .common)
    }
    
    //MARK:-关闭定时器
    func stopTimer() {
        self.timer.invalidate()
        self.timer = nil
    }
    
    @objc func timerAct() {
        let currentTime = PlayerManager.shared.getCurrentTime()
        let totalTime = PlayerManager.shared.getTotalTime()

        //如果当前时间=总时长 就直接下一首(或者单曲循环)
        if currentTime == totalTime {
            self.autoNext()
        }
        //更新进度圆环
        if let cell = collectionView.visibleCells.first as? PlayerBottomCell {
            let cT = Double(currentTime ?? "0")
            let dT = Double(totalTime ?? "0")
            if let ct = cT, let dt = dT, dt > 0.0 {
                cell.progress = CGFloat(ct/dt)
            }
            //播放完归零
            if currentTime == totalTime {
                cell.progress = CGFloat(0.0)
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
    
    //MARK:-自动下一首或者是单曲循环
    func autoNext() {
        self.stopTimer()
        if self.isSinglecycle {
            self.reloadData(with: PlayerManager.shared.index)
        } else {
            PlayerManager.shared.playNext()
            self.reloadData(with: PlayerManager.shared.index)
        }
    }
    
    //手指拖动开始
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dragStartX = scrollView.contentOffset.x
        dragAtIndex = self.selectedIndex
    }
    
    //手指拖动停止
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        dragEndX = scrollView.contentOffset.x
        //在主线程执行居中方法
        DispatchQueue.main.async {
            self.fixCellToCenter()
        }
    }
    
    //居中
    @objc func fixCellToCenter() {
        if self.selectedIndex != dragAtIndex {
            self.scrollToCenterAnimated(animated: true)
            return
        }
        //最小滚动距离
        let dragMiniDistance = self.bounds.width/10
        if dragStartX - dragEndX >= dragMiniDistance {
            self.selectedIndex -= 1 //向右
        } else if dragEndX - dragStartX >= dragMiniDistance {
            self.selectedIndex += 1 //向右
        }
        let maxIndex = collectionView.numberOfItems(inSection: 0) - 1
        self.selectedIndex = max(self.selectedIndex, 0)
        self.selectedIndex = min(self.selectedIndex, maxIndex)
        self.scrollToCenterAnimated(animated: true)
    }
    
    //滚动到中间
    func scrollToCenterAnimated(animated: Bool) {
        collectionView.scrollToItem(at: IndexPath(row: self.selectedIndex, section: 0), at: .centeredHorizontally, animated: animated)
    }
    //MARK:-锁屏传值
    func lockScreeen(totalTime: String) {
        if PlayerManager.shared.musicArray.count > 0 {
            let model = PlayerManager.shared.musicArray[PlayerManager.shared.index]
            var info = [String: Any]()
            //设置歌曲时长
            info[MPMediaItemPropertyPlaybackDuration] = Double(totalTime) ?? 0.0
            info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0.0
            //设置歌曲名
            info[MPMediaItemPropertyTitle] = model.title ?? ""
            //设置演唱者
            info[MPMediaItemPropertyArtist] = model.nickname ?? ""
            //歌手头像
            if let url = (model.coverLarge ?? "").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
                if let data = try? Data(contentsOf: URL(string: url)!) {
                    let artwork = MPMediaItemArtwork.init(boundsSize: CGSize(width: 400, height: 400)) { (size) -> UIImage in
                        return UIImage(data: data)!
                    }
                    info[MPMediaItemPropertyArtwork] = artwork
                }
            }
            //进度光标的速度（这个随 自己的播放速率调整，我默认是原速播放）
            info[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
            MPNowPlayingInfoCenter.default().nowPlayingInfo = info
        }
    }
}

extension PlayerBottomView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlayerBottomCell.identifier, for: indexPath) as! PlayerBottomCell
        cell.isSongPlayer = PlayerManager.shared.isPlaying
        cell.musicModel = musicModel
        cell.tapCallback = { [weak self](value) in
            if PlayerManager.shared.isFristPlayerPauseBtn && PlayerManager.shared.isPlaying {
                PlayerManager.shared.isFristPlayerPauseBtn = false
                if let music = UserDefaultsManager.shared.unarchive(key: CURRENTMUSIC) as? MusicModel {
                    PlayerManager.shared.replaceItem(with: music.playUrl32 ?? "")
                    self?.startTimer()
                } else {
                   self?.reloadData(with: 0)
                }
            } else {
                if let isPlaying = value as? Bool {
                    if isPlaying {
                        self?.startTimer()
                    } else {
                        self?.stopTimer()
                    }
                }
            }
            
        }
        return cell
    }
}
