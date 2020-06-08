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
    
    var progress: CGFloat = 0 {
        didSet {
            let cell = tableView.cellForRow(at: IndexPath(row: scrollRow, section: 0)) as? LrcCell
            cell?.progress = progress
        }
    }
    //当前歌词所在的位置
    var scrollRow: Int = -1 {
        didSet {
            if scrollRow == oldValue { return }
            tableView.reloadRows(at: tableView.indexPathsForVisibleRows!, with: .none)
            tableView.scrollToRow(at: IndexPath(row: scrollRow, section: 0), at: .middle, animated: true)
        }
    }
    var lrcArray: [Lrclink] = [] {
        didSet {
            if lrcArray.isEmpty {
                tipLbl.isHidden = false
                tipLbl.text = "纯音乐，无歌词"
            } else {
                tipLbl.isHidden = true
            }
            self.tableView.reloadData()
        }
    }
    
    fileprivate lazy var tipLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = kFont15
        return lbl
    }()
    
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
        tableView.register(LrcCell.self, forCellReuseIdentifier: LrcCell.identifier)
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self.view)
        }
        
        NotificationCenter.addObserver(observer: self, selector: #selector(musicLrcChange), name: .kLrcLoadStatus)
        NotificationCenter.addObserver(observer: self, selector: #selector(musicTimeInterval), name: .kLrcTimeChange)
        
        self.tableView.addSubview(tipLbl)
        tipLbl.snp.makeConstraints { (make) in
            make.center.equalTo(tableView)
        }

        self.lrcArray = PlayerManager.shared.lrcArray ?? []
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.removeObserver(observer: self, name: .kLrcTimeChange)
        NotificationCenter.removeObserver(observer: self, name: .kLrcLoadStatus)
    }

    //监听歌词状态
    @objc fileprivate func musicLrcChange(_ sender: Notification) {
        if let status = sender.object as? LrcLoadStatus {
            switch status {
            case .loadding:
                self.lrcArray.removeAll()
                self.tableView.reloadData()
                tipLbl.isHidden = false
                tipLbl.text = "歌词加载中..."
            case .completed:
                self.lrcArray = PlayerManager.shared.lrcArray ?? []
            case .failed:
                self.lrcArray = []
            default:
                break
            }
        }
    }
    
//    监听时间变化
    @objc fileprivate func musicTimeInterval(_ sender: Notification) {
        if let lrc = sender.object as? (index: Int, progress: CGFloat) {
            self.scrollRow = lrc.index
            self.progress = lrc.progress
        }
    }
    
    deinit {
        NotificationCenter.removeObserver(observer: self, name: .kLrcTimeChange)
        NotificationCenter.removeObserver(observer: self, name: .kLrcLoadStatus)
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
        if scrollRow == indexPath.row {
            cell.progress = progress
        } else {
            cell.progress = 0
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
