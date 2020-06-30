//
//  CommonResult.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/13.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit
import ObjectMapper

class ObjectNull: Mappable {
    required init?( map: Map){
        
    }
    func mapping( map: Map) {
    }
}

class ObjectOption: Mappable {
    var id: Int?
    var name: String?
    var object: String?
    var fplx: String?
    init(id: Int, name: String, object: String = "") {
        self.id = id
        self.name = name
        self.object = object
    }
    
    init(id: Int, fplx: String, name: String) {
        self.id = id
        self.fplx = fplx
        self.name = name
    }
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        name <- map["option_name"]
        object <- map["object"]
        fplx <- map["fplx"]
    }
}
