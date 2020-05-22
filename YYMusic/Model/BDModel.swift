//
//  BDModel.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/19.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit
import ObjectMapper

class BaseResult: Mappable {
    var error_message: String? = "网络错误"
    var error_code: Int?
    var error: AnyObject?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        error_message <- map["error_message"]
        error_code <- map["error_code"]
    }
}

class SongInfo: BaseResult {
    var bitrate: Bitrate?
    var songinfo: BDSongModel?
    required init?(map: Map){
        super.init(map: map)
    }
    override func mapping(map: Map) {
        super.mapping(map: map)
        bitrate <- map["bitrate"]
        songinfo <- map["songinfo"]
    }
}

class SongList: BaseResult {
    var billboard: ObjectAlbum?
    var song_list: [BDSongModel]?

    required init?(map: Map){
        super.init(map: map)
    }
    override func mapping(map: Map) {
        super.mapping(map: map)
        billboard <- map["billboard"]
        song_list <- map["song_list"]
    }
}

class Billboard: Mappable {
    var bg_color: String?
    var bg_pic: String?
    var comment: String?
    var name: String?
    var web_url: String?

    var pic_s192: String?
    var pic_s210: String?
    var pic_s260: String?
    var pic_s444: String?
    var pic_s640: String?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        bg_color <- map["bg_color"]
        bg_pic <- map["bg_pic"]
        comment <- map["comment"]
        name <- map["name"]
        web_url <- map["web_url"]
        pic_s192 <- map["pic_s192"]
        pic_s210 <- map["pic_s210"]
        pic_s260 <- map["pic_s260"]
        pic_s444 <- map["pic_s444"]
        pic_s640 <- map["pic_s640"]
    }
}

class BDSongModel: Mappable {
    var album_1000_1000: String?
    var album_500_500: String?
    var album_title: String?
    var name: String?
    var artist_name: String?
    var song_id: String?
    var author: String?
    var country: String?
    var hot: Int?
    //歌词
    var lrclink: String?
    var pic_big: String?
    var pic_huge: String?
    var pic_premium: String?
    var pic_radio: String?
    var pic_s500: String?
    var pic_small: String?
    var title: String?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        album_1000_1000 <- map["album_1000_1000"]
        album_500_500 <- map["album_500_500"]
        album_title <- map["album_title"]
        name <- map["name"]
        artist_name <- map["artist_name"]
        song_id <- map["song_id"]
        author <- map["author"]
        country <- map["country"]
        hot <- map["hot"]
        lrclink <- map["lrclink"]
        pic_big <- map["pic_big"]
        pic_huge <- map["pic_huge"]
        pic_premium <- map["pic_premium"]
        pic_radio <- map["pic_radio"]
        pic_s500 <- map["pic_s500"]
        pic_small <- map["pic_small"]
        title <- map["title"]
    }
}

class Bitrate: Mappable {
    var file_link: String?
    var file_size: Int?

    var file_bitrate: Int?
    var file_duration: Int?
    var file_extension: String?
    var show_link: String?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        file_link <- map["file_link"]
        file_size <- map["file_size"]
        file_bitrate <- map["file_bitrate"]
        file_duration <- map["file_duration"]
        file_extension <- map["file_extension"]
        show_link <- map["show_link"]
    }
}

class Lrclink: Mappable {
    var time: Double?
    var lrc: String?
    init() {
    }
    required init?(map: Map){
        
    }
    func mapping(map: Map) {
        time <- map["time"]
        lrc <- map["lrc"]
    }
}
