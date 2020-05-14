//
//  AlamofireManager.swift
//  FeeCloud
//
//  Created by 王浩 on 2018/8/23.
//  Copyright © 2018年 haoge. All rights reserved.
//

import UIKit
import Alamofire

class AlamofireManager {
    static let sharedSessionManager: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        return Session(configuration: configuration, delegate: SessionDelegate(), serverTrustManager: nil)
    }()
}
