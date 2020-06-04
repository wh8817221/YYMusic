//
//  LyricViewController.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/20.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit
import AVFoundation

class LyricViewController: UIViewController {
    
    var lrcLbl: LrcLabel?
    
    var model: BDSongModel?
    //当前歌词所在的位置
    fileprivate var currentRow: Int?
    var lrcArray: [Lrclink] = [] {
        didSet {
            if lrcArray.isEmpty {
                emptyLbl.isHidden = false
                emptyLbl.text = "纯音乐，无歌词"
                self.tableView.reloadData()
            } else {
                emptyLbl.isHidden = true
                self.tableView.reloadData()
            }
        }
    }
    
    fileprivate lazy var emptyLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = kFont15
        return lbl
    }()
    
    fileprivate var isDragging: Bool = false
    fileprivate var tableView: UITableView!
    fileprivate var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.backgroundColor = UIColor.clear
        tableView.register(LrcCell.self, forCellReuseIdentifier: LrcCell.identifier)
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self.view)
        }
        
        NotificationCenter.addObserver(observer: self, selector: #selector(musicLrcChange), name: .kLrcChange)
        NotificationCenter.addObserver(observer: self, selector: #selector(musicTimeInterval), name: .kMusicTimeInterval)
        
        self.tableView.addSubview(emptyLbl)
        emptyLbl.snp.makeConstraints { (make) in
            make.center.equalTo(tableView)
        }

        self.lrcArray = PlayerManager.shared.lrcArray ?? []
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.removeObserver(observer: self, name: .kMusicTimeInterval)
        NotificationCenter.removeObserver(observer: self, name: .kLrcChange)
    }
    
    func createTimer() {
        self.timer = Timer(timeInterval: 1.0/30.0, target: self, selector: #selector(upddatePerSecond), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .default)
    }
    
    @objc func upddatePerSecond() {
        if !isDragging {
            let ct = PlayerManager.shared.currentTime
            let cs = CMTimeGetSeconds(ct)
            //歌词滚动显示
            for (index,lrc) in self.lrcArray.enumerated() {
                let currrentLrc = lrc
                var nextLrc: Lrclink?
                //获取下一句歌词
                if index == self.lrcArray.count - 1 {
                    nextLrc = lrcArray[index]
                } else {
                    nextLrc = lrcArray[index+1]
                }
                
                if Double(cs) >= currrentLrc.time! && Double(cs) < (nextLrc?.time)! {
                    self.lrcLbl?.text = currrentLrc.lrc
                    self.lrcLbl?.progress = CGFloat((Double(cs)-currrentLrc.time!)/((nextLrc?.time)!-currrentLrc.time!))
                }
            }
        }
    }
    
    func removeTimer() {
        self.timer.invalidate()
        self.timer = nil
    }
    
    //监听歌词状态
    @objc fileprivate func musicLrcChange(_ sender: Notification) {
        if let lrcs = sender.object as? [Lrclink] {
            self.lrcArray = lrcs
        } else {
            self.lrcArray.removeAll()
            self.tableView.reloadData()
            emptyLbl.isHidden = false
            emptyLbl.text = "歌词加载中..."
        }
    }
    
    //监听时间变化
    @objc fileprivate func musicTimeInterval(_ sender: Notification) {
        if let timeArr = sender.object as? [Float64] {
            let cs = timeArr[0]
            if !isDragging {
                //歌词滚动显示
                for (index,lrc) in self.lrcArray.enumerated() {
                    if lrc.time! < Double(cs) {
                        self.currentRow = index
                        let indexPath = IndexPath(row: index, section: 0)
                        self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.removeObserver(observer: self, name: .kMusicTimeInterval)
        NotificationCenter.removeObserver(observer: self, name: .kLrcChange)
    }
}
extension LyricViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lrcArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let lrc = lrcArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: LrcCell.identifier, for: indexPath) as! LrcCell
        cell.lrcLbl?.text = lrc.lrc
        cell.lrcLbl?.backgroundColor = .clear
        if currentRow == indexPath.row {
            cell.lrcLbl.textColor = .green
        } else {
            cell.lrcLbl.textColor = .white
        }
        return cell
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isDragging = true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            isDragging = false
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isDragging = false
    }
    
    
}
