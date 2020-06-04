//
//  AppDelegate.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/13.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var allowOrentitaionRotation: Bool = false
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        initRootViewController()
        //开启接收远程事件
        application.beginReceivingRemoteControlEvents()
        //监听音乐被打断
        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionWasInterrupted(_:)), name: AVAudioSession.interruptionNotification, object: nil)
        return true
    }
    
    @objc fileprivate func audioSessionWasInterrupted(_ notification: Notification) {
        if let type = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? Int{
            let opetions = notification.userInfo?[AVAudioSessionInterruptionOptionKey]
            switch UInt(type) {
            case AVAudioSession.InterruptionType.began.rawValue:
                PlayerManager.shared.playerPause()
            case AVAudioSession.InterruptionType.ended.rawValue:
                //是否可以继续播放
                if let ot = opetions as? Int {
                    if UInt(ot) == AVAudioSession.InterruptionOptions.shouldResume.rawValue {
                        PlayerManager.shared.playerPlay()
                    }
                }
            default:
                break
            }
        }
    }
    
    func initRootViewController() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = getStoryboardInstantiateViewController(identifier: "MainTabBarViewController")
        self.window?.backgroundColor = .white
        self.window?.makeKeyAndVisible()
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        if event?.type == UIEvent.EventType.remoteControl {
            switch event?.subtype {
            case .remoteControlPause:
                PlayerManager.shared.playerPause()
            case .remoteControlPlay:
                //播放
                PlayerManager.shared.playerPlay()
            case .remoteControlPreviousTrack:
                //前一首
                PlayerManager.shared.playPrevious()
            case .remoteControlNextTrack:
                //下一首
                PlayerManager.shared.playNext()
            default:
                break
            }
            PlayerManager.shared.updateLockedScreenMusic()
        }
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if self.allowOrentitaionRotation {
            return .allButUpsideDown
        }
        return .portrait
    }
    
    func applicationProtectedDataDidBecomeAvailable(_ application: UIApplication) {
        print("解锁")
        PlayerManager.shared.isLockedScreen = false
    }
    
    func applicationProtectedDataWillBecomeUnavailable(_ application: UIApplication) {
        PlayerManager.shared.isLockedScreen = true
        PlayerManager.shared.updateLockedScreenMusic()
    }
}

