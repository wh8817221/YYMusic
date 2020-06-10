//
//  StringExtention.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/20.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit

extension String {
    //获取时间格式
    func timeIntervalToMMSSFormat(interval: TimeInterval) -> String {
        let ti = Int(interval)
        let seconds: Int = ti%60
        let minutes: Int = (ti/60)%60
        return String(format: "%02ld:%02ld", arguments: [minutes, seconds])
    }
    
    //字符串截取
    func textSubstring(startIndex: Int, length: Int) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: startIndex)
        let endIndex = self.index(startIndex, offsetBy: length)
        let subvalues = self[startIndex..<endIndex]
        return String(subvalues)
    }
    /**
    *  临时文件路径
    */
    static func tempFilePath() -> String {
        return NSHomeDirectory().appending("/tmp").appending("/MusicTemp.mp3")
    }
    
    /**
    *  缓存文件夹路径
    */
    static func cacheFolderPath() -> String {
        return NSHomeDirectory().appending("/Library").appending("/MusicCaches")
    }
    
    /**
    *  获取网址中的文件名
    */
    static func fileName(with url: URL) -> String? {
        return url.path.components(separatedBy: "/").last
    }
}
