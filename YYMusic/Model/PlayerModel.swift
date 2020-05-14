//
//  PlayerModel.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/13.
//  Copyright © 2020 haoge. All rights reserved.
//

import ObjectMapper

class Result<T: Mappable>: Mappable {
    var album: ObjectAlbum?
    var msg: String?
    var ret: Int?
    var data: T?
    var error: AnyObject?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        album <- map["album"]
        msg <- map["msg"]
        ret <- map["ret"]
        data <- map["tracks"]
    }
}

class ObjectAlbum: Mappable {
    var albumId: Int?
    var avatarPath: String?
    var categoryName: String?
    var coverLarge: String?
    var coverLargePop: String?
    var coverMiddle: String?
    var coverOrigin: String?
    var coverSmall: String?
    var coverWebLarge: String?
    var customSubTitle: String?
    var customTitle: String?
    var intro: String?
    var lastUptrackCoverPath: String?
    var lastUptrackTitle: String?
    var salePoint: String?
    var salePointPopup: String?
    var shortIntro: String?
    var tags: String?
    var title: String?
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        coverWebLarge <- map["coverWebLarge"]
        coverSmall <- map["coverSmall"]
        coverOrigin <- map["coverOrigin"]
        coverMiddle <- map["coverMiddle"]
        coverLarge <- map["coverLarge"]
        albumId <- map["albumId"]
        avatarPath <- map["avatarPath"]
        categoryName <- map["categoryName"]
        title <- map["title"]
        tags <- map["tags"]
        shortIntro <- map["shortIntro"]
        salePointPopup <- map["salePointPopup"]
        salePoint <- map["salePoint"]
        lastUptrackTitle <- map["lastUptrackTitle"]
        lastUptrackCoverPath <- map["lastUptrackCoverPath"]
        intro <- map["intro"]
        customTitle <- map["customTitle"]
        customSubTitle <- map["customSubTitle"]
    }
}

class PlayerModels: Mappable {
    var list: [PlayerModel]?
    var maxPageId: Int?
    var pageId: Int?
    var pageSize: Int?
    var totalCount: Int?
    
    required init?(map: Map){
        
    }
    
    init() {
    }
    
    func mapping(map: Map) {
        list <- map["list"]
        maxPageId <- map["maxPageId"]
        pageId <- map["pageId"]
        pageSize <- map["pageSize"]
        totalCount <- map["totalCount"]
    }
}

class PlayerModel: Mappable {
    var albumId: Int?
    var comments: Int?
    var coverMiddle: String?
    var coverSmall: String?
    
    var coverLarge: String?
    var playUrl32: String?
    var title: String?
    var nickname: String?
    var trackId: String?
    required init?(map: Map){
        
    }
    
    init() {
    }
    
    func mapping(map: Map) {
        albumId <- map["albumId"]
        comments <- map["comments"]
        coverMiddle <- map["coverMiddle"]
        coverSmall <- map["coverSmall"]
        
        coverLarge <- map["coverLarge"]
        playUrl32 <- map["playUrl32"]
        title <- map["title"]
        nickname <- map["nickname"]
        trackId <- map["trackId"]
    }
}
