//
//  TrackListViewController.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/14.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit
import Kingfisher

class TrackListViewController: UIViewController {
    
    var type: BillListType?
    @IBOutlet weak var tableView: UITableView!
    fileprivate var songs: [BDSongModel] = []
    
    fileprivate var changeModels: [MusicModel] = []
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
        
        self.getMusicList()
    }

    func getMusicList() {
        var param = [String: Any]()
        param["method"] = "baidu.ting.billboard.billList"
        param["type"] = type?.rawValue
        param["size"] = 100
        param["cuid"] = "2c02f143b48e415e568cf806b7691a02e318beb6"
        let d = RequestHelper.getCommonList(param).generate()
        NetWorkingTool.shared.requestDataBD(generate: d, method: .get, successCallback: { [weak self](data: SongList?) in
            if let list = data?.song_list {
                self?.songs = list
                self?.tableView.reloadData()
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
        tableView.deselectRow(at: indexPath, animated: true)
        let song = songs[indexPath.row]
        getSongPlay(songid: song.song_id, indexPath: indexPath)
    }
    
    func getSongPlay(songid: String?, indexPath: IndexPath) {
        var param = [String: Any]()
        param["method"] = "baidu.ting.song.play"
        param["songid"] = songid
        param["cuid"] = "2c02f143b48e415e568cf806b7691a02e318beb6"
        let d = RequestHelper.getCommonList(param).generate()
        NetWorkingTool.shared.requestDataBD(generate: d, method: .get, successCallback: { (data: SongInfo?) in
            if let s = data {
                let song = MusicModel()
                song.playUrl32 = s.bitrate?.file_link
                song.coverSmall = s.songinfo?.pic_small
                song.nickname = s.songinfo?.author
                song.title = s.songinfo?.title
                song.coverLarge = s.songinfo?.pic_big
                song.coverMiddle = s.songinfo?.pic_premium
                song.lrclink = s.songinfo?.lrclink
                PlayerManager.shared.playMusic(model: song)
            }
        })
    }
    
}
