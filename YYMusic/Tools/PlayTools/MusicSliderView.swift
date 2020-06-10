//
//  MusicSliderView.swift
//  YYMusic
//
//  Created by 王浩 on 2020/6/9.
//  Copyright © 2020 haoge. All rights reserved.
//

import UIKit

@objc protocol MusicSliderViewDelegate: NSObjectProtocol {
    // 滑块滑动开始
    @objc optional func sliderTouchBegan(value: CGFloat)
    // 滑块滑动中
    @objc optional func sliderValueChanged(value: CGFloat)
    // 滑块滑动结束
    @objc optional func sliderTouchEnded(value: CGFloat)
    // 滑杆点击
    @objc optional func sliderTapped(value: CGFloat)
}

class MusicSliderView: UIView {
    weak var delegate: MusicSliderViewDelegate?
    
    /** 默认滑杆的颜色 */
    var bgTintColor: UIColor = UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1.0) {
        didSet{
            bgProgressView.backgroundColor = bgTintColor
        }
    }
    /** 滑杆进度颜色 */
    var progressTintColor: UIColor = .white{
        didSet{
            sliderProgressView.backgroundColor = progressTintColor
        }
    }
    /** 缓存进度颜色 */
    var bufferTintColor: UIColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1.0) {
        didSet{
            bufferProgressView.backgroundColor = bufferTintColor
        }
    }
    
    /** 滑杆进度 */
    var value: CGFloat? {
        didSet{
            if let rate = value {
                let offsetX = (self.frame.width - kSliderBtnWH)*rate
                self.sliderProgressView.frame.size.width = offsetX
                self.sliderBtn.center.x = offsetX+kSliderBtnWH/2
                self.lastPoint = self.sliderBtn.center
            }
        }
    }
    /** 缓存进度 */
    var bufferValue: CGFloat? {
        didSet {
            let finishValue = self.bgProgressView.frame.width * bufferValue!
            //动画
            UIView.animate(withDuration: 0.5, animations: {
                self.bufferProgressView.frame.size.width = finishValue
            })
        }
    }
    /** 滑块的大小 */
    fileprivate var kSliderBtnWH: CGFloat = 22.0
    /** 进度的高度 */
    fileprivate var kProgressH: CGFloat = 3.0
    
    /** 滑块 */
    fileprivate lazy var sliderBtn: UIButton = {
        let btn = UIButton(type: .custom)
        let highlighted = UIImage(named: "music_slider_circle")
        let normal = UIImage(named: "icon_dot")
        btn.setImage(normal, for: .normal)
        btn.setImage(highlighted, for: .highlighted)
        btn.addTarget(self, action: #selector(sliderBtnTouchBegin(_:)), for: .touchDown)
        btn.addTarget(self, action: #selector(sliderBtnTouchEnded(_:)), for: .touchCancel)
        btn.addTarget(self, action: #selector(sliderBtnTouchEnded(_:)), for: .touchUpInside)
        btn.addTarget(self, action: #selector(sliderBtnTouchEnded(_:)), for: .touchUpOutside)
        btn.addTarget(self, action: #selector(sliderBtnDragMoving(_:event:)), for: .touchDragInside)
        return btn
    }()
    
    fileprivate lazy var bgProgressView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = self.bgTintColor
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = kProgressH/2
        iv.layer.masksToBounds = true
        return iv
    }()
    
    fileprivate lazy var bufferProgressView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = self.bufferTintColor
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = kProgressH/2
        iv.layer.masksToBounds = true
        return iv
    }()
    
    fileprivate lazy var sliderProgressView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = self.progressTintColor
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = kProgressH/2
        iv.layer.masksToBounds = true
        return iv
    }()
    
    fileprivate var lastPoint: CGPoint?
    fileprivate var tapGesture: UITapGestureRecognizer!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addSubViews()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.bgProgressView.frame.size.width = self.frame.width-kSliderBtnWH
        
        self.bgProgressView.center.y = self.frame.size.height*0.5
        self.bufferProgressView.center.y = self.frame.size.height*0.5
        self.sliderProgressView.center.y = self.frame.size.height*0.5
        
        self.sliderBtn.center.y = self.frame.size.height*0.5
    }
    
    func addSubViews() {
        self.backgroundColor = UIColor.clear
        
        self.addSubview(bgProgressView)
        self.addSubview(bufferProgressView)
        self.addSubview(sliderProgressView)
        self.addSubview(sliderBtn)
        //初始化frame
        bgProgressView.frame = CGRect(x: kSliderBtnWH/2, y: 0, width: 0, height: kProgressH)
        
        bufferProgressView.frame = bgProgressView.frame
        sliderProgressView.frame = bgProgressView.frame
        
        sliderBtn.frame = CGRect(x: 0, y: 0, width: kSliderBtnWH, height: kSliderBtnWH)
        
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc fileprivate func tapped(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: self)
        //获取进度
        var value = (point.x - self.bgProgressView.frame.minX)/self.bgProgressView.frame.width
        value = value >= 1.0 ? 1.0 : value <= 0 ? 0 : value
        self.value = value
        guard let delegate = self.delegate else {
            return
        }
        if delegate.responds(to: #selector(delegate.sliderTapped(value:))) {
            delegate.sliderTapped?(value: value)
        }
    }
    
    @objc fileprivate func sliderBtnTouchBegin(_ sender: UIButton) {
        guard let delegate = self.delegate else {
            return
        }
        if delegate.responds(to: #selector(delegate.sliderTouchBegan(value:))) {
            delegate.sliderTouchBegan?(value: self.value ?? 0)
        }
    }
    
    @objc fileprivate func sliderBtnTouchEnded(_ sender: UIButton) {
        guard let delegate = self.delegate else {
            return
        }
        if delegate.responds(to: #selector(delegate.sliderTouchEnded(value:))) {
            delegate.sliderTouchEnded?(value: self.value ?? 0)
        }
    }
    
    @objc fileprivate func sliderBtnDragMoving(_ sender: UIButton, event: UIEvent) {
        guard let point = event.allTouches?.first?.location(in: self) else {
            return
        }
        // 获取进度值 由于btn是从 0-(self.width - btn.width)
        var value = (point.x-sender.frame.width*0.5)/(self.frame.width-sender.frame.width)
        value = value >= 1.0 ? 1.0 : value <= 0.0 ? 0.0 : value
        self.value = value
        
        guard let delegate = self.delegate else {
            return
        }
        if delegate.responds(to: #selector(delegate.sliderValueChanged(value:))) {
            delegate.sliderValueChanged?(value: value)
        }
    }
    
    
}
