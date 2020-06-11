//
//  MoreListViewController.swift
//  YYMusic
//
//  Created by 王浩 on 2020/6/4.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit

class MoreListViewController: UIViewController {
    
    var musicModel: BDSongModel?
    fileprivate var visualEffectView: UIVisualEffectView!
    fileprivate var tableView: UITableView!
    fileprivate var topContentView: UIView!
    fileprivate var bottomContentView: UIView!
    fileprivate var playStyleBtn: UIButton!
    fileprivate var closedBtn: UIButton!
    fileprivate var musicList: [BDSongModel]! {
        get {
            return PlayerManager.shared.musicArray
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        
        let effect = UIBlurEffect(style: .light)
        visualEffectView = UIVisualEffectView(effect: effect)
        self.view.addSubview(visualEffectView)
        visualEffectView.snp.makeConstraints { (make) in
            make.left.right.bottom.top.equalTo(self.view)
        }
        
        topContentView = UIView()
        self.view.addSubview(topContentView)
        topContentView.snp.makeConstraints { (make) in
            make.height.equalTo(50)
            make.left.right.top.equalTo(self.view)
        }
        
        playStyleBtn = UIButton(type: .custom)
        playStyleBtn.titleLabel?.font = kFont15
        playStyleBtn.setTitle("当前播放(\(musicList.count)首歌曲)", for: .normal)
//        playStyleBtn.setTitle("顺序播放(\(musicList.count)首)", for: .normal)
//        playStyleBtn.setImage(UIImage(named: "icon_order"), for: .normal)
        topContentView.addSubview(playStyleBtn)
        playStyleBtn.snp.makeConstraints { (make) in
            make.left.equalTo(topContentView.snp.left).offset(15)
            make.height.equalTo(24)
            make.centerY.equalTo(topContentView.snp.centerY)
        }
        
        let tLine = UIView()
        tLine.backgroundColor = kLineColor
        topContentView.addSubview(tLine)
        tLine.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.left.right.bottom.equalTo(topContentView)
        }
        
        
        bottomContentView = UIView()
        self.view.addSubview(bottomContentView)
        bottomContentView.snp.makeConstraints { (make) in
            make.height.equalTo(49)
            make.left.right.bottom.equalTo(self.view)
        }
        
        closedBtn = UIButton(type: .custom)
        closedBtn.titleLabel?.font = kFont15
        closedBtn.setTitle("关闭", for: .normal)
        closedBtn.addTarget(self, action: #selector(closedAction), for: .touchUpInside)
        bottomContentView.addSubview(closedBtn)
        closedBtn.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(bottomContentView)
        }
        
        let bLine = UIView()
        bLine.backgroundColor = kLineColor
        bottomContentView.addSubview(bLine)
        bLine.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.left.right.top.equalTo(bottomContentView)
        }
        
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.rowHeight = 44
        tableView.backgroundColor = .clear
        tableView.separatorColor = kLineColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(topContentView.snp.bottom)
            make.left.right.equalTo(self.view)
            make.bottom.equalTo(bottomContentView.snp.top)
        }
    }
    
    @objc fileprivate func closedAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    deinit {
        print("\(self)释放了")
    }
}

extension MoreListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = musicList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if model.song_id == musicModel?.song_id {
            cell.textLabel?.textColor = kThemeColor
        } else {
            cell.textLabel?.textColor = .white
        }
        
        cell.textLabel?.text = "\(model.title ?? "") - \(model.author ?? "")"
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let song = musicList[indexPath.row]
        self.musicModel = song
        self.tableView.reloadData()
        PlayerManager.shared.playMusic(model: song)
    }
}
