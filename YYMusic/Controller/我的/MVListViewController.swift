//
//  MVListViewController.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/26.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit

class MVListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    fileprivate var mvList: [MVList] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        let lbl = UILabel()
        lbl.text = "我的MV"
        self.navigationItem.titleView = lbl
        
        self.tableView.estimatedRowHeight = 70
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.getMvList()
    }

    func getMvList() {
        var param = [String: Any]()
        param["method"] = "baidu.ting.artist.getArtistMVList"
        param["page"] = 0
        param["size"] = 50
        param["id"] = 2517
        param["usetinguid"] = 1
        param["cuid"] = "2c02f143b48e415e568cf806b7691a02e318beb6"
        let d = RequestHelper.getCommonList(param).generate()
        NetWorkingTool.shared.requestDataBD(generate: d, method: .get, successCallback: { [weak self](data: MVBase?) in
            if let list = data?.result?.mvList {
                self?.mvList = list
                self?.tableView.reloadData()
            }
        })
    }

}

extension MVListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mvList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mv = mvList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "musicCell", for: indexPath)
        let img1 = cell.viewWithTag(1) as! UIImageView
        let lbl2 = cell.viewWithTag(2) as! UILabel
        let lbl3 = cell.viewWithTag(3) as! UILabel
//        img1.layer.cornerRadius = 6
//        img1.layer.masksToBounds = true
        
        if let urlStr = mv.thumbnail, let url = URL(string: urlStr) {
            img1.kf.setImage(with: url)
        }
        lbl2.text = mv.title ?? ""
        lbl2.font = UIFont.systemFont(ofSize: 17)
        
        lbl3.text = mv.artist ?? ""
        lbl3.font = UIFont.systemFont(ofSize: 13)
        lbl3.textColor = UIColor.gray
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let mv = mvList[indexPath.row]
        getMvPlay(mv_id: mv.mv_id, fileName: mv.title, cover: mv.thumbnail2)
    }
    
    func getMvPlay(mv_id: String?, fileName: String?, cover: String?) {
        var param = [String: Any]()
        param["method"] = "baidu.ting.mv.playMV"
        param["mv_id"] = mv_id
        param["song_id"] = "33847306"
        param["cuid"] = "2c02f143b48e415e568cf806b7691a02e318beb6"
        let d = RequestHelper.getCommonList(param).generate()
        NetWorkingTool.shared.requestDataBD(generate: d, method: .get, successCallback: { [weak self](data: MVBase?) in
            if let files = data?.result?.files {
                let vc = MVPlayViewController()
                vc.fileTitle = fileName
                vc.mvFileBase = files
                vc.cover = cover
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        })
    }
}
