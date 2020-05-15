//
//  ProgressView.swift
//  test分段选择
//
//  Created by 王浩 on 2017/11/7.
//  Copyright © 2017年 王浩. All rights reserved.
//

import UIKit

class ProgressView: UIView, CAAnimationDelegate {
    var progressWidth: CGFloat = 2.5  //环形进度条的圆环宽度
    var progress: CGFloat = 0.0 {
        didSet {
            if arcLayer != nil {
                arcLayer.removeFromSuperlayer()
                self.setNeedsDisplay()
            }
        }
    }
    var progressColor: UIColor?
    fileprivate var arcLayer: CAShapeLayer!
    fileprivate var progressTimer: Timer!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let viewWidth = self.frame.width
        let progressContext = UIGraphicsGetCurrentContext()
        progressContext!.setLineWidth(progressWidth)
        
        let color = UIColor(red: 57/255, green: 57/255, blue: 58/255, alpha: 1.0)
        progressContext!.setStrokeColor(color.cgColor)
        
        let xCenter = rect.size.width * 0.5
        let yCenter = rect.size.height * 0.5
        let radius = viewWidth/2-progressWidth
        
        //绘制环形进度条底框
        progressContext!.addArc(center: CGPoint(x: xCenter, y: yCenter), radius: radius, startAngle: 0, endAngle: 2*CGFloat(Double.pi), clockwise: false)
        progressContext!.drawPath(using: .stroke)

        //绘制环形进度环
        // - M_PI * 0.5为改变初始位置
        let to = -CGFloat(Double.pi)*0.5 + self.progress * CGFloat(Double.pi)*2
        
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: xCenter, y: yCenter), radius: radius, startAngle: -CGFloat(Double.pi)*0.5, endAngle: to, clockwise: true)
    
        arcLayer = CAShapeLayer()
        arcLayer.path = path.cgPath  //46,169,230
        arcLayer.fillColor = UIColor.clear.cgColor
        
        arcLayer.strokeColor = progressColor?.cgColor
        arcLayer.lineWidth = progressWidth
        arcLayer.lineCap = CAShapeLayerLineCap(rawValue: "round")
        arcLayer.backgroundColor = UIColor.blue.cgColor
        self.layer.addSublayer(arcLayer)
        
        if self.progress > 1 {
            self.progress = 1
        } else if self.progress < 0 {
            self.progress = 0
        }
    }
}
