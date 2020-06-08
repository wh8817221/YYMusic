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
        let lrcConnectArray = lrcConnect.components(separatedBy: "\n")
//        print(lrcConnectArray)
//        for (index,lrc) in lrcConnectArray.enumerated() {
//            if  lrc.hasPrefix("[ti:") || lrc.hasPrefix("[al:") || !lrc.hasPrefix("["){
//                continue
//            }
//            if lrc.isEmpty {
//                lrcConnectArray.remove(at: index)
//            }
//        }
//        self.analyzerEachLrc(lrcConnectArray: lrcConnectArray)
        self.lyricParase(with: lrcConnectArray)
    }
    
    //解析每一行歌词字符，获得时间点和对应的歌词
    func analyzerEachLrc(lrcConnectArray: [String]) {
        for lrcStr in lrcConnectArray {
            let eachLrcArray = lrcStr.components(separatedBy: "]")
            let lrc = eachLrcArray.last
            
            //如果时间点对应的歌词为空就不加入歌词数组
//            if lrc?.count == 0 || lrc == "\r" || lrc == "\n" {
//                continue
//            }
            
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

            let eachLrc = Lrclink()
            eachLrc.lrc = lrc
            eachLrc.time = interval1
            self.lrcArray.append(eachLrc)
            
        }
    }
    
    func lyricParase(with linesArray: [String]) {
        let pattern = "\\[[0-9][0-9]:[0-9][0-9].[0-9]{1,}\\]"
        guard let regular = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return
        }
        for line in linesArray {
            let matchesArray = regular.matches(in: line, options: .reportProgress, range: NSRange(location: 0, length: line.count))
            let lrc = line.components(separatedBy: "]").last
            
            //如果时间点对应的歌词为空就不加入歌词数组
//            if lrc?.count == 0 || lrc == "\r" || lrc == "\n" {
//                continue
//            }
            
            for match in matchesArray {
                var timeStr = NSString(string: line).substring(with: match.range)
                // 去掉开头和结尾的[],得到时间00:00.00
                timeStr = timeStr.textSubstring(startIndex: 1, length: timeStr.count-2)
                
                let df = DateFormatter()
                df.dateFormat = "mm:ss.SS"
                let date1 = df.date(from: timeStr)
                let date2 = df.date(from: "00:00.00")
                var interval1 = date1!.timeIntervalSince1970
                let interval2 = date2!.timeIntervalSince1970
                
                interval1 -= interval2
                if (interval1 < 0) {
                    interval1 *= -1
                }

                let eachLrc = Lrclink()
                eachLrc.lrc = lrc
                eachLrc.time = interval1
                self.lrcArray.append(eachLrc)
            }
        }
    }
}

extension String {
    //字符串截取
    func textSubstring(startIndex: Int, length: Int) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: startIndex)
        let endIndex = self.index(startIndex, offsetBy: length)
        let subvalues = self[startIndex..<endIndex]
        return String(subvalues)
    }
}
