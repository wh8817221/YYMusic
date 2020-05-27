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
    var model: MusicModel?
    //当前歌词所在的位置
    fileprivate var currentRow: Int?
    fileprivate var lrcArray: [Lrclink] = []
    fileprivate var isDragging: Bool = false
    fileprivate var tableView: UITableView!
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellID")
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self.view)
        }
        
        NotificationCenter.addObserver(observer: self, selector: #selector(musicTimeInterval), name: .kMusicTimeInterval)
        loadLrclink()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.removeObserver(observer: self, name: .kMusicTimeInterval)
    }
    
    @objc fileprivate func musicTimeInterval(_ sender: Notification) {
        if let timeArr = sender.object as? [Float64] {
            let cs = timeArr[0]
            if !isDragging {
                //歌词滚动显示
                for (index,lrc) in self.lrcArray.enumerated() {
//                    let currrentLrc = lrc
//                    //获取下一句歌词
//                    let nextIndex = index+1
//                    var nextLrc: Lrclink?
//                    if nextIndex < self.lrcArray.count {
//                        nextLrc = self.lrcArray[nextIndex]
//                    }
                    if lrc.time! < Double(cs) {
                        self.currentRow = index
                        let currentIndexPath = IndexPath(row: index, section: 0)
                        self.tableView.scrollToRow(at: currentIndexPath, at: .middle, animated: true)
                        lrcLbl?.text = lrc.lrc
                        self.tableView.reloadData()
                    }
                    //根据进度,显示label画多少
//                    let progress = (cs-currrentLrc.time!)/((nextLrc?.time)!-currrentLrc.time!)
//                    lrcLbl?.progress = CGFloat(progress)
                }
            }
        }
    }
 
    func loadLrclink() {
        //本地文件
        if let path = Bundle.main.path(forResource: "shaonian", ofType: "txt") {
            if let lrcs = LrcAnalyzer.shared.analyzerLrc(by: path) {
                self.lrcArray = lrcs
                self.tableView.reloadData()
            }
        }
        //网络文件
//        if let lrclink = model?.lrclink {
//            NetWorkingTool.shared.downloadFile(fileURL: URL(string: lrclink)!, successCallback: { (fileUrl) in
//                if let lrcs = LrcAnalyzer.shared.analyzerLrc(by: fileUrl!) {
//                    print(lrcs)
//                }
//            })
//        }
    }
    
}
extension LyricViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lrcArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let lrc = lrcArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)
        cell.textLabel?.text = lrc.lrc
        cell.textLabel?.textAlignment = .center
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.backgroundColor = .clear
        if currentRow == indexPath.row {
            cell.textLabel?.textColor = .green
        } else {
            cell.textLabel?.textColor = .white
        }
        cell.selectionStyle = .none
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
