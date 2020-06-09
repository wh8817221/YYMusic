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
    /// 歌词的定时器
    var lrcProgress: CADisplayLink?
    
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
    
    //MARK:歌词的定时器设置
    func addLrcTimer() {
        if self.lrcArray.isEmpty {
            return
        }
        self.lrcProgress = CADisplayLink(target: self, selector: #selector(upddatePerSecond))
        self.lrcProgress?.add(to: RunLoop.main, forMode: .common)
    }
    
    //删除歌词的定时器
    func removeLrcTimer() {
        if lrcProgress != nil {
            lrcProgress?.invalidate()
            lrcProgress = nil
        }
    }
    
    //MARK:-更新歌词的时间
    @objc func upddatePerSecond() {
        if let lrc = self.getLrc() {
            NotificationCenter.post(name: .kMusicLrcProgress, object: (index: lrc.index, lrcText: lrc.lrcText, progress: lrc.progress), userInfo: nil)
        }
    }
    
    //MARK:-获取播放歌曲的信息
    func getLrc() -> (index: Int?, lrcText: String?, progress: CGFloat?)? {
        
        let cs = PlayerManager.shared.currentTime
        var i: Int = 0
        var progress: CGFloat = 0.0
        //歌词滚动显示
        for (index,lrc) in lrcArray.enumerated() {
            let currrentLrc = lrc
            var nextLrc: Lrclink?
            //获取下一句歌词
            if index == lrcArray.count-1 {
                nextLrc = lrcArray[index]
            } else {
                nextLrc = lrcArray[index+1]
            }
            
            if Double(cs) >= currrentLrc.time! && Double(cs) < (nextLrc?.time)! {
                i = index
                progress = CGFloat((Double(cs)-currrentLrc.time!)/((nextLrc?.time)!-currrentLrc.time!))
                return (i, currrentLrc.lrc, progress)
            }
        }
        return nil
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
