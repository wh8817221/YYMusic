//
//  LrcAnalyzer.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/21.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit

class LrcAnalyzer: NSObject {
    static let shared = LrcAnalyzer()
    var lrcArray: [Lrclink] = []
    
    func analyzerLrc(by url: URL) -> [Lrclink]? {
        self.lrcArray = []
        if let lrcConnect = try? String(contentsOf: url, encoding: .utf8) {
            self.analyzerLrc(lrcConnect: lrcConnect)
        }
        return self.lrcArray
    }
    
    func analyzerLrc(by path: String) -> [Lrclink]? {
        self.lrcArray = []
        if let lrcConnect = try? String(contentsOfFile: path, encoding: .utf8) {
            self.analyzerLrc(lrcConnect: lrcConnect)
        }
        return self.lrcArray
    }
    
    //根据换行符\n分割字符串，获得包含每一句歌词的数组
    func analyzerLrc(lrcConnect: String) {
        var lrcConnectArray = lrcConnect.components(separatedBy: "\n")
        for (index,lrc) in lrcConnectArray.enumerated() {
//            if  lrc.hasPrefix("[ti:") || lrc.hasPrefix("[al:") || !lrc.hasPrefix("["){
//                continue
//            }
            if lrc.isEmpty {
                lrcConnectArray.remove(at: index)
            }
        }
        self.analyzerEachLrc(lrcConnectArray: lrcConnectArray)
    }
    
    //解析每一行歌词字符，获得时间点和对应的歌词
    func analyzerEachLrc(lrcConnectArray: [String]) {
        for lrcStr in lrcConnectArray {
            let eachLrcArray = lrcStr.components(separatedBy: "]")
            let lrc = eachLrcArray.last
            
            let df = DateFormatter()
            df.dateFormat = "[mm:ss.SS"
            let date1 = df.date(from: eachLrcArray.first!)
            let date2 = df.date(from: "[00:00.00")
            var interval1 = date1!.timeIntervalSince1970
            let interval2 = date2!.timeIntervalSince1970
            
            interval1 -= interval2
            if (interval1 < 0) {
                interval1 *= -1
            }
            
            //如果时间点对应的歌词为空就不加入歌词数组
            //        if (lrc.length == 0 || [lrc isEqualToString:@"\r"] || [lrc isEqualToString:@"\n"]) {
            //            continue;
            //        }
            let eachLrc = Lrclink()
            eachLrc.lrc = lrc
            eachLrc.time = interval1
            self.lrcArray.append(eachLrc)
            
        }
    }
}
