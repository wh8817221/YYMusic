//
//  PlayButton.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/28.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit

class PlayButton: UIButton {
    
    var model: MusicModel? {
        didSet {
            if let url = URL(string: (model?.coverSmall)!) {
                self.kf.setImage(with: url, for: .normal)
            }
        }
    }
    
    /*圆环进度指示器*/
    var progress: CGFloat = 0.0
//    {
//        didSet{
//            diskAnimation(progress: progress)
//            if progress > 1 || progress < 0 { return }
//            arcLayer.removeFromSuperlayer()
//            drawCircle(progress: progress)
//        }
//    }
    
    fileprivate lazy var arcLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        
        layer.strokeColor = UIColor.green.cgColor
        layer.lineWidth = 2.5
        layer.lineCap = CAShapeLayerLineCap(rawValue: "round")
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setImage(UIImage(named: "musicicon"), for: .normal)
//        startAnimation()
    }
        
    //绘制进度圆环
    fileprivate func drawCircle(progress: CGFloat) {
        let xCenter = self.bounds.size.width * 0.5
        let yCenter = self.bounds.size.height * 0.5
        let radius = self.bounds.size.width/2-2
        //绘制环形进度环
        // - M_PI * 0.5为改变初始位置
        let to = -CGFloat(Double.pi)*0.5 + progress * CGFloat(Double.pi)*2
        
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: xCenter, y: yCenter), radius: CGFloat(radius), startAngle: -CGFloat(Double.pi)*0.5, endAngle: to, clockwise: true)
        arcLayer.path = path.cgPath  //46,169,230
        self.layer.addSublayer(arcLayer)
    }

    func startAnimation() {
        if self.layer.animation(forKey: "rotationAnimationZ") == nil {
            let rotationAnimationZ = CABasicAnimation(keyPath: "transform.rotation.z")
            rotationAnimationZ.timingFunction = CAMediaTimingFunction(name: .linear)
            rotationAnimationZ.fromValue = 0 // 开始角度
            rotationAnimationZ.toValue = 2*CGFloat(Double.pi)
            rotationAnimationZ.duration = 10
            rotationAnimationZ.autoreverses = false
            rotationAnimationZ.isRemovedOnCompletion = false
            rotationAnimationZ.repeatCount = MAXFLOAT
            rotationAnimationZ.fillMode = .forwards
            self.layer.add(rotationAnimationZ, forKey: "rotationAnimationZ")
        } else {
            let layer = self.layer
            let pausedTime = layer.timeOffset
            layer.speed = 1.0
            layer.timeOffset = 0.0
            layer.beginTime = 0
            let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
            layer.beginTime = timeSincePause
        }
    }
    
    func stopAnimation() {
        let layer = self.layer
        let pauseTime = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pauseTime
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
