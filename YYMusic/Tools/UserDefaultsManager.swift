//
//  UserDefaultsManager.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/14.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit

let TOTALTIME = "TOTALTIME"
let CURRENTMUSIC = "CURRENTMUSIC"

class UserDefaultsManager: NSObject {
    static let shared = UserDefaultsManager()
    fileprivate var userDefaults = UserDefaults.standard
    //存
    func userDefaultsSet(object: Any?, key: String) {
        userDefaults.set(object, forKey: key)
        userDefaults.synchronize()
    }
    
    //取
    func userDefaultsGet(key: String) -> Any? {
        return userDefaults.object(forKey: key)
    }

    //删除
    func userDefaultsDelete(key: String) {
        userDefaults.removeObject(forKey: key)
    }
    
    //归档存储
    func archiver(object: Any, key: String) {
        let d = NSKeyedArchiver.archivedData(withRootObject: object)
        self.userDefaultsSet(object: d, key: key)
    }
    //归档取
    func unarchive(key: String) -> Any? {
        if let d = userDefaultsGet(key: key) as? Data {
            let obj = NSKeyedUnarchiver.unarchiveObject(with: d)
            return obj
        }
        return nil
    }
}
