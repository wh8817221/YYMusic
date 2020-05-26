//
//  BillListViewController.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/19.
//  Copyright © 2020 haoge. All rights reserved.
//
import UIKit
import Kingfisher

enum BillListType: Int {
    //        type:榜单类型（1、新歌榜 2、热歌榜 3、摇滚榜 4、爵士榜 5、流行榜 6、欧美金曲榜 7、经典老歌榜 8、情歌对唱榜 9、影视金曲榜 10、网络金曲榜）
    case random = 0
    case new = 1
    case hot = 2
    case rock = 3
    case jazz = 4
    case popular = 5
    case west = 6
    case classic = 7
    case love = 8
    case film = 9
    case net = 10
    
    func getName() -> String {
        switch self {
        case .random:
            return "随便听听"
        case .new:
            return "新歌榜"
        case .hot:
            return "热歌榜"
        case .rock:
            return "摇滚榜"
        case .jazz:
            return "爵士榜"
        case .popular:
            return "流行榜"
        case .west:
            return "欧美金曲榜"
        case .classic:
            return "经典老歌榜"
        case .love:
            return "情歌对唱榜"
        case .film:
            return "影视金曲榜"
        default:
            return "网络金曲榜"
        }
    }
    
}

class BillListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    fileprivate var songs: [BDSongModel] = []
    fileprivate var types = [BillListType]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let lbl = UILabel()
        lbl.text = "全部榜单"
        self.navigationItem.titleView = lbl
        
        self.tableView.estimatedRowHeight = 70
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.delegate = self
        self.tableView.dataSource = self
        initData()
    }

    func initData() {
        for i in 0...10 {
            let type = BillListType(rawValue: i)
            self.types.append(type!)
        }
        self.tableView.reloadData()
    }
}

extension BillListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.types.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = types[indexPath.row]
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.font = kFont15
        cell.textLabel?.text = type.getName()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let type = types[indexPath.row]
        if type == .random {
            let vc = getStoryboardInstantiateViewController(identifier: "MusicListViewController") as? MusicListViewController
            self.navigationController?.pushViewController(vc!, animated: true)
        } else {
            let vc = getStoryboardInstantiateViewController(identifier: "TrackListViewController") as? TrackListViewController
            vc?.type = type
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
}
