//
//  StringExtention.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/20.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit

extension String {
    func timeIntervalToMMSSFormat(interval: TimeInterval) -> String {
        let ti = Int(interval)
        let seconds: Int = ti%60
        let minutes: Int = (ti/60)%60
        return String(format: "%02ld:%02ld", arguments: [minutes, seconds])
    }
    
}
