//
//  CustomHUD.swift
//  Demo
//
//  Created by 王浩 on 2018/11/27.
//  Copyright © 2018 SwiftKick Mobile. All rights reserved.
//

import UIKit
import PKHUD
class CustomHUD: NSObject {
    
    class func showProgress() {
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()
    }
    
    class func showProgress(title: String?, subtitle: String?) {
        PKHUD.sharedHUD.contentView = PKHUDProgressView(title: title, subtitle: subtitle)
        PKHUD.sharedHUD.show()
    }
    
    class func hideProgress(delay: Double = 0.25, completion: (()->Void)? = nil) {
        PKHUD.sharedHUD.hide(afterDelay: delay) { (finished) in
            if finished {
                completion?()
            }
        }
    }
    
    class func showHideTextHUD(_ text: String?, delay: Double = 1.0, completion: (()->Void)? = nil) {
        PKHUD.sharedHUD.contentView = PKHUDTextView(text: text)
        if !PKHUD.sharedHUD.isVisible {
            PKHUD.sharedHUD.show()
        }
        PKHUD.sharedHUD.hide(afterDelay: delay) { (finished) in
            if finished {
                completion?()
            }
        }
    }
    
    class func showSuccessHUD(title: String? = nil, subtitle: String? = nil, delay: Double = 0.25, completion: (()->Void)? = nil) {
        PKHUD.sharedHUD.contentView = PKHUDSuccessView(title: title, subtitle: subtitle)
        if !PKHUD.sharedHUD.isVisible {
            PKHUD.sharedHUD.show()
        }
        PKHUD.sharedHUD.hide(afterDelay: delay) { (finished) in
            if finished {
                completion?()
            }
        }
    }
    
    class func showHideErrorHUD(title: String? = nil, subtitle: String = "网络错误", delay: Double = 0.25, completion: (()->Void)? = nil) {
        PKHUD.sharedHUD.contentView = PKHUDErrorView(title: title, subtitle: subtitle)
        if !PKHUD.sharedHUD.isVisible {
            PKHUD.sharedHUD.show()
        }
        PKHUD.sharedHUD.hide(afterDelay: delay) { (finished) in
            if finished {
                completion?()
            }
        }
    }
}
