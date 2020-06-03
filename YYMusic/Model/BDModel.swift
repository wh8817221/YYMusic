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

class BDSongModel: NSObject, Mappable, NSCoding {
    required init?(coder: NSCoder) {
        self.name = coder.decodeObject(forKey: "name") as? String
        self.pic_small = coder.decodeObject(forKey: "pic_small") as? String
        self.pic_premium = coder.decodeObject(forKey: "pic_premium") as? String
        self.pic_big = coder.decodeObject(forKey: "pic_big") as? String
        
        self.file_link = coder.decodeObject(forKey: "file_link") as? String
        self.lrclink = coder.decodeObject(forKey: "lrclink") as? String
        self.title = coder.decodeObject(forKey: "title") as? String
        self.author = coder.decodeObject(forKey: "author") as? String
        self.song_id = coder.decodeObject(forKey: "song_id") as? String
    }

    func encode(with coder: NSCoder) {
        coder.encode(name, forKey:"name")
        coder.encode(song_id, forKey:"song_id")
        coder.encode(author, forKey:"author")
        coder.encode(lrclink, forKey:"lrclink")
        coder.encode(title, forKey:"title")
        coder.encode(pic_big, forKey:"pic_big")
        coder.encode(pic_premium, forKey:"pic_premium")
        coder.encode(pic_small, forKey:"pic_small")
        coder.encode(file_link, forKey:"file_link")
    }

    var album_title: String?
    var name: String?
    var artist_name: String?
    var song_id: String?
    var author: String?
    var hot: Int?
    //歌词
    var lrclink: String?
    var pic_big: String?
    var pic_premium: String?
    var pic_small: String?
    var title: String?
    //播放歌曲的链接
    var file_link: String?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        album_title <- map["album_title"]
        name <- map["name"]
        artist_name <- map["artist_name"]
        song_id <- map["song_id"]
        author <- map["author"]
        hot <- map["hot"]
        lrclink <- map["lrclink"]
        pic_big <- map["pic_big"]
        pic_premium <- map["pic_premium"]
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


class MVBase: BaseResult {
    var result: MVResult?
    required init?(map: Map){
        super.init(map: map)
    }
    override func mapping(map: Map) {
        super.mapping(map: map)
        result <- map["result"]
    }
}

class MVResult: Mappable {
    var has_more: Bool?
    var total: Int?
    var mvList: [MVList]?
    var files: MVFilesBase?
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        total <- map["total"]
        mvList <- map["mvList"]
        files <- map["files"]
    }
}

class MVList: Mappable {
    var mv_id: String?
    var thumbnail: String?
    var title: String?
    var artist: String?
    var artist_id: String?
    var thumbnail2: String?
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        mv_id <- map["mv_id"]
        thumbnail <- map["thumbnail"]
        thumbnail2 <- map["thumbnail2"]
        title <- map["title"]
        artist <- map["artist"]
        artist_id <- map["artist_id"]
    }
}

class MVFilesBase: Mappable {
    //清晰度
    var liuchang: MVFiles?
    var biaoqing: MVFiles?
    var gaoqing: MVFiles?
    var chaoqing: MVFiles?
    
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        liuchang <- map["31"]
        biaoqing <- map["41"]
        gaoqing <- map["61"]
        chaoqing <- map["71"]
    }
}

class MVFiles: Mappable {
    //清晰度
    var definition_name: String?
    var aspect_ratio: String?
    var file_link: String?
    var source_path: String?
    
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        definition_name <- map["definition_name"]
        aspect_ratio <- map["aspect_ratio"]
        file_link <- map["file_link"]
        source_path <- map["source_path"]
    }
}
