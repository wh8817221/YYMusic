//
//  TitleScrollView.swift
//  TestCardView
//
//  Created by 王浩 on 2019/12/30.
//  Copyright © 2019 haoge. All rights reserved.
//

import UIKit

//MARK:-代理
@objc protocol TitleScrollViewDelegate: NSObjectProtocol {
    //手动点击了按钮
    @objc optional func titleButtonDidSelectedAtIndex(index: Int)
}

class TitleScrollView: UIView, UIScrollViewDelegate {
    //共有属性
    weak var delegate: TitleScrollViewDelegate?
    fileprivate var configue = SelectConfigue()
    //按钮文字大小 默认 13
    fileprivate var btnTag = 100
    fileprivate var kWidthArr:[CGFloat] = []
    fileprivate var bWidthArr:[CGFloat] = []
    fileprivate var kPointArr:[CGFloat] = []
    fileprivate var bPointArr:[CGFloat] = []
    fileprivate var btnWidth:[CGFloat] = []
    fileprivate var btnCenter:[CGFloat] = []
    fileprivate var buttonMargin: CGFloat = 20
    fileprivate var arrTitle:[String]?

    fileprivate lazy var topScrollView:UIScrollView = {
        let scroll = UIScrollView()
        scroll.delegate = self
        scroll.alwaysBounceHorizontal = true
        scroll.showsHorizontalScrollIndicator = false
        scroll.backgroundColor = UIColor.clear
        return scroll
    }()
    
    fileprivate lazy var topAnotherScrollView:UIView = {
        let scroll = UIView()
        scroll.clipsToBounds = true
        return scroll
    }()
    
    fileprivate lazy var bottomView:UIView = {
        let view = UIView()
        view.backgroundColor = configue.lineColor
        view.layer.cornerRadius = configue.lineRadius
        view.layer.masksToBounds = true
        return view
    }()
    
    init(frame: CGRect, arrTitle: [String], configue: SelectConfigue = SelectConfigue()) {
        super.init(frame: frame)
        self.configue = configue
        self.arrTitle = arrTitle
        self.buildUI()
    }
   
    //这个需要后调用
    func buildUI() {
        topScrollView.backgroundColor = configue.scrollViewColor
        self.addSubview(topScrollView)
        topScrollView.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left)
            make.top.equalTo(self.snp.top)
            make.right.equalTo(self.snp.right)
            make.height.equalTo(44)
        }
        
        //计算按钮间距
        calculateButtonMargin()
        //创建按钮
        createtopScrollBtn()
        topScrollView.addSubview(topAnotherScrollView)
        createtopAnotherScrollBtn()
        topAnotherScrollView.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(topAnotherScrollView)
            make.height.equalTo(configue.lineHeight)
        }
        
        xianXinHanShu()
    }
    
    //MARK:-计算按钮间距
    fileprivate func calculateButtonMargin() {
        guard let arrTitle = arrTitle else {return}
        var widthTotal:CGFloat = 0
        for (_,title) in arrTitle.enumerated() {
            let width = (title as NSString).size(withAttributes: [NSAttributedString.Key.font: configue.defaultButtonFont]).width
            widthTotal += width
        }
        
        if (widthTotal+CGFloat(arrTitle.count)*buttonMargin) > self.frame.width {
            //大于的时候取默认值
        } else {
            buttonMargin = (self.frame.width-widthTotal)/CGFloat(arrTitle.count)
        }
    }
    
    public func createtopScrollBtn() {
        guard let arrTitle = arrTitle else {return}
        var tempBtn:UIButton?
        var widthTotal:CGFloat = 0
        for (index,title) in arrTitle.enumerated() {
            let btn = UIButton()
            btn.tag = self.btnTag + index
            btn.setTitle(title, for: .normal)
            btn.setTitleColor(configue.defaultButtonColor, for: .normal)
            btn.titleLabel?.font = configue.defaultButtonFont
            btn.titleLabel?.textAlignment = .center
            btn.addTarget(self, action: #selector(btnSelector(btn:)), for: .touchUpInside)
            topScrollView.addSubview(btn)
            let width = (title as NSString).size(withAttributes: [NSAttributedString.Key.font: configue.defaultButtonFont]).width
            btnWidth.append(width+buttonMargin)
            btnCenter.append((width+buttonMargin)/2+widthTotal)
            widthTotal += width + buttonMargin
            btn.snp.makeConstraints { (make) in
                if let tempBtn = tempBtn {
                    make.left.equalTo(tempBtn.snp.right)
                }else {
                    make.left.equalTo(0)
                }
                make.top.equalTo(0)
                make.width.equalTo(width+buttonMargin)
                make.height.equalTo(44)
            }
            
            tempBtn = btn
            topScrollView.contentSize = CGSize.init(width: widthTotal, height: 44)
        }
    }
    
    func scrollAnimation(btn: UIButton) {
        let btnCenterX = btn.center.x
        let topScrollWidth = topScrollView.frame.size.width
        let topScrollConsizeWidth = topScrollView.contentSize.width
        
        if btnCenterX < topScrollWidth/2 {
            topScrollView.setContentOffset(CGPoint.init(x: 0, y: 0), animated: true)
        }else if btnCenterX + topScrollWidth/2 < topScrollConsizeWidth {
            topScrollView.setContentOffset(CGPoint.init(x: btnCenterX-topScrollWidth/2, y: 0), animated: true)
            
        }else {
            topScrollView.setContentOffset(CGPoint.init(x: topScrollConsizeWidth-topScrollWidth, y: 0), animated: true)
        }
        topAnotherScrollView.snp.updateConstraints { (make) in
            make.centerX.equalTo(self.topScrollView.snp.left).offset(btnCenterX)
            make.width.equalTo(btn.frame.width - 8)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    @objc func btnSelector(btn: UIButton) {
        self.scrollAnimation(btn: btn)
        
        guard let delegate = self.delegate else {
            return
        }
        if (delegate.responds(to: #selector(delegate.titleButtonDidSelectedAtIndex(index:)))) {
            delegate.titleButtonDidSelectedAtIndex?(index: btn.tag-btnTag)
        }
    }
    
    public func createtopAnotherScrollBtn() {
        guard let arrTitle = arrTitle,arrTitle.count > 0 else {return}
        
        let widthFirst = (arrTitle[0] as NSString).size(withAttributes: [NSAttributedString.Key.font: configue.defaultButtonFont]).width
        topAnotherScrollView.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.centerX.equalTo(self.topScrollView.snp.left).offset((widthFirst+buttonMargin)/2)
            make.width.equalTo(widthFirst+buttonMargin/2)
            make.height.equalTo(44)
        }
        
        var tempBtn:UIButton?
        var widthTotal:CGFloat = 0
        for title in arrTitle {
            let btn = UIButton()
            btn.setTitle(title, for: .normal)
            btn.setTitleColor(configue.selectButtonColor, for: .normal)
            btn.titleLabel?.font = configue.defaultButtonFont
            btn.titleLabel?.textAlignment = .center
            topAnotherScrollView.addSubview(btn)
            let width = (title as NSString).size(withAttributes: [NSAttributedString.Key.font: configue.defaultButtonFont]).width
            widthTotal += width + buttonMargin
            btn.snp.makeConstraints { (make) in
                if let tempBtn = tempBtn {
                    make.left.equalTo(tempBtn.snp.right)
                }else {
                    make.left.equalTo(self.topScrollView.snp.left)
                }
                make.top.equalTo(0)
                make.width.equalTo(width+buttonMargin)
                make.height.equalTo(44)
            }
            tempBtn = btn
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x < 0 || scrollView.contentOffset.x > scrollView.contentSize.width - topScrollView.frame.width {
            return
        }
        if scrollView == topScrollView {  return }
        let offset = scrollView.contentOffset.x
        let btnCenterX = self.centerInfor(offsetX: offset)
        let width =
            self.widthInfor(offsetX: offset)-buttonMargin/2
        topAnotherScrollView.snp.updateConstraints({ (make) in
            make.centerX.equalTo(self.topScrollView.snp.left).offset(btnCenterX)
            make.width.equalTo(width)
        })
        
        let topScrollWidth = topScrollView.frame.width
        let topScrollConsizeWidth = topScrollView.contentSize.width
        if btnCenterX < topScrollWidth/2 {
            topScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        } else if btnCenterX + topScrollWidth/2 < topScrollConsizeWidth {
            topScrollView.setContentOffset(CGPoint(x: btnCenterX-topScrollWidth/2, y: 0), animated: true)
        } else {
            topScrollView.setContentOffset(CGPoint(x: topScrollConsizeWidth-topScrollWidth, y: 0), animated: true)
        }
    }
    
    fileprivate func widthInfor(offsetX:CGFloat) -> CGFloat {
        if kPointArr.count == 0 || bPointArr.count == 0{
            return 0
        }
        var index = Int(offsetX*1.999/(self.frame.width))
        if index >= kPointArr.count {
            index = kPointArr.count - 1
        }
        let k = kWidthArr[index]
        let b = bWidthArr[index]
        return k*offsetX + b
    }
    
    fileprivate func centerInfor(offsetX:CGFloat) -> CGFloat {
        if kPointArr.count == 0 || bPointArr.count == 0{
            return 0
        }
        var index = Int(offsetX*1.999/(self.frame.width))
        if index >= kPointArr.count {
            index = kPointArr.count - 1
        }
        let k = kPointArr[index]
        let b = bPointArr[index]
        
        return k*offsetX + b
    }
    
    public func xianXinHanShu() {
        guard let arrTitle = arrTitle else {return}
        
        for index in 0..<arrTitle.count - 1 {
            let startPointX = btnCenter[index] - btnWidth[index]/2
            let endPointX = btnCenter[index+1] + btnWidth[index+1]/2
            let distance = endPointX - startPointX
            let midpointX =  startPointX + distance/2
            let width = self.frame.width
            let k1 = 2*(distance - btnWidth[index])/width
            let b1 = btnWidth[index] - k1 * CGFloat(2*index) * width/2
            kWidthArr.append(k1)
            bWidthArr.append(b1)
            
            let k2 = 2*(btnWidth[index+1] - distance )/width
            let b2 = distance - k2 * CGFloat(2*index+1) * width/2
            kWidthArr.append(k2)
            bWidthArr.append(b2)
            
            let k11 = 2*(midpointX - btnCenter[index])/width
            let b11 = btnCenter[index] - k11 * CGFloat(2*index)*width/2
            kPointArr.append(k11)
            bPointArr.append(b11)
            
            let k22 = 2*( btnCenter[index+1] - midpointX )/width
            let b22 = midpointX - k22 * CGFloat(2*index+1)*width/2
            kPointArr.append(k22)
            bPointArr.append(b22)
        }
    }
}


