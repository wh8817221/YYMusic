//
//  AppDelegate.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/13.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var allowOrentitaionRotation: Bool = false
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        initRootViewController()
        //开启接收远程事件
        application.beginReceivingRemoteControlEvents()
        return true
    }
    
    func initRootViewController() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = getStoryboardInstantiateViewController(identifier: "MainViewController")
        self.window?.backgroundColor = .white
        self.window?.makeKeyAndVisible()
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        if event?.type == UIEvent.EventType.remoteControl {
            switch event?.subtype {
            case .remoteControlPause:
                //暂停
                WHPlayerBottomView.shared.tapPlayButton(isPlay: false)
            case .remoteControlPlay:
                //播放
                WHPlayerBottomView.shared.tapPlayButton(isPlay: true)
            case .remoteControlPreviousTrack:
                //前一首
                WHPlayerBottomView.shared.previousMusic()
            case .remoteControlNextTrack:
                //下一首
                WHPlayerBottomView.shared.nextMusic()
            default:
                break
            }
        }
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if self.allowOrentitaionRotation {
            return .allButUpsideDown
        }
        return .portrait
    }
}

