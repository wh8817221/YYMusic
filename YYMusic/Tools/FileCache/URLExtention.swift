//
//  URLExtention.swift
//  YYMusic
//
//  Created by 王浩 on 2020/6/9.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit

extension URL {
    
    /**
    *  自定义scheme
    */
    func customSchemeURL() -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        components?.scheme = "streaming"
        return components?.url
    }

    /**
    *  还原scheme
    */
    func originalSchemeURL() -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        components?.scheme = "http"
        return components?.url
    }
}

