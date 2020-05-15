//
//  PlayerBottomCell.swift
//  YYMusic
//
//  Created by 王浩 on 2020/5/14.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit
import Kingfisher

class PlayerBottomCell: UICollectionViewCell {
    static let identifier = String(describing: PlayerBottomCell.self)
    var tapCallback: ObjectCallback?
    var isSongPlayer: Bool = false {
        didSet{
            self.playAndPauseBtn.isSelected = isSongPlayer
            if isSongPlayer {
                //开始动画
                startAnimation()
            }
        }
    }
    
    var musicModel: MusicModel? {
        didSet {
            if let m = musicModel {
                let url = URL(string: m.coverSmall!)
                headerImageView.kf.setImage(with: url, placeholder: UIImage(named: "musicicon"), options: nil, progressBlock: nil, completionHandler: {(result) in
                })
                songNameLbl.text = m.title ?? ""
                songerLbl.text = m.nickname ?? ""
            }
        }
    }
    
    /*圆环进度指示器*/
    var progress: CGFloat = 0.0 {
        didSet{
            if progress > 1 || progress < 0 { return }
            if arcLayer != nil {
                arcLayer.removeFromSuperlayer()
                drawCircle(rect: playAndPauseBtn.frame, progress: progress)
            }
        }
    }
    
    /*歌手头像*/
    @IBOutlet weak var headerImageView: UIImageView!
    /*歌名*/
    @IBOutlet weak var songNameLbl: UILabel!
    /*歌手名*/
    @IBOutlet weak var songerLbl: UILabel!
    /*播放暂停按钮*/
    @IBOutlet weak var playAndPauseBtn: UIButton!
    fileprivate var arcLayer: CAShapeLayer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor(red: 57/255, green: 57/255, blue: 58/255, alpha: 1.0)
        
        headerImageView.layer.cornerRadius = headerImageView.frame.height/2
        headerImageView.layer.masksToBounds = true
        
        songNameLbl.textColor = kThemeColor
        songNameLbl.font = kFont17
        songerLbl.textColor = .white
        songerLbl.font = kFont12
        
        playAndPauseBtn.setImage(UIImage(named: "icons_play_music1"), for: .normal)
        playAndPauseBtn.setImage(UIImage(named: "icons_stop_music1"), for: .selected)
        playAndPauseBtn.addTarget(self, action: #selector(playAndPause(_:)), for: .touchUpInside)
        drawCircle(rect: playAndPauseBtn.frame, progress: 0.0)
    }
    
    //绘制圆环
    fileprivate func drawCircle(rect: CGRect, progress: CGFloat) {
        let xCenter = rect.size.width * 0.5
        let yCenter = rect.size.height * 0.5
        let radius = rect.size.width/2-2.5
        //绘制环形进度环
        // - M_PI * 0.5为改变初始位置
        let to = -CGFloat(Double.pi)*0.5 + progress * CGFloat(Double.pi)*2
        
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: xCenter, y: yCenter), radius: CGFloat(radius), startAngle: -CGFloat(Double.pi)*0.5, endAngle: to, clockwise: true)
    
        arcLayer = CAShapeLayer()
        arcLayer.path = path.cgPath  //46,169,230
        arcLayer.fillColor = UIColor.clear.cgColor
        
        arcLayer.strokeColor = kThemeColor.cgColor
        arcLayer.lineWidth = 2.5
        arcLayer.lineCap = CAShapeLayerLineCap(rawValue: "round")
        playAndPauseBtn.layer.addSublayer(arcLayer)
    }
    
    @objc func playAndPause(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if !sender.isSelected {
            //暂停播放
            PlayerManager.shared.playerPause()
            //停止动画
            self.stopAnimation()
        } else {
            //开始播放
            PlayerManager.shared.playerPlay()
            //开始动画
            startAnimation()
        }
        tapCallback?(PlayerManager.shared.isPlaying)
    }
    
    func startAnimation() {
        if headerImageView.layer.animation(forKey: "rotationAnimationX") == nil {
            let rotationAnimationX = CABasicAnimation(keyPath: "transform.rotation.z")
            rotationAnimationX.beginTime = 0
            rotationAnimationX.toValue = 2 * CGFloat(Double.pi)
            rotationAnimationX.duration = 5
            rotationAnimationX.isRemovedOnCompletion = false
            rotationAnimationX.repeatCount = MAXFLOAT
            headerImageView.layer.add(rotationAnimationX, forKey: "rotationAnimationX")
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
}
