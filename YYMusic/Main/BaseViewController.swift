//
//  BaseViewController.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/21.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    var statusBarStyle: UIStatusBarStyle = .default {
        didSet {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
