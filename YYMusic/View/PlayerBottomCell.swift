//
//  PlayerBottomCell.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/14.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit

class PlayerBottomCell: UICollectionViewCell {
    static let identifier = String(describing: PlayerBottomCell.self)
    /*歌手头像*/
    @IBOutlet weak var headerImageView: UIImageView!
    /*歌名*/
    @IBOutlet weak var songNameLbl: UILabel!
    /*歌手名*/
    @IBOutlet weak var songerLbl: UILabel!
    /*播放暂停按钮*/
    @IBOutlet weak var playAndPauseBtn: UIButton!
    //    var playAndPauseBtn: UIButton!
    //    /*下一首按钮*/
    //    var nextBtn: UIButton!
    //    /*进度*/
    //    var progressSlider: UISlider!
    //    /*定时器*/
    //     var timer: Timer!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor(red: 57/255, green: 57/255, blue: 58/255, alpha: 1.0)
        songNameLbl.textColor = kThemeColor
        songNameLbl.font = kFont20
        songerLbl.textColor = .white
        songerLbl.font = kFont14
    }

}
