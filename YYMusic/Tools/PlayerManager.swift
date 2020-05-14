//
//  PlayerManager.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/14.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerManager: NSObject {
    static let shared = PlayerManager()
    /*存放歌曲数组*/
    var musicArray: [MusicModel] = []
    /*播放下标*/
    var index: Int = 0
    /*标记是不是没点列表直接点了播放按钮如果是就默认播放按钮*/
    var isFristPlayerPauseBtn: Bool = false
    /*开始播放*///0是开始 1 暂停
    var isStartPlayer: ((_ index: Int) -> Void)?
    /*是不是正在播放*/
    var isPlaying: Bool = false
    /*播放器*/
    fileprivate var player: AVPlayer!
    override init() {
        super.init()
        if player == nil {
            player = AVPlayer()
            let session = AVAudioSession.sharedInstance()
            try? session.setCategory(.playback)
            try? session.setActive(true, options: [])
        }
    }
    //播放
    func playerPlay() {
        player.play()
        isPlaying = true
    }
    //暂停
    func playerPause() {
        player.pause()
        isPlaying = false
    }
    
    //播放和暂停
    func playAndPause() {
        if isPlaying {
            self.playerPause()
            if let startPlayer = self.isStartPlayer {
                startPlayer(1)
            }
        } else {
            self.playerPlay()
            if let startPlayer = self.isStartPlayer {
                startPlayer(0)
            }
        }
    }

    //前一首
    func playPrevious() {
        if self.index == 0 {
            self.index = self.musicArray.count - 1
        } else {
            self.index -= 1
        }
    }
    
    //下一首
    func playNext() {
        if self.index == self.musicArray.count - 1 {
            self.index = 0
        } else {
            self.index += 1
        }
    }
  
    func playerVolume(with volumeFloat: CGFloat) {
        self.player.volume = Float(volumeFloat)
    }

    func playerProgress(with progressFloat: Double) {
        let time = CMTime(seconds: progressFloat, preferredTimescale: 1)
        self.player.seek(to: time) { [weak self](finished) in
            self?.playerPlay()
        }
    }
    
    //当前播放
    func replaceItem(with urlString: String) {
        let url = URL(string: urlString)
        let item = AVPlayerItem(url: url!)
        self.player.replaceCurrentItem(with: item)
        self.playerPlay()
    }
}
