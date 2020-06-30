//
//  TrackListViewController.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/14.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit
import Kingfisher
import MJRefresh

class TrackListViewController: UIViewController {
    
    var type: BillListType?
    @IBOutlet weak var tableView: UITableView!
    fileprivate var songs: [BDSongModel] = [] {
        didSet {
            if self.type == .new || isSelectedMusic{
                PlayerManager.shared.musicArray = songs
                PlayerManager.shared.resetIndex(model: currentModel)
            }
        }
    }
    
    fileprivate var currentModel: BDSongModel?
    fileprivate var size = 20
    fileprivate var page = 0
    fileprivate var isSelectedMusic: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = kBackgroundColor
        self.tableView.estimatedRowHeight = 70
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = .clear
        self.tableView.separatorColor = kLineColor
        // tableview  给音乐播放留距离
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 65))
        // tableview  给音乐播放留距离
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 65))
        
        //获取上次播放存储的歌曲
        if let music = UserDefaultsManager.shared.unarchive(key: CURRENTMUSIC) as? BDSongModel {
            self.currentModel = music
        }
        
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            self.page = 0
            self.getMusicList()
        })
        tableView.mj_footer = MJRefreshBackNormalFooter(refreshingBlock: {
            self.page += self.size
            self.getMusicList()
        })
        self.tableView.mj_footer?.isHidden = true
        self.tableView.mj_header?.isAutomaticallyChangeAlpha = true
        self.tableView.mj_header?.beginRefreshing()
        
        //注册监听音乐模型改变
        NotificationCenter.addObserver(observer: self, selector: #selector(musicChange(_:)), name: .kMusicChange)
        
    }

    @objc fileprivate func musicChange(_ notification: Notification) {
        if let model = notification.object as? BDSongModel {
            self.currentModel = model
            self.tableView.reloadData()
        }
    }
    
    func getMusicList() {
        var param = [String: Any]()
        param["method"] = "baidu.ting.billboard.billList"
        param["type"] = type?.rawValue
        param["size"] = size
        param["offset"] = page
        if self.page == 0 {
            self.songs = []
        }
        let d = RequestHelper.getCommonList(param).generate()
        NetWorkingTool.shared.requestDataBD(generate: d, method: .get, successCallback: { [weak self](data: SongList?) in
            // refresh
            self?.tableView.mj_header?.endRefreshing()
            self?.tableView.mj_footer?.endRefreshing()
            if let d = data {
                if d.billboard?.havemore == true {
                    self?.tableView.mj_footer?.isHidden = false
                } else {
                    self?.tableView.mj_footer?.isHidden = true
                }
                
                if let list = d.song_list {
                    self?.songs = (self?.songs)! + list
                }
                
                self?.tableView.reloadData()
            }
        })
    }
    
    deinit {
        NotificationCenter.removeObserver(observer: self, name: .kMusicChange)
    }
}

extension TrackListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let song = songs[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "musicCell", for: indexPath)
        let img1 = cell.viewWithTag(1) as! UIImageView
        let lbl2 = cell.viewWithTag(2) as! UILabel
        let lbl3 = cell.viewWithTag(3) as! UILabel
        img1.layer.cornerRadius = img1.frame.height/2
        img1.layer.masksToBounds = true
        if let urlStr = song.pic_big, let url = URL(string: urlStr) {
            img1.kf.setImage(with: url)
        }
        lbl2.text = song.title ?? ""
        lbl2.font = UIFont.systemFont(ofSize: 17)
        
        lbl3.text = song.author ?? ""
        lbl3.font = UIFont.systemFont(ofSize: 13)
        
        if currentModel?.song_id == song.song_id {
            lbl2.textColor = kThemeColor
            lbl3.textColor = kThemeColor
        } else {
            lbl2.textColor = .black
            lbl3.textColor = .gray
        }
        
        
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        isSelectedMusic = true
        tableView.deselectRow(at: indexPath, animated: true)
        let song = songs[indexPath.row]
        PlayerManager.shared.playMusic(model: song)
    }
}
