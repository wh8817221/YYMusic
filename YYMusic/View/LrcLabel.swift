//
//  LrcLabel.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/27.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit

class LrcLabel: UILabel {

    var progress: CGFloat = 0 {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.drawText(in: rect)
        let fillRext = CGRect(x: 0, y: 0, width: bounds.width*progress, height: bounds.height)
        UIColor(red: 38/255.0, green: 187/255, blue: 102/255.0, alpha: 1).set()
        UIRectFillUsingBlendMode(fillRext, .sourceIn)
    }

}
