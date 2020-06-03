//
//  MusicView.swift
//  YYMusic
//
//  Created by 王浩 on 2020/6/1.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit
import MarqueeLabel

class MusicView: UIView {
    
    var model: BDSongModel? {
        didSet {
            if let m = model {
                let url = URL(string: m.pic_small!)
                headerImageView.kf.setImage(with: url, placeholder: UIImage(named: "musicicon"), options: nil, progressBlock: nil, completionHandler: {(result) in
                })
                songNameLbl.text = "\(m.title ?? "") - \(m.author ?? "")"
            }
        }
    }
    
    /*歌手头像*/
    var headerImageView: UIImageView!
    /*歌名-歌手名*/
    var songNameLbl: MarqueeLabel = {
        let lbl = MarqueeLabel()
        lbl.text = "歌曲-歌手"
        lbl.textColor = .black
        lbl.font = kFont15
        lbl.textAlignment = .left
        lbl.speed = .duration(10)
        lbl.trailingBuffer = 30
        lbl.fadeLength = 10
        lbl.animationCurve = .easeInOut
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initChild()
    }
    
    func initChild() {
        headerImageView = UIImageView()
        headerImageView.image = UIImage(named: "musicicon")
        headerImageView.layer.cornerRadius = 25
        headerImageView.layer.masksToBounds = true
        self.addSubview(headerImageView)
        headerImageView.snp.makeConstraints { (make) in
            make.height.width.equalTo(50)
            make.left.equalTo(self.snp.left).offset(10)
            make.bottom.equalTo(self.snp.bottom).offset(-6)
        }
        
        self.addSubview(songNameLbl)
        songNameLbl.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.snp.centerY).offset(8)
            make.left.equalTo(headerImageView.snp.right).offset(10)
            make.right.equalTo(self.snp.right)
        }
    }
    
    func startAnimation() {
        if headerImageView.layer.animation(forKey: "rotationAnimationZ") == nil {
            let rotationAnimationZ = CABasicAnimation(keyPath: "transform.rotation.z")
            rotationAnimationZ.timingFunction = CAMediaTimingFunction(name: .linear)
            rotationAnimationZ.fromValue = 0 // 开始角度
            rotationAnimationZ.toValue = 2*CGFloat(Double.pi)
            rotationAnimationZ.duration = 10
            rotationAnimationZ.autoreverses = false
            rotationAnimationZ.isRemovedOnCompletion = false
            rotationAnimationZ.repeatCount = MAXFLOAT
            rotationAnimationZ.fillMode = .forwards
            headerImageView.layer.add(rotationAnimationZ, forKey: "rotationAnimationZ")
        } else {
            let layer = headerImageView.layer
            let pausedTime = layer.timeOffset
            layer.speed = 1.0
            layer.timeOffset = 0.0
            layer.beginTime = 0
            let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
            layer.beginTime = timeSincePause
        }
    }
    
    func stopAnimation() {
        let layer = headerImageView.layer
        let pauseTime = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pauseTime
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
