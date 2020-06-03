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
            if self.type == .new {
                PlayerManager.shared.musicArray = songs
            }
        }
    }
    fileprivate var changeModels: [MusicModel] = []
    
    fileprivate var size = 20
    fileprivate var page = 0
    
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
                self?.songs.append(contentsOf: d.song_list!)
                self?.tableView.reloadData()
                if d.billboard?.havemore == true {
                    self?.tableView.mj_footer?.isHidden = false
                } else {
                    self?.tableView.mj_footer?.isHidden = true
                }
            }
        })
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
        lbl3.textColor = UIColor.gray
        
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        PlayerManager.shared.musicArray = songs
        tableView.deselectRow(at: indexPath, animated: true)
        let song = songs[indexPath.row]
        PlayerManager.shared.playMusic(model: song)
    }
}
